import 'dotenv/config';
import { PrismaClient } from '@prisma/client';
import { PrismaPg } from '@prisma/adapter-pg';
import { Pool } from 'pg';
import * as bcrypt from 'bcrypt';

const connectionString = process.env.DATABASE_URL;

if (!connectionString) {
  throw new Error('DATABASE_URL environment variable is not set');
}

const pool = new Pool({ connectionString });
const adapter = new PrismaPg(pool);
const prisma = new PrismaClient({ adapter });

async function main() {
  console.log('🌱 Starting database seed...');

  try {
    // Hash the shared test password
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

    // Create dummy admin using the Supervisor table because the schema has no Admin model.
    const admin = await prisma.supervisor.upsert({
      where: { email: 'admin@test.com' },
      update: {},
      create: {
        email: 'admin@test.com',
        staffId: 'ADM-001',
        fullName: 'Test Admin',
        passwordHash: hashedPassword,
      },
    });

    console.log('\n✅ Dummy Admin created/updated:');
    console.log(`   Email: ${admin.email}`);
    console.log(`   Staff ID: ${admin.staffId}`);
    console.log(`   Full Name: ${admin.fullName}`);
    console.log(`   ID: ${admin.id}`);
    console.log('\n📧 Admin login credentials for testing:');
    console.log(`   Email: admin@test.com`);
    console.log(`   Password: TestPass123!`);

    // Create dummy module leader
    const moduleLeader = await prisma.moduleLeader.upsert({
      where: { email: 'leader@test.com' },
      update: {},
      create: {
        email: 'leader@test.com',
        staffId: 'LEAD-001',
        fullName: 'Test Module Leader',
        passwordHash: hashedPassword,
      },
    });

    console.log('\n✅ Dummy Module Leader created/updated:');
    console.log(`   Email: ${moduleLeader.email}`);
    console.log(`   Staff ID: ${moduleLeader.staffId}`);
    console.log(`   Full Name: ${moduleLeader.fullName}`);
    console.log(`   ID: ${moduleLeader.id}`);
    console.log('\n📧 Module leader login credentials for testing:');
    console.log(`   Email: leader@test.com`);
    console.log(`   Password: TestPass123!`);

    // Create dummy student
    const student = await prisma.student.upsert({
      where: { email: 'student@test.com' },
      update: {},
      create: {
        email: 'student@test.com',
        studentId: 'STU-001',
        fullName: 'Test Student',
        degree: 'BSc Computer Science',
        passwordHash: hashedPassword,
      },
    });

    console.log('\n✅ Dummy Student created/updated:');
    console.log(`   Email: ${student.email}`);
    console.log(`   Student ID: ${student.studentId}`);
    console.log(`   Full Name: ${student.fullName}`);
    console.log(`   Degree: ${student.degree}`);
    console.log(`   ID: ${student.id}`);
    console.log('\n📧 Student login credentials for testing:');
    console.log(`   Email: student@test.com`);
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
