import { Module } from '@nestjs/common';
import { NotificationController } from './notification.controller';
import { IntegrationsModule } from '../integrations/integrations.module';

@Module({
  imports: [IntegrationsModule],
  controllers: [NotificationController],
})
export class NotificationModule {}
