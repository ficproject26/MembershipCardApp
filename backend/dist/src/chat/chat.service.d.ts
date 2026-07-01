import { PrismaService } from '../prisma.service';
export declare class ChatService {
    private readonly prisma;
    constructor(prisma: PrismaService);
    getMessages(user1Id: string, user2Id: string): Promise<any>;
    saveMessage(data: {
        senderId: string;
        senderType: string;
        receiverId: string;
        receiverType: string;
        content: string;
        type?: string;
        mediaUrl?: string;
    }): Promise<any>;
}
