import { Injectable, OnModuleInit, OnModuleDestroy } from '@nestjs/common';
import { PrismaClient } from '@prisma/client';

let prismaInstance: PrismaClient | null = null;

@Injectable()
export class PrismaService implements OnModuleInit, OnModuleDestroy {
  private client: PrismaClient;

  constructor() {
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
  }

  async onModuleDestroy() {
    await (this.client as any).$disconnect?.();
  }
}
