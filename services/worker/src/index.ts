import Redis from 'ioredis';

const redis = new Redis(process.env.REDIS_URL ?? 'redis://localhost:6379');

async function startWorker() {
  console.log('Worker service started');
  redis.on('connect', () => console.log('Connected to Redis'));
}

startWorker().catch((error) => {
  console.error('Worker startup failed', error);
  process.exit(1);
});
