import { Injectable, OnModuleInit, OnModuleDestroy, forwardRef, Inject } from '@nestjs/common';
import { PrismaClient } from '@prisma/client';
import { SystemGateway } from './system.gateway';

let prismaInstance: PrismaClient | null = null;

@Injectable()
export class PrismaService implements OnModuleInit, OnModuleDestroy {
  private client: PrismaClient;

  constructor(
    @Inject(forwardRef(() => SystemGateway))
    private readonly systemGateway: SystemGateway,
  ) {
    if (!prismaInstance) {
      prismaInstance = new PrismaClient();
    }
    
    const gateway = this.systemGateway;
    this.client = (prismaInstance as any).$extends({
      query: {
        $allModels: {
          async $allOperations({ model, operation, args, query }: any) {
            const result = await query(args);
            const mutationActions = ['create', 'update', 'delete', 'upsert', 'createMany', 'updateMany', 'deleteMany'];
            
            if (mutationActions.includes(operation)) {
              if (model !== 'Message') {
                try {
                  gateway.broadcastDataChanged(model, operation);
                } catch (e) {
                  console.error('Failed to broadcast data change:', e);
                }
              }
            }
            return result;
          }
        }
      }
    }) as any;
  }

  get agent() {
    return (this.client as any).agent;
  }

  get lead() {
    return (this.client as any).lead;
  }

  get transaction() {
    return (this.client as any).transaction;
  }

  get membershipPricing() {
    return (this.client as any).membershipPricing;
  }

  get commissionConfig() {
    return (this.client as any).commissionConfig;
  }

  get staff() {
    return (this.client as any).staff;
  }

  get message() {
    return (this.client as any).message;
  }

  get statusUpdate() {
    return (this.client as any).statusUpdate;
  }

  get kycDocument() {
    return (this.client as any).kycDocument;
  }

  async onModuleInit() {
    await (this.client as any).$connect();
  }

  async onModuleDestroy() {
    await (this.client as any).$disconnect?.();
  }
}
