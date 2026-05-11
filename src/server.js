const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const path = require('path');
const pinoHttp = require('pino-http');
const { randomUUID } = require('crypto');

const config = require('./config');
const { pool } = require('./infra/db');
const { setupWorkerQueue, closeWorkerQueue } = require('./infra/workerTransport');
const { createLogger } = require('./infra/logger');

const healthRouter = require('./routes/health');
const usersRouter = require('./routes/users');

async function bootstrap() {
  await pool.query('select 1');
  await setupWorkerQueue();
}

function createApp(logger) {
  const app = express();
  app.locals.logger = logger;

  app.disable('x-powered-by');

  app.use(
    helmet({
      contentSecurityPolicy: false,
      crossOriginEmbedderPolicy: false,
    })
  );
  app.use(cors());
  app.use(
    pinoHttp({
      logger,
      genReqId: (req, res) => {
        const id = req.headers['x-request-id'];
        if (id && typeof id === 'string' && id.length < 200) return id;
        return randomUUID();
      },
      customLogLevel: (req, res, err) => {
        if (res.statusCode >= 500 || err) return 'error';
        if (res.statusCode >= 400) return 'warn';
        return 'info';
      },
    })
  );
  app.use(express.json({ limit: '256kb' }));
  app.use(express.static(path.join(__dirname, '..', 'public')));

  app.use('/api/v1', healthRouter);
  app.use('/api/v1', usersRouter);

  app.use((err, req, res, next) => {
    const log = req.log || app.locals.logger;
    log.error({ err, path: req.path }, 'request error');
    const status = err.status || 500;
    res.status(status).json({
      error: err.message || 'Internal Server Error',
      ...(err.details ? { details: err.details } : {}),
    });
  });

  return app;
}

async function runApiServer(options = {}) {
  const attachSignals = options.attachSignals !== false;

  if (!config.databaseUrl && !config.useEmbeddedPostgres) {
    throw new Error(
      'DATABASE_URL is required for external Postgres. Omit DATABASE_URL to use embedded local Postgres (zero-config).'
    );
  }

  const logger = createLogger('spinbattles-api');

  await bootstrap();
  const app = createApp(logger);
  const server = app.listen(config.port, () => {
    const baseUrl = `http://localhost:${config.port}`;
    logger.info(
      { port: config.port, workerSocketPort: config.workerSocketPort, baseUrl },
      'API listening'
    );
  });

  const shutdown = async () => {
    try {
      server.close();
    } catch (_) {}
    try {
      await closeWorkerQueue();
    } catch (_) {}
    try {
      await pool.end();
    } catch (_) {}
    process.exit(0);
  };

  if (attachSignals) {
    process.on('SIGINT', shutdown);
    process.on('SIGTERM', shutdown);
  }

  return { server, shutdown, logger };
}

async function main() {
  await runApiServer({ attachSignals: true });
}

const embeddedSingle = process.env.SPIN_EMBEDDED_SINGLE_PROCESS === '1';
if (require.main === module && !embeddedSingle) {
  main().catch((e) => {
    // eslint-disable-next-line no-console
    console.error(e);
    process.exit(1);
  });
}

module.exports = { bootstrap, createApp, runApiServer };
