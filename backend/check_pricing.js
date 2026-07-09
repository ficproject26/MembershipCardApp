const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

async function main() {
  try {
    const pricing = await prisma.membershipPricing.findMany();
    console.log('PRICING IN DB:', JSON.stringify(pricing, null, 2));
  } catch (err) {
    console.error('Error fetching pricing:', err);
  } finally {
    await prisma.$disconnect();
  }
}
main();
