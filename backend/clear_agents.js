const { PrismaClient } = require('@prisma/client');
const { PrismaBetterSqlite3 } = require('@prisma/adapter-better-sqlite3');
const path = require('path');

const dbPath = path.resolve(__dirname, 'dev.db');
const adapter = new PrismaBetterSqlite3({ url: dbPath });
const prisma = new PrismaClient({ adapter });

async function main() {
  console.log('Clearing all agent mock data (agents, leads, transactions, messages, etc.)...');

  // Delete dependent tables first
  await prisma.kycDocument.deleteMany({});
  await prisma.lead.deleteMany({});
  await prisma.transaction.deleteMany({});
  await prisma.message.deleteMany({});
  
  // Set referredById to null on all agents to avoid self-referential constraint issues during delete
  await prisma.agent.updateMany({
    data: {
      referredById: null
    }
  });

  // Delete all agents
  const deleteResult = await prisma.agent.deleteMany({});
  console.log(`Deleted ${deleteResult.count} agents from the database.`);
  console.log('Database agents table cleared successfully!');
}

main()
  .catch(e => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
