import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma.service';

@Injectable()
export class ChatService {
  constructor(private readonly prisma: PrismaService) {}

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
    return this.prisma.message.create({
      data,
    });
  }
}
