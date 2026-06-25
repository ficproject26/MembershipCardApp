"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
Object.defineProperty(exports, "__esModule", { value: true });
const client_1 = require("@prisma/client");
const adapter_better_sqlite3_1 = require("@prisma/adapter-better-sqlite3");
const path = __importStar(require("path"));
const dbPath = path.resolve(process.cwd(), 'dev.db');
const adapter = new adapter_better_sqlite3_1.PrismaBetterSqlite3({ url: dbPath });
const prisma = new client_1.PrismaClient({ adapter });
async function main() {
    console.log('Seeding database at:', dbPath);
    const pricings = [
        { tier: 'Silver', price: 999, benefits: 'Credit Card Leads,Loan Leads,Basic Dashboard,5% Direct Referrals' },
        { tier: 'Gold', price: 1999, benefits: 'Credit Card Leads,Loan Leads,Jobs Search/Listing,8% Direct Referrals,2% Indirect Referrals' },
        { tier: 'Diamond', price: 4999, benefits: 'Credit Card Leads,Loan Leads,Jobs Listings,Insurance Leads,10% Direct Referrals,3% Indirect Referrals,Priority KYC Review' },
        { tier: 'Platinum', price: 9999, benefits: 'Credit Card Leads,Loan Leads,Jobs Listings,Insurance Leads,IT Projects Leads,BPO Services Leads,12% Direct Referrals,5% Indirect Referrals,Dedicated Account Manager' },
    ];
    for (const p of pricings) {
        await prisma.membershipPricing.upsert({
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
        await prisma.commissionConfig.upsert({
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
//# sourceMappingURL=seed.js.map