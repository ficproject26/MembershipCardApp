import { Injectable, OnModuleInit, OnModuleDestroy } from '@nestjs/common';
import { PrismaClient } from '@prisma/client';
import { PrismaBetterSqlite3 } from '@prisma/adapter-better-sqlite3';
import * as path from 'path';

let prismaInstance: PrismaClient | null = null;

@Injectable()
export class PrismaService implements OnModuleInit, OnModuleDestroy {
  private client: PrismaClient;

  constructor() {
    if (!prismaInstance) {
      const dbPath = path.resolve(process.cwd(), 'dev.db');
      const adapter = new PrismaBetterSqlite3({ url: dbPath });
      prismaInstance = new PrismaClient({ adapter } as any);
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

  async onModuleInit() {
    // No-op for SQLite adapter
  }

  async onModuleDestroy() {
    await (this.client as any).$disconnect?.();
  }
}
