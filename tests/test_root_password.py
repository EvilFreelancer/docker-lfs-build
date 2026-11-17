"""Run with python3 -m unittest discover -s tests -v. No root access required."""
import json
import os
from pathlib import Path
import subprocess
import tempfile
import unittest


REPO = Path(__file__).resolve().parents[1]
PASSWORD_SCRIPT = REPO / 'book/chapter-7/7.x-configure-root-password.sh'


class RootPasswordTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.bin = self.root / 'bin'
        self.bin.mkdir()
        self.log = self.root / 'calls.jsonl'
        self.env = dict(os.environ, PATH=f'{self.bin}:/usr/bin:/bin',
                        TEST_LOG=str(self.log), TEST_HELPER=str(PASSWORD_SCRIPT))
        self.env.pop('LFS_ROOT_PASSWORD', None)
        for name in ('pwconv', 'passwd', 'chpasswd', 'chroot', 'sudo'):
            self.mock(name)

    def mock(self, name):
        path = self.bin / name
        path.write_text('''#!/usr/bin/python3
import json, os, subprocess, sys
from pathlib import Path
name = Path(sys.argv[0]).name
record = dict(name=name, args=sys.argv[1:],
              password_env=os.environ.get('LFS_ROOT_PASSWORD'))
if name == 'chpasswd':
    record['input'] = sys.stdin.read()
with open(os.environ['TEST_LOG'], 'a') as log:
    log.write(json.dumps(record) + '\\n')
if os.environ.get('TEST_FAIL') == name:
    sys.exit(17)
if name == 'chroot' and sys.argv[-1].endswith('7.x-configure-root-password.sh'):
    sys.exit(subprocess.call(['/bin/bash', '-x', os.environ['TEST_HELPER']]))
if name == 'sudo':
    # The image links /bin/sh to Bash; reproduce that on hosts using dash.
    sys.exit(subprocess.call(['/bin/bash', '-x', '-']))
''')
        path.chmod(0o755)

    def calls(self):
        return [json.loads(line) for line in self.log.read_text().splitlines()]

    def helper(self, value, fail=None):
        if fail:
            self.env['TEST_FAIL'] = fail
        result = subprocess.run(['bash', '-x', str(PASSWORD_SCRIPT)],
                                input=value, text=True, capture_output=True,
                                env=self.env)
        if value:
            self.assertNotIn(value, result.stdout + result.stderr)
        self.assertTrue(all(c['password_env'] is None for c in self.calls()))
        return result

    def test_password_preserves_shell_characters_and_whitespace(self):
        secret = '  test$`password`\\ "\' * % !  '
        result = self.helper(secret)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual([c['name'] for c in self.calls()],
                         ['pwconv', 'passwd', 'chpasswd'])
        self.assertEqual(self.calls()[1]['args'], ['-l', 'root'])
        self.assertEqual(self.calls()[2]['args'], ['-c', 'SHA512'])
        self.assertEqual(self.calls()[2]['input'], f'root:{secret}\n')

    def test_empty_locks_root_and_warns(self):
        result = self.helper('')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn('root is locked', result.stderr)
        self.assertEqual([c['name'] for c in self.calls()], ['pwconv', 'passwd'])

    def test_colon_and_newline_injection_rejected(self):
        for secret in ('invalid:password', 'secret\nother:entry',
                       'trailing-newline\n', 'carriage\rreturn'):
            with self.subTest(secret=repr(secret)):
                self.log.unlink(missing_ok=True)
                result = self.helper(secret)
                self.assertNotEqual(result.returncode, 0)
                self.assertIn('must not contain', result.stderr)
                self.assertNotIn('chpasswd', [c['name'] for c in self.calls()])

    def test_shadow_failures_propagate(self):
        for command in ('pwconv', 'passwd', 'chpasswd'):
            with self.subTest(command=command):
                result = self.helper('failure-test-secret', command)
                self.assertNotEqual(result.returncode, 0)

    def chapter(self, secret=None, fail=None):
        self.env.update(LFS='/unused-lfs', TERM='dumb')
        if secret is not None:
            self.env['LFS_ROOT_PASSWORD'] = secret
        if fail:
            self.env['TEST_FAIL'] = fail
        return subprocess.run(['bash', '-x', str(REPO / 'book/chapter-7.sh')],
                              env=self.env, text=True, capture_output=True)

    def test_chroot_transport_and_trace(self):
        secret = 'transport-$-secret " with spaces'
        result = self.chapter(secret)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertNotIn(secret, result.stdout + result.stderr)
        calls = self.calls()
        self.assertTrue(all(c['password_env'] is None for c in calls))
        chroots = [c for c in calls if c['name'] == 'chroot']
        self.assertEqual(len(chroots), 2)
        self.assertTrue(all(secret not in str(c['args']) for c in chroots))
        self.assertEqual(calls[3]['input'], f'root:{secret}\n')

    def test_unset_password_chapter(self):
        result = self.chapter()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn('root is locked', result.stderr)

    def test_password_failure_stops_other_chroot_configuration(self):
        result = self.chapter('chroot-failure-secret', fail='chpasswd')
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(sum(c['name'] == 'chroot' for c in self.calls()), 1)

    def test_driver_scopes_password_and_stops_before_images(self):
        # Substitute paths only in the test copy; run the real driver's logic.
        script = (REPO / 'book/book.sh').read_text()
        for directory in ('book', 'image'):
            target = self.root / directory
            target.mkdir()
            script = script.replace(f'/{directory}/', f'{target}/')
        for name in ('chapter-3.sh', 'chapter-5.sh', 'chapter-6.sh',
                     'chapter-7.sh', 'chapter-8.sh', 'chapter-9.sh'):
            path = self.root / 'book' / name
            path.write_text('''#!/usr/bin/python3
import json, os, sys
from pathlib import Path
name = Path(sys.argv[0]).name
with open(os.environ['TEST_LOG'], 'a') as log:
    log.write(json.dumps(dict(name=name, password_env=os.environ.get('LFS_ROOT_PASSWORD'))) + '\\n')
if name == 'chapter-7.sh':
    sys.exit(17)
''')
            path.chmod(0o755)
        self.env.update(LFS=str(self.root), LFS_ROOT_PASSWORD='driver-secret')
        result = subprocess.run(['bash', '-x', '-c', script], env=self.env,
                                text=True, capture_output=True)
        self.assertEqual(result.returncode, 17, result.stderr)
        self.assertNotIn('driver-secret', result.stdout + result.stderr)
        calls = [c for c in self.calls() if c['name'] != 'sudo']
        self.assertEqual([c['name'] for c in calls],
                         ['chapter-3.sh', 'chapter-5.sh', 'chapter-6.sh', 'chapter-7.sh'])
        for call in calls:
            expected = 'driver-secret' if call['name'] == 'chapter-7.sh' else None
            self.assertEqual(call['password_env'], expected)

        # Also verify the successful path clears the password before packaging.
        chapter = self.root / 'book/chapter-7.sh'
        success_script = chapter.read_text().replace('sys.exit(17)', 'sys.exit(0)')
        chapter.write_text(success_script)
        image = self.root / 'image/image.sh'
        image.write_text(success_script)
        image.chmod(0o755)
        self.log.unlink()
        result = subprocess.run(['bash', '-x', '-c', script], env=self.env,
                                text=True, capture_output=True)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertNotIn('driver-secret', result.stdout + result.stderr)
        later = self.calls()[-3:]
        self.assertEqual([c['name'] for c in later],
                         ['chapter-8.sh', 'chapter-9.sh', 'image.sh'])
        self.assertTrue(all(c['password_env'] is None for c in later))


if __name__ == '__main__':
    unittest.main()
