const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

async function main() {
  // Find a group to attach a meeting to
  const group = await prisma.group.findFirst({
    include: {
      project: { include: { module: true } }
    }
  });

  if (!group) {
    console.log("No group found. Cannot create ghosted meeting.");
    return;
  }

  // Find a supervisor
  const supervisor = await prisma.supervisor.findFirst();

  if (!supervisor) {
    console.log("No supervisor found.");
    return;
  }

  // Create a ghosted meeting
  const meeting = await prisma.meeting.create({
    data: {
      groupId: group.id,
      supervisorId: supervisor.id,
      scheduledDate: new Date(Date.now() - 7 * 24 * 60 * 60 * 1000), // 1 week ago
      status: 'MISSED',
      type: 'MILESTONE_1',
      actionItems: 'Student failed to show up',
    }
  });

  console.log("Successfully created a MISSED meeting!", meeting);
}

main()
  .catch(e => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
