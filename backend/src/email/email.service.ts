import { Injectable, Logger } from '@nestjs/common';
import * as nodemailer from 'nodemailer';

@Injectable()
export class EmailService {
  private readonly logger = new Logger(EmailService.name);
  private transporter: nodemailer.Transporter;

  constructor() {
    this.transporter = nodemailer.createTransport({
      host: process.env.EMAIL_HOST || 'smtp.gmail.com',
      port: parseInt(process.env.EMAIL_PORT || '587', 10),
      secure: false, // true for 465, false for other ports
      auth: {
        user: process.env.EMAIL_USER,
        pass: process.env.EMAIL_PASS,
      },
    });
  }

  async sendVerificationEmail(to: string, token: string): Promise<void> {
    const verificationUrl = `http://localhost:3000/auth/verify-email?token=${token}`; // Update this with your actual frontend URL later

    const mailOptions = {
      from: `"Membership App" <${process.env.EMAIL_USER}>`,
      to,
      subject: 'Verify your email address',
      html: `
        <h3>Welcome!</h3>
        <p>Please verify your email by clicking the link below:</p>
        <a href="${verificationUrl}">${verificationUrl}</a>
        <p>If you did not request this, please ignore this email.</p>
      `,
    };

    try {
      await this.transporter.sendMail(mailOptions);
      this.logger.log(`Verification email sent to ${to}`);
    } catch (error) {
      this.logger.error(`Failed to send verification email to ${to}`, error.stack);
      // Depending on requirements, you might want to throw error here
    }
  }

  async sendPasswordResetEmail(to: string, token: string): Promise<void> {
    const resetUrl = `http://localhost:3000/auth/reset-password?token=${token}`; // Update this with your actual frontend URL later

    const mailOptions = {
      from: `"Membership App" <${process.env.EMAIL_USER}>`,
      to,
      subject: 'Reset your password',
      html: `
        <h3>Password Reset Request</h3>
        <p>You requested to reset your password. Click the link below to set a new password:</p>
        <a href="${resetUrl}">${resetUrl}</a>
        <p>This link will expire in 1 hour.</p>
        <p>If you did not request this, please ignore this email.</p>
      `,
    };

    try {
      await this.transporter.sendMail(mailOptions);
      this.logger.log(`Password reset email sent to ${to}`);
    } catch (error) {
      this.logger.error(`Failed to send password reset email to ${to}`, error.stack);
    }
  }
}
