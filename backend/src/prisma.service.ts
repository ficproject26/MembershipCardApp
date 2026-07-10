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
    this.client = prismaInstance;
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
    await this.client.$connect();

    // Broadcast changes to all connected websocket clients
    (this.client as any).$use(async (params: any, next: any) => {
      const result = await next(params);
      const mutationActions = ['create', 'update', 'delete', 'upsert', 'createMany', 'updateMany', 'deleteMany'];
      
      if (mutationActions.includes(params.action)) {
        // Exclude specific models from broadcasting if they are too noisy, e.g., Message
        if (params.model !== 'Message') {
          try {
            this.systemGateway.broadcastDataChanged(params.model, params.action);
          } catch (e) {
            console.error('Failed to broadcast data change:', e);
          }
        }
      }
      return result;
    });
  }

  async onModuleDestroy() {
    await (this.client as any).$disconnect?.();
  }
}
