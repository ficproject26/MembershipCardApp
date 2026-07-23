import { Module } from '@nestjs/common';
import { LeadService } from './lead.service';
import { LeadController } from './lead.controller';
import { IntegrationsModule } from '../integrations/integrations.module';
import { RedisModule } from '../redis/redis.module';

@Module({
  imports: [IntegrationsModule, RedisModule],
  controllers: [LeadController],
  providers: [LeadService],
})
export class LeadModule {}
