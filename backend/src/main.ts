import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { DocumentBuilder, SwaggerModule } from '@nestjs/swagger';
import { AppLogger } from './common/logger';
import * as Sentry from '@sentry/node';

async function bootstrap() {
  // Initialize Sentry
  if (process.env.SENTRY_DSN && process.env.SENTRY_DSN !== 'placeholder_sentry_dsn') {
    Sentry.init({
      dsn: process.env.SENTRY_DSN,
      tracesSampleRate: 1.0,
      environment: process.env.NODE_ENV || 'development',
    });
  }

  const app = await NestFactory.create(AppModule, {
    logger: AppLogger,
  });

  app.enableCors();

  const config = new DocumentBuilder()
    .setTitle('FIC Admin Control API')
    .setDescription('The API documentation for the Membership Card application')
    .setVersion('1.0')
    .addBearerAuth()
    .build();
  const document = SwaggerModule.createDocument(app, config);
  SwaggerModule.setup('api', app, document);

  await app.listen(process.env.PORT ?? 3001, '0.0.0.0');
}
bootstrap();
