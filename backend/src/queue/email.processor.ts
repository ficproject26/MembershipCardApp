import { Processor, WorkerHost } from '@nestjs/bullmq';
import { Job } from 'bullmq';
import { Logger } from '@nestjs/common';
import { EmailService } from '../email/email.service';

@Processor('email')
export class EmailProcessor extends WorkerHost {
  private readonly logger = new Logger(EmailProcessor.name);

  constructor(private readonly emailService: EmailService) {
    super();
  }

  async process(job: Job<any, any, string>): Promise<any> {
    this.logger.log(`Processing email job ${job.id} of type ${job.name}`);

    try {
      switch (job.name) {
        case 'verification':
          await this.emailService.sendVerificationEmail(job.data.to, job.data.token);
          break;
        case 'passwordReset':
          await this.emailService.sendPasswordResetEmail(job.data.to, job.data.token);
          break;
        case 'welcome':
          await this.emailService.sendWelcomeEmail(job.data.to, job.data.name);
          break;
        default:
          this.logger.warn(`Unknown email job type: ${job.name}`);
      }
      this.logger.log(`Successfully completed email job ${job.id}`);
    } catch (error) {
      this.logger.error(`Failed to process email job ${job.id}`, error.stack);
      throw error;
    }
  }
}
