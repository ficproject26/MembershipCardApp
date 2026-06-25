import { PrismaService } from '../prisma.service';
export declare class AgentService {
    private prisma;
    constructor(prisma: PrismaService);
    create(createAgentDto: any): Promise<any>;
    login(email: string, password?: string): Promise<any>;
    findAll(): Promise<any>;
    findOne(id: string): Promise<any>;
    findByPhone(phoneNumber: string): Promise<any>;
    update(id: string, updateAgentDto: any): Promise<any>;
    remove(id: string): Promise<any>;
}
