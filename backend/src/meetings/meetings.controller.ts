import { Controller, Post, Get, Delete, Body, Param, Query, UseGuards, Request } from '@nestjs/common';
import { MeetingsService } from './meetings.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../auth/guards/roles.guard';
import { Roles } from '../auth/decorators/roles.decorator';
import { Role } from '../auth/enums/role.enum';

@Controller('meetings')
@UseGuards(JwtAuthGuard, RolesGuard)
export class MeetingsController {
  constructor(private readonly meetingsService: MeetingsService) {}

  @Post('schedule')
  @Roles(Role.SUPERVISOR)
  async scheduleMeeting(@Request() req, @Body() body: Record<string, any>) {
    const supervisorId = req.user.id;
    return this.meetingsService.scheduleMeeting(
      supervisorId,
      body.groupId,
      body.scheduledDate as Date,
      body.windowExpiry as Date,
      body.notes
    );
  }

  @Get('my-meetings')
  @Roles(Role.STUDENT)
  async getMyMeetings(@Request() req) {
    return this.meetingsService.getMyMeetings(req.user.id);
  }

  @Post(':id/attend')
  @Roles(Role.STUDENT)
  async markAttendance(@Request() req, @Param('id') meetingId: string) {
    const studentId = req.user.id;
    return this.meetingsService.markAttendance(studentId, meetingId);
  }

  // ───────────────────────────────────────────────
  // MARK-MEETINGS FEATURE (Meeting Days 1-21)
  // ───────────────────────────────────────────────

  @Get('marks/:groupId')
  @Roles(Role.SUPERVISOR)
  async getProjectMeetingMarks(
    @Request() req,
    @Param('groupId') groupId: string,
  ) {
    const supervisorId = req.user.id;
    return this.meetingsService.getProjectMeetingMarks(groupId, supervisorId);
  }

  @Post('marks/:groupId')
  @Roles(Role.SUPERVISOR)
  async markMeetingDay(
    @Request() req,
    @Param('groupId') groupId: string,
    @Body() body: { meetingNumber: number; meetingDate: string; notes?: string },
  ) {
    const supervisorId = req.user.id;
    return this.meetingsService.markMeetingDay(
      supervisorId,
      groupId,
      body.meetingNumber,
      new Date(body.meetingDate),
      body.notes,
    );
  }

  @Delete('marks/:groupId/:meetingNumber')
  @Roles(Role.SUPERVISOR)
  async unmarkMeetingDay(
    @Request() req,
    @Param('groupId') groupId: string,
    @Param('meetingNumber') meetingNumber: string,
  ) {
    const supervisorId = req.user.id;
    return this.meetingsService.unmarkMeetingDay(
      supervisorId,
      groupId,
      parseInt(meetingNumber, 10),
    );
  }
}
