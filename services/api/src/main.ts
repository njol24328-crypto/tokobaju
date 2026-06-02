import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  app.enableCors({
    origin: [
      'http://localhost:3000',
      'http://localhost:3001',
      'http://localhost:3002'
    ],
    credentials: true
  });
  await app.listen(4000);
  console.log('API service running on http://localhost:4000');
}

bootstrap();
