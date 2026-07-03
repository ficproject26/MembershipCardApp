const { PrismaClient } = require('@prisma/client');
const bcrypt = require('bcrypt');

const prisma = new PrismaClient();

async function main() {
  console.log('Seeding agents with Pending KYC...');

  const password = await bcrypt.hash('password123', 10);

  const agents = [
    {
      name: 'Rajesh Kumar',
      email: 'rajesh@gmail.com',
      phoneNumber: '9876543212',
      agentCode: 'FIC8821',
      membership: 'Gold',
      kycStatus: 'Pending',
      aadhaarNumber: '1234-5678-9012',
      panNumber: 'ABCDE1234F',
      bankAccountNumber: '9182736455',
      bankIfscCode: 'SBIN0001234',
      bankAccountName: 'Rajesh Kumar',
      photoUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=150&q=80',
    },
    {
      name: 'Priya Sharma',
      email: 'priya@gmail.com',
      phoneNumber: '8765432109',
      agentCode: 'FIC4329',
      membership: 'Platinum',
      kycStatus: 'Pending',
      aadhaarNumber: '9876-5432-1098',
      panNumber: 'WXYZ9876A',
      bankAccountNumber: '1092837465',
      bankIfscCode: 'HDFC0000123',
      bankAccountName: 'Priya Sharma',
      photoUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=150&q=80',
    },
  ];

  for (const agent of agents) {
    const existing = await prisma.agent.findUnique({ where: { email: agent.email } });
    if (!existing) {
      await prisma.agent.create({
        data: {
          ...agent,
          password: password,
          walletBalance: 0.0,
          totalEarnings: 0.0,
        }
      });
      console.log(`Created agent: ${agent.name} with Pending KYC`);
    } else {
      // Update existing to Pending KYC
      await prisma.agent.update({
        where: { email: agent.email },
        data: {
          kycStatus: 'Pending',
          aadhaarNumber: agent.aadhaarNumber,
          panNumber: agent.panNumber,
          bankAccountNumber: agent.bankAccountNumber,
          bankIfscCode: agent.bankIfscCode,
          bankAccountName: agent.bankAccountName,
          photoUrl: agent.photoUrl,
        }
      });
      console.log(`Updated agent: ${agent.name} to Pending KYC`);
    }
  }

  console.log('Finished seeding agents.');
}

main()
  .catch(e => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
