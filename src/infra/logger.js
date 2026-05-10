const pino = require('pino');
const config = require('../config');

function createLogger(name) {
  return pino({
    name,
    level: config.logLevel,
    redact: {
      paths: ['req.headers.authorization', 'req.headers.cookie'],
      remove: true,
    },
  });
}

module.exports = { createLogger };
