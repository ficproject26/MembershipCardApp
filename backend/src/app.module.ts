import { Module } from '@nestjs/common';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { ServeStaticModule } from '@nestjs/serve-static';
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

@Module({
  imports: [
    ServeStaticModule.forRoot({
      rootPath: join(process.cwd(), 'uploads'),
      serveRoot: '/uploads/',
    }),
    PrismaModule, AgentModule, LeadModule, PricingModule, StaffModule, AuthModule, IntegrationsModule, QueueModule, ChatModule, StatusModule, KycUploadModule
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
