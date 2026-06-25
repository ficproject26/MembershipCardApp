import { OnModuleInit, OnModuleDestroy } from '@nestjs/common';
export declare class PrismaService implements OnModuleInit, OnModuleDestroy {
    private client;
    constructor();
    get agent(): any;
    get lead(): any;
    get transaction(): any;
    get membershipPricing(): any;
    get commissionConfig(): any;
    get staff(): any;
    onModuleInit(): Promise<void>;
    onModuleDestroy(): Promise<void>;
}
