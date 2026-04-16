import { PrismaClient } from '@prisma/client';
import * as bcrypt from 'bcrypt';

const prisma = new PrismaClient();

async function main() {
  console.log('🌱 Starting database seed...');

  try {
    // Hash the test password
    const hashedPassword = await bcrypt.hash('TestPass123!', 10);

    // Create dummy supervisor
    const supervisor = await prisma.supervisor.upsert({
      where: { email: 'supervisor@test.com' },
      update: {},
      create: {
        email: 'supervisor@test.com',
        staffId: 'SUP-999',
        fullName: 'Test Supervisor',
        passwordHash: hashedPassword,
      },
    });

    console.log('✅ Dummy Supervisor created/updated:');
    console.log(`   Email: ${supervisor.email}`);
    console.log(`   Staff ID: ${supervisor.staffId}`);
    console.log(`   Full Name: ${supervisor.fullName}`);
    console.log(`   ID: ${supervisor.id}`);
    console.log('\n📧 Login credentials for testing:');
    console.log(`   Email: supervisor@test.com`);
    console.log(`   Password: TestPass123!`);
  } catch (error) {
    console.error('❌ Seed failed:', error);
    process.exit(1);
  } finally {
    await prisma.$disconnect();
    console.log('\n✨ Seed completed successfully!');
  }
}

main();
