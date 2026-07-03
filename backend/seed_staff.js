const { PrismaClient } = require('@prisma/client');
const bcrypt = require('bcrypt');

const prisma = new PrismaClient();

async function main() {
  console.log('Seeding staff members...');

  const staffList = [
    { name: 'Admin User', email: 'admin@fic.com', phoneNumber: '1234567890', role: 'admin' },
    { name: 'Credit Card Team Lead', email: 'cctl@fic.com', phoneNumber: '1122334455', role: 'creditCardTL' },
    { name: 'Loan Team Lead', email: 'loantl@fic.com', phoneNumber: '2233445566', role: 'loanTL' },
    { name: 'KYC Staff 1', email: 'kyc1@fic.com', phoneNumber: '3344556677', role: 'kycDepartment' },
    { name: 'HR Manager', email: 'hr@fic.com', phoneNumber: '4455667788', role: 'hr' },
    { name: 'IT Project Manager', email: 'itpm@fic.com', phoneNumber: '5566778899', role: 'itProjectManager' },
  ];

  for (const staff of staffList) {
    const password = await bcrypt.hash('password123', 10);
    
    // Check if exists
    const existing = await prisma.staff.findUnique({ where: { email: staff.email } });
    if (!existing) {
      await prisma.staff.create({
        data: {
          name: staff.name,
          email: staff.email,
          phoneNumber: staff.phoneNumber,
          role: staff.role,
          password: password,
        }
      });
      console.log(`Created staff: ${staff.name} (${staff.role})`);
    } else {
      console.log(`Staff already exists: ${staff.name}`);
    }
  }
}

main()
  .catch(e => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
