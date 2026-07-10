import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma.service';
import { FcmService } from '../integrations/fcm/fcm.service';

@Injectable()
export class ChatService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly fcmService: FcmService,
  ) {}

  async getMessages(user1Id: string, user2Id: string) {
    return this.prisma.message.findMany({
      where: {
        OR: [
          { senderId: user1Id, receiverId: user2Id },
          { senderId: user2Id, receiverId: user1Id },
        ],
      },
      orderBy: { createdAt: 'asc' },
    });
  }

  async saveMessage(data: {
    senderId: string;
    senderType: string;
    receiverId: string;
    receiverType: string;
    content: string;
    type?: string;
    mediaUrl?: string;
  }) {
    const message = await this.prisma.message.create({
      data,
    });

    // Send Push Notification
    try {
      let receiverFcmToken: string | null = null;

      if (data.receiverType === 'Agent') {
        const agent = await this.prisma.agent.findUnique({ where: { id: data.receiverId } });
        receiverFcmToken = agent?.fcmToken;
      } else if (data.receiverType === 'Staff') {
        const staff = await this.prisma.staff.findUnique({ where: { id: data.receiverId } });
        receiverFcmToken = staff?.fcmToken;
      }

      if (receiverFcmToken) {
        // Send notification: title="New Message", body="<message content>"
        await this.fcmService.sendToDevice(
          receiverFcmToken,
          'New Message',
          data.type === 'IMAGE' ? '📷 Image' : data.type === 'VIDEO' ? '🎥 Video' : data.content,
          {
            type: 'chat',
            senderId: data.senderId,
            senderType: data.senderType,
          }
        );
      }
    } catch (error) {
      console.error('Error sending push notification for chat message:', error);
    }

    return message;
  }
}
