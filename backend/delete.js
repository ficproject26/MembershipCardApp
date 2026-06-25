const { PrismaClient } = require('@prisma/client');
const { PrismaBetterSqlite3 } = require('@prisma/adapter-better-sqlite3');
const path = require('path');

const dbPath = path.resolve(__dirname, 'dev.db');
const adapter = new PrismaBetterSqlite3({ url: dbPath });
const prisma = new PrismaClient({ adapter });

async function deleteMocks() {
  await prisma.agent.deleteMany({
    where: {
      email: { in: ['john@fic.com', 'jane@fic.com'] }
    }
  });
  console.log('Mock users deleted');
}

deleteMocks()
  .catch(console.error)
  .finally(() => prisma.$disconnect());
