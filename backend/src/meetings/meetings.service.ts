import { Injectable, BadRequestException, NotFoundException, Logger } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { Cron, CronExpression } from '@nestjs/schedule';

@Injectable()
export class MeetingsService {
  private readonly logger = new Logger(MeetingsService.name);

  constructor(private prisma: PrismaService) {}

  async scheduleMeeting(supervisorId: string, groupId: string, scheduledDate: Date, windowExpiry: Date, notes?: string) {
    return this.prisma.meeting.create({
      data: {
        scheduledDate: new Date(scheduledDate),
        windowExpiry: new Date(windowExpiry),
        supervisorNotes: notes,
        groupId,
        supervisorId,
        status: 'SCHEDULED',
      }
    });
  }

  async getMyMeetings(studentId: string) {
    return this.prisma.meeting.findMany({
      where: {
        group: {
          members: {
            some: { studentId: studentId }
          }
        }
      },
      select: {
        id: true,
        groupId: true,
        scheduledDate: true,
        windowExpiry: true,
        status: true,
        supervisorNotes: true,
        supervisor: {
          select: { fullName: true }
        }
      },
      orderBy: { scheduledDate: 'desc' }
    });
  }

  async markAttendance(studentId: string, meetingId: string) {
    const meeting = await this.prisma.meeting.findUnique({
      where: { id: meetingId },
      include: {
        group: {
          include: {
            members: true
          }
        }
      }
    });

    if (!meeting) {
      throw new NotFoundException('Meeting not found');
    }

    if (meeting.status !== 'SCHEDULED') {
      throw new BadRequestException(`Meeting cannot be marked attended (Current status: ${meeting.status})`);
    }

    // Verify student is physically part of the group for this meeting
    const isMember = meeting.group.members.some(member => member.studentId === studentId);
    if (!isMember) {
      throw new BadRequestException('You are not a member of the group assigned to this meeting');
    }

    // CRITICAL REQUIREMENT: Strict verification that Date.now() is before windowExpiry
    if (new Date() > new Date(meeting.windowExpiry)) {
      throw new BadRequestException('Attendance window has expired');
    }

    return this.prisma.meeting.update({
      where: { id: meetingId },
      data: { status: 'ATTENDED' }
    });
  }

  // Automatic Cron Job running every hour
  @Cron(CronExpression.EVERY_HOUR)
  async handleMeetingExpirations() {
    this.logger.debug('Running Cron: Checking for expired SCHEDULED meetings...');
    const now = new Date();
    
    // Automatically update meetings where status is 'SCHEDULED' and windowExpiry is in the past
    const result = await this.prisma.meeting.updateMany({
      where: {
        status: 'SCHEDULED',
        windowExpiry: {
          lt: now
        }
      },
      data: {
        status: 'MISSED'
      }
    });

    if (result.count > 0) {
      this.logger.log(`Auto-marked ${result.count} expired meetings as MISSED.`);
    }
  }

  // ───────────────────────────────────────────────
  // MARK-MEETINGS FEATURE (Meeting Days 1-21)
  // ───────────────────────────────────────────────

  async getProjectMeetingMarks(groupId: string, supervisorId: string) {
    return this.prisma.meeting.findMany({
      where: {
        groupId,
        supervisorId,
        meetingNumber: { not: null },
      },
      select: {
        id: true,
        meetingNumber: true,
        scheduledDate: true,
        status: true,
        supervisorNotes: true,
        createdAt: true,
      },
      orderBy: { meetingNumber: 'asc' },
    });
  }

  async markMeetingDay(
    supervisorId: string,
    groupId: string,
    meetingNumber: number,
    meetingDate: Date,
    notes?: string,
  ) {
    // Validate meeting number range
    if (meetingNumber < 1 || meetingNumber > 21) {
      throw new BadRequestException('Meeting number must be between 1 and 21');
    }

    // Check if this meeting number is already marked for this group
    const existing = await this.prisma.meeting.findFirst({
      where: {
        groupId,
        supervisorId,
        meetingNumber,
      },
    });

    if (existing) {
      // Update existing mark
      return this.prisma.meeting.update({
        where: { id: existing.id },
        data: {
          scheduledDate: new Date(meetingDate),
          windowExpiry: new Date(meetingDate), // Same as scheduled for marks
          supervisorNotes: notes,
          status: 'ATTENDED',
        },
      });
    }

    // Create new meeting mark
    return this.prisma.meeting.create({
      data: {
        meetingNumber,
        scheduledDate: new Date(meetingDate),
        windowExpiry: new Date(meetingDate),
        supervisorNotes: notes,
        groupId,
        supervisorId,
        status: 'ATTENDED',
      },
    });
  }

  async unmarkMeetingDay(
    supervisorId: string,
    groupId: string,
    meetingNumber: number,
  ) {
    const existing = await this.prisma.meeting.findFirst({
      where: {
        groupId,
        supervisorId,
        meetingNumber,
      },
    });

    if (!existing) {
      throw new NotFoundException('Meeting mark not found');
    }

    return this.prisma.meeting.delete({
      where: { id: existing.id },
    });
  }
}
