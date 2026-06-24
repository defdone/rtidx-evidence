require('dotenv').config();

const path = require('path');
const { spawn } = require('child_process');
const config = require('./config');

if (config.useEmbeddedPostgres) {
  process.env.SPIN_EMBEDDED_SINGLE_PROCESS = '1';
  require('./standalone');
} else {
  const root = path.join(__dirname, '..');
  const concurrently = path.join(root, 'node_modules', 'concurrently', 'dist', 'bin', 'concurrently.js');
  const serverJs = path.join(root, 'src', 'server.js');
  const workerJs = path.join(root, 'src', 'worker.js');
  const child = spawn(
    process.execPath,
    [
      concurrently,
      '-k',
      '-n',
      'api,worker',
      `${process.execPath} ${serverJs}`,
      `${process.execPath} ${workerJs}`,
    ],
    { cwd: root, stdio: 'inherit', shell: true }
  );
  child.on('exit', (code) => process.exit(code === null ? 0 : code));
}
