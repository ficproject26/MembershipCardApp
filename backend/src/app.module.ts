import { Module } from '@nestjs/common';
import { APP_GUARD } from '@nestjs/core';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { ServeStaticModule } from '@nestjs/serve-static';
import { ThrottlerModule } from '@nestjs/throttler';
import { join } from 'path';
import { AgentModule } from './agent/agent.module';
import { LeadModule } from './lead/lead.module';
import { PricingModule } from './pricing/pricing.module';
import { PrismaModule } from './prisma.module';
import { StaffModule } from './staff/staff.module';
import { AuthModule } from './auth/auth.module';
import { IntegrationsModule } from './integrations/integrations.module';
import { QueueModule } from './queue/queue.module';
import { ChatModule } from './chat/chat.module';
import { StatusModule } from './status/status.module';
import { KycUploadModule } from './kyc-upload/kyc-upload.module';
import { EmailModule } from './email/email.module';
import { RedisModule } from './redis/redis.module';
import { NotificationModule } from './notification/notification.module';
import { CommissionModule } from './commission/commission.module';
import { AgoraModule } from './agora/agora.module';
import { CustomThrottlerGuard } from './common/guards/throttle.guard';

@Module({
  imports: [
    // ─── Security: Rate Limiting ───
    // Global limit: 100 requests per 60 seconds per IP
    ThrottlerModule.forRoot([{
      ttl: 60000,
      limit: 100,
    }]),
    ServeStaticModule.forRoot({
      rootPath: join(process.cwd(), 'uploads'),
      serveRoot: '/uploads/',
    }),
    PrismaModule, AgentModule, LeadModule, PricingModule, StaffModule, AuthModule, IntegrationsModule, QueueModule, ChatModule, StatusModule, KycUploadModule, EmailModule, RedisModule, NotificationModule, CommissionModule, AgoraModule
  ],
  controllers: [AppController],
  providers: [
    AppService,
    // ─── Security: Apply throttle guard globally ───
    {
      provide: APP_GUARD,
      useClass: CustomThrottlerGuard,
    },
  ],
})
export class AppModule {}

