import { PrismaService } from '../prisma.service';
import { Prisma } from '@prisma/client';
export declare class StaffService {
    private prisma;
    constructor(prisma: PrismaService);
    create(data: Prisma.StaffCreateInput): Promise<any>;
    findAll(): Promise<any>;
    findOne(id: string): Promise<any>;
    login(email: string, password: string): Promise<any>;
    update(id: string, data: Prisma.StaffUpdateInput): Promise<any>;
    remove(id: string): Promise<any>;
}
