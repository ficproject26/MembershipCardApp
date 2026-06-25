import { Module } from '@nestjs/common';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { AgentModule } from './agent/agent.module';
import { LeadModule } from './lead/lead.module';
import { PricingModule } from './pricing/pricing.module';
import { PrismaModule } from './prisma.module';
import { StaffModule } from './staff/staff.module';
import { AuthModule } from './auth/auth.module';
import { IntegrationsModule } from './integrations/integrations.module';
import { QueueModule } from './queue/queue.module';

@Module({
  imports: [PrismaModule, AgentModule, LeadModule, PricingModule, StaffModule, AuthModule, IntegrationsModule, QueueModule],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
