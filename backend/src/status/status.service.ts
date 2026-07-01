import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma.service';

@Injectable()
export class StatusService {
  constructor(private readonly prisma: PrismaService) {}

  async createStatus(userId: string, userName: string, content: string, type: string = 'TEXT', mediaUrl?: string) {
    return this.prisma.statusUpdate.create({
      data: {
        userId,
        userName,
        content,
        type,
        mediaUrl,
      },
    });
  }

  async getActiveStatuses() {
    // Return statuses from the last 24 hours
    const yesterday = new Date();
    yesterday.setHours(yesterday.getHours() - 24);

    return this.prisma.statusUpdate.findMany({
      where: {
        createdAt: {
          gte: yesterday,
        },
      },
      orderBy: {
        createdAt: 'asc',
      },
    });
  }

  async deleteStatus(id: string) {
    return this.prisma.statusUpdate.delete({
      where: { id },
    });
  }
}
