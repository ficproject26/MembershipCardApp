import { Injectable, Logger } from '@nestjs/common';
import { InjectQueue } from '@nestjs/bullmq';
import { Queue } from 'bullmq';

@Injectable()
export class QueueService {
  private readonly logger = new Logger(QueueService.name);

  constructor(@InjectQueue('email') private readonly emailQueue: Queue) {}

  async sendVerificationEmail(to: string, token: string) {
    try {
      await this.emailQueue.add('verification', { to, token }, {
        attempts: 3,
        backoff: { type: 'exponential', delay: 1000 },
      });
      this.logger.log(`Added verification email job for ${to}`);
    } catch (error) {
      this.logger.error(`Failed to add verification email job: ${error.message}`);
    }
  }

  async sendPasswordResetEmail(to: string, token: string) {
    try {
      await this.emailQueue.add('passwordReset', { to, token }, {
        attempts: 3,
        backoff: { type: 'exponential', delay: 1000 },
      });
      this.logger.log(`Added password reset email job for ${to}`);
    } catch (error) {
      this.logger.error(`Failed to add password reset email job: ${error.message}`);
    }
  }
}

