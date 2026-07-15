import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { DocumentBuilder, SwaggerModule } from '@nestjs/swagger';
import { AppLogger } from './common/logger';
import * as Sentry from '@sentry/node';
import helmet from 'helmet';

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

  // ─── Security: Helmet HTTP headers ───
  // XSS protection, clickjacking block, MIME sniffing prevent
  app.use(helmet());

  // ─── Security: CORS restriction ───
  // Only allow requests from our frontend & mobile apps
  const isProduction = process.env.NODE_ENV === 'production';
  const allowedOrigins = isProduction
    ? ['https://membershipcardapp.onrender.com']
    : [
        'https://membershipcardapp.onrender.com',
        'http://localhost:3000',
        'http://localhost:3001',
        'http://localhost:8080',
        'http://10.0.2.2:3001', // Android emulator
      ];

  app.enableCors({
    origin: (origin: string | undefined, callback: (err: Error | null, allow?: boolean) => void) => {
      // Allow requests with no origin (mobile apps, Postman, server-to-server)
      if (!origin || allowedOrigins.includes(origin)) {
        callback(null, true);
      } else {
        callback(new Error(`Origin ${origin} not allowed by CORS`));
      }
    },
    methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE'],
    allowedHeaders: ['Content-Type', 'Authorization', 'Accept'],
    credentials: true,
  });

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
