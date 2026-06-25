import { PrismaClient } from '@prisma/client';
import { PrismaBetterSqlite3 } from '@prisma/adapter-better-sqlite3';
import * as path from 'path';

const dbPath = path.resolve(process.cwd(), 'dev.db');
const adapter = new PrismaBetterSqlite3({ url: dbPath });
const prisma = new PrismaClient({ adapter } as any);

async function main() {
  console.log('Seeding database at:', dbPath);
  
  const pricings = [
    { tier: 'Silver', price: 999, benefits: 'Credit Card Leads,Loan Leads,Basic Dashboard,5% Direct Referrals' },
    { tier: 'Gold', price: 1999, benefits: 'Credit Card Leads,Loan Leads,Jobs Search/Listing,8% Direct Referrals,2% Indirect Referrals' },
    { tier: 'Diamond', price: 4999, benefits: 'Credit Card Leads,Loan Leads,Jobs Listings,Insurance Leads,10% Direct Referrals,3% Indirect Referrals,Priority KYC Review' },
    { tier: 'Platinum', price: 9999, benefits: 'Credit Card Leads,Loan Leads,Jobs Listings,Insurance Leads,IT Projects Leads,BPO Services Leads,12% Direct Referrals,5% Indirect Referrals,Dedicated Account Manager' },
  ];

  for (const p of pricings) {
    await (prisma as any).membershipPricing.upsert({
      where: { tier: p.tier },
      update: { price: p.price, benefits: p.benefits },
      create: p,
    });
  }

  const commissions = [
    { serviceType: 'Credit Card', directRate: 0.12, indirectRate: 0.03 },
    { serviceType: 'Loan', directRate: 0.10, indirectRate: 0.02 },
    { serviceType: 'Jobs', directRate: 0.08, indirectRate: 0.015 },
    { serviceType: 'Insurance', directRate: 0.15, indirectRate: 0.04 },
    { serviceType: 'IT Projects', directRate: 0.20, indirectRate: 0.05 },
    { serviceType: 'BPO Services', directRate: 0.18, indirectRate: 0.045 },
  ];

  for (const c of commissions) {
    await (prisma as any).commissionConfig.upsert({
      where: { serviceType: c.serviceType },
      update: { directRate: c.directRate, indirectRate: c.indirectRate },
      create: c,
    });
  }

  console.log('Database seeded successfully!');
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
