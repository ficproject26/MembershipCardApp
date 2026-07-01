import { PrismaService } from '../prisma.service';
export declare class StatusService {
    private readonly prisma;
    constructor(prisma: PrismaService);
    createStatus(userId: string, userName: string, content: string, type?: string, mediaUrl?: string): Promise<any>;
    getActiveStatuses(): Promise<any>;
    deleteStatus(id: string): Promise<any>;
}
