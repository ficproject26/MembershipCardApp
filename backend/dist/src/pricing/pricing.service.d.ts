import { PrismaService } from '../prisma.service';
export declare class PricingService {
    private prisma;
    constructor(prisma: PrismaService);
    create(createPricingDto: any): Promise<any>;
    findAll(): Promise<any>;
    findOne(id: number): Promise<any>;
    update(id: number, updatePricingDto: any): Promise<any>;
    remove(id: number): Promise<any>;
}
