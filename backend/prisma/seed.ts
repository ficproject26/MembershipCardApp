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
    { serviceType: 'Credit Card', silverRate: 1000.0, goldRate: 1500.0, diamondRate: 1800.0, platinumRate: 2000.0 },
    { serviceType: 'Loan', silverRate: 1200.0, goldRate: 1800.0, diamondRate: 2200.0, platinumRate: 2500.0 },
    { serviceType: 'Jobs', silverRate: 400.0, goldRate: 700.0, diamondRate: 900.0, platinumRate: 1000.0 },
    { serviceType: 'Insurance', silverRate: 1500.0, goldRate: 2200.0, diamondRate: 2700.0, platinumRate: 3000.0 },
    { serviceType: 'IT Projects', silverRate: 3000.0, goldRate: 4500.0, diamondRate: 5500.0, platinumRate: 6000.0 },
    { serviceType: 'BPO Services', silverRate: 2500.0, goldRate: 3500.0, diamondRate: 4500.0, platinumRate: 5000.0 },
    { serviceType: 'App Referral', silverRate: 300.0, goldRate: 500.0, diamondRate: 600.0, platinumRate: 700.0 },
    { serviceType: 'Plan Upgrade', silverRate: 500.0, goldRate: 800.0, diamondRate: 1000.0, platinumRate: 1200.0 },
  ];

  for (const c of commissions) {
    await (prisma as any).commissionConfig.upsert({
      where: { serviceType: c.serviceType },
      update: {
        silverRate: c.silverRate,
        goldRate: c.goldRate,
        diamondRate: c.diamondRate,
        platinumRate: c.platinumRate,
      },
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
