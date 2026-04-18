import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class ModuleLeaderService {
  constructor(private readonly prisma: PrismaService) {}

  async getOverviewStatistics(moduleLeaderId: string) {
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
      groupName: meeting.group.groupName || 'Unnamed Group',
      projectTitle: meeting.group.project?.title || 'No Project Linked',
      meetingStatus: meeting.status,
      meetingDate: meeting.scheduledDate.toISOString(),
      supervisorName: meeting.supervisor.fullName,
    }));
  }
}
