import { Controller, Post, Body, Logger } from '@nestjs/common';
import { PrismaService } from '../prisma.service';
import { FcmService } from '../integrations/fcm/fcm.service';

@Controller('notifications')
export class NotificationController {
  private readonly logger = new Logger(NotificationController.name);

  constructor(
    private prisma: PrismaService,
    private fcmService: FcmService,
  ) {}

  @Post('register-token')
  async registerToken(@Body() body: { userId: string; userType: string; fcmToken: string }) {
    const { userId, userType, fcmToken } = body;
    this.logger.log(`Registering FCM token for ${userType} ${userId}`);

    try {
      if (userType === 'agent') {
        const agent = await this.prisma.agent.findFirst({
          where: { OR: [{ id: userId }, { agentCode: userId }] }
        });
        if (agent) {
          await this.prisma.agent.update({
            where: { id: agent.id },
            data: { fcmToken },
          });
        }
      } else if (userType === 'staff' || userType === 'admin') {
        await this.prisma.staff.update({
          where: { id: userId },
          data: { fcmToken },
        });
      }
      return { success: true, message: 'FCM token registered' };
    } catch (error) {
      this.logger.error(`Failed to register token: ${error.message}`);
      return { success: false, message: error.message };
    }
  }

  @Post('send')
  async sendNotification(@Body() body: { 
    userId: string; 
    userType: string; 
    title: string; 
    message: string;
    data?: Record<string, string>;
  }) {
    const { userId, userType, title, message, data } = body;

    try {
      let fcmToken: string | null = null;

      if (userType === 'agent') {
        const agent = await this.prisma.agent.findUnique({ where: { id: userId } });
        fcmToken = agent?.fcmToken || null;
      } else if (userType === 'staff' || userType === 'admin') {
        const staff = await this.prisma.staff.findUnique({ where: { id: userId } });
        fcmToken = staff?.fcmToken || null;
      }

      if (!fcmToken) {
        return { success: false, message: 'No FCM token found for user' };
      }

      const sent = await this.fcmService.sendToDevice(fcmToken, title, message, data);
      return { success: sent, message: sent ? 'Notification sent' : 'Failed to send' };
    } catch (error) {
      this.logger.error(`Failed to send notification: ${error.message}`);
      return { success: false, message: error.message };
    }
  }

  @Post('send-to-all-agents')
  async sendToAllAgents(@Body() body: { title: string; message: string; data?: Record<string, string> }) {
    const agents = await this.prisma.agent.findMany({
      where: { fcmToken: { not: null } },
      select: { fcmToken: true },
    });

    const tokens = agents.map((a: any) => a.fcmToken!).filter(Boolean);
    if (!tokens.length) {
      return { success: false, message: 'No agents with FCM tokens found' };
    }

    const invalidTokens = await this.fcmService.sendToMultiple(tokens, body.title, body.message, body.data);
    
    // Clean up invalid tokens
    if (invalidTokens.length > 0) {
      await this.prisma.agent.updateMany({
        where: { fcmToken: { in: invalidTokens } },
        data: { fcmToken: null },
      });
    }

    return { success: true, sent: tokens.length - invalidTokens.length, failed: invalidTokens.length };
  }
}
