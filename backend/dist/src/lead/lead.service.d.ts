import { PrismaService } from '../prisma.service';
export declare class LeadService {
    private prisma;
    constructor(prisma: PrismaService);
    create(createLeadDto: any): Promise<any>;
    findAll(): Promise<any>;
    findOne(id: string): Promise<any>;
    findByAgent(agentId: string): Promise<any>;
    update(id: string, updateLeadDto: any): Promise<any>;
    remove(id: string): Promise<any>;
}
