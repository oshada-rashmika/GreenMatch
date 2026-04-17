import { Controller, Post, Get, Body, Param, UseGuards, Request } from '@nestjs/common';
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
}
