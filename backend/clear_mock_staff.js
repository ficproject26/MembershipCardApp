const { PrismaClient } = require('@prisma/client');
const { PrismaBetterSqlite3 } = require('@prisma/adapter-better-sqlite3');
const path = require('path');

const dbPath = path.resolve(__dirname, 'dev.db');
const adapter = new PrismaBetterSqlite3({ url: dbPath });
const prisma = new PrismaClient({ adapter });

async function main() {
  console.log('Cleaning up mock staff members from the database...');

  const keepEmails = [
    'admin@fic.com',
    'cctl@fic.com',
    'loantl@fic.com',
    'kyc1@fic.com',
    'hr@fic.com',
    'itpm@fic.com'
  ];

  // Delete all staff members whose email is not in the keep list
  const deleteResult = await prisma.staff.deleteMany({
    where: {
      email: {
        notIn: keepEmails
      }
    }
  });

  console.log(`Deleted ${deleteResult.count} old mock staff members from the database.`);
  
  // Verify remaining staff
  const remaining = await prisma.staff.findMany();
  console.log('Remaining staff members in database:');
  remaining.forEach(s => console.log(`- ${s.name} (${s.email}) - ${s.role}`));
}

main()
  .catch(e => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
