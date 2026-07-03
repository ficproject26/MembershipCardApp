import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { PrismaService } from '../prisma.service';
import { QueueService } from '../queue/queue.service';
import * as crypto from 'crypto';

@Injectable()
export class AuthService {
  constructor(
    private prisma: PrismaService,
    private queueService: QueueService,
  ) {}

  async verifyEmail(token: string) {
    const agent = await this.prisma.agent.findFirst({
      where: { verificationToken: token },
    });

    if (!agent) {
      throw new BadRequestException('Invalid or expired verification token');
    }

    await this.prisma.agent.update({
      where: { id: agent.id },
      data: {
        isEmailVerified: true,
        verificationToken: null,
      },
    });

    return { message: 'Email verified successfully' };
  }

  async forgotPassword(email: string) {
    const agent = await this.prisma.agent.findUnique({ where: { email } });
    if (!agent) {
      // Return success even if not found to prevent email enumeration
      return { message: 'If an account with that email exists, a reset link has been sent.' };
    }

    const resetToken = crypto.randomBytes(32).toString('hex');
    const resetTokenExpiry = new Date(Date.now() + 60 * 60 * 1000); // 1 hour

    await this.prisma.agent.update({
      where: { id: agent.id },
      data: {
        resetToken,
        resetTokenExpiry,
      },
    });

    this.queueService.sendPasswordResetEmail(agent.email, resetToken);

    return { message: 'If an account with that email exists, a reset link has been sent.' };
  }

  async resetPassword(token: string, newPassword: string) {
    const agent = await this.prisma.agent.findFirst({
      where: {
        resetToken: token,
        resetTokenExpiry: { gt: new Date() },
      },
    });

    if (!agent) {
      throw new BadRequestException('Invalid or expired reset token');
    }

    await this.prisma.agent.update({
      where: { id: agent.id },
      data: {
        password: newPassword, // In a real app, hash this before saving!
        resetToken: null,
        resetTokenExpiry: null,
      },
    });

    return { message: 'Password has been reset successfully' };
  }
}
