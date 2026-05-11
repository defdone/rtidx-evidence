const { z } = require('zod');

const userIdParam = z.object({
  userId: z.string().uuid(),
});

const claimIdParam = z.object({
  userId: z.string().uuid(),
  claimId: z.string().uuid(),
});

const createUserBody = z.object({
  handle: z.string().trim().min(1).max(64),
});

const creditsBody = z.object({
  delta: z.coerce.number().int().refine((d) => d !== 0, { message: 'delta must be non-zero' }),
  reason: z.string().trim().min(1).max(256),
  idempotency_key: z.preprocess(
    (v) => (v === '' || v == null ? undefined : String(v).trim()),
    z.string().min(1).max(128).optional()
  ),
});

const claimBody = z.object({
  sku: z.string().trim().min(1).max(64),
  tx_hash: z
    .string()
    .regex(/^0x[a-fA-F0-9]{64}$/, 'tx_hash must be a 32-byte 0x-prefixed hex string'),
});

function validationError(zodError) {
  const e = new Error('Validation failed');
  e.status = 400;
  e.details = zodError.flatten();
  return e;
}

module.exports = {
  userIdParam,
  claimIdParam,
  createUserBody,
  creditsBody,
  claimBody,
  validationError,
};
