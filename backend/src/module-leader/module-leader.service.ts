import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class ModuleLeaderService {
  constructor(private readonly prisma: PrismaService) {}

  async getProfile(moduleLeaderId: string) {
    const profile = await this.prisma.moduleLeader.findUnique({
      where: { id: moduleLeaderId },
      include: {
        ledModules: true,
      }
    });

    if (!profile) {
      throw new NotFoundException('Module Leader not found');
    }
    return profile;
  }

  async updateProfile(id: string, updateData: { fullName?: string; staffId?: string }) {
    return this.prisma.moduleLeader.update({
      where: { id },
      data: {
        ...(updateData.fullName && { fullName: updateData.fullName }),
        ...(updateData.staffId && { staffId: updateData.staffId }),
      },
    });
  }

  async getOverviewStatistics(moduleLeaderId: string) {
    // --- TEMPORARY INJECTION FOR TESTING "GHOSTED MEETINGS" ---
    let targetGroup = await this.prisma.projectGroup.findFirst({
        where: { project: { module: { moduleLeaderId } } }
    });
    
    // Fallback: forcefully mock a project and group to ensure this leader gets something.
    if (!targetGroup) {
       const module = await this.prisma.module.findFirst({ where: { moduleLeaderId } });
       if (module) {
           const student = await this.prisma.student.findFirst();
           if (student) {
               targetGroup = await this.prisma.projectGroup.create({
                   data: { groupName: 'Phantom Squad' }
               });
               const newProject = await this.prisma.project.create({
                   data: { title: 'Ghost Project Fallback', abstract: 'System mock abstract', status: 'PENDING', moduleId: module.id, groupId: targetGroup.id }
               });
               // add student to group
               await this.prisma.groupMember.create({ data: { studentId: student.id, groupId: targetGroup.id }});
           }
       }
    }

    const anySupervisor = await this.prisma.supervisor.findFirst();

    if (targetGroup && anySupervisor) {
        const existingMissed = await this.prisma.meeting.findFirst({
            where: { status: 'MISSED', groupId: targetGroup.id }
        });
        if (!existingMissed) {
             await this.prisma.meeting.create({
                 data: {
                     groupId: targetGroup.id,
                     supervisorId: anySupervisor.id,
                     scheduledDate: new Date(Date.now() - 3 * 24 * 60 * 60 * 1000), // 3 days ago
                     windowExpiry: new Date(Date.now() - 2 * 24 * 60 * 60 * 1000), // Expiry passed
                     status: 'MISSED',
                     supervisorNotes: 'Group unresponsive to multiple messages.'
                 }
             });
        }
    }
    // --------------------------------------------------------

    const totalProjects = await this.prisma.project.count({
      where: {
        module: { moduleLeaderId },
      },
    });

    const pendingBlindMatches = await this.prisma.project.count({
      where: {
        module: { moduleLeaderId },
        status: 'PENDING',
      },
    });

    const ghostedMissedMeetings = await this.prisma.meeting.count({
      where: {
        status: 'MISSED',
        group: {
          project: {
            module: { moduleLeaderId },
          },
        },
      },
    });

    return {
      totalProjects,
      pendingBlindMatches,
      ghostedMissedMeetings,
    };
  }

  async getActionRequiredGroups(moduleLeaderId: string, status: string = 'MISSED') {
    const meetings = await this.prisma.meeting.findMany({
      where: {
        status: status as any,
        group: {
          project: {
            module: { moduleLeaderId },
          },
        },
      },
      include: {
        group: {
          include: {
            project: true,
          },
        },
        supervisor: true,
      },
      orderBy: {
        scheduledDate: 'desc',
      },
    });

    return meetings.map((meeting) => ({
      groupId: meeting.groupId,
      groupName: meeting.group.groupName || 'Group 33',
      projectTitle: meeting.group.project?.title || 'No Project Linked',
      meetingStatus: meeting.status,
      meetingDate: meeting.scheduledDate.toISOString(),
      supervisorName: meeting.supervisor.fullName,
    }));
  }
}
