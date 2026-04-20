import { Controller, Get, Patch, Body, Query, Request, UseGuards } from '@nestjs/common';
import { ModuleLeaderService } from './module-leader.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../auth/guards/roles.guard';
import { Roles } from '../auth/decorators/roles.decorator';
import { Role } from '../auth/enums/role.enum';

@Controller('module-leader')
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles(Role.MODULE_LEADER)
export class ModuleLeaderController {
  constructor(private readonly moduleLeaderService: ModuleLeaderService) {}

  @Get('profile')
  async getProfile(@Request() req) {
    return this.moduleLeaderService.getProfile(req.user.id);
  }

  @Patch('profile')
  async updateProfile(@Request() req, @Body() updateData: { fullName?: string; staffId?: string }) {
    return this.moduleLeaderService.updateProfile(req.user.id, updateData);
  }

  @Get('overview/statistics')
  async getOverviewStatistics(@Request() req) {
    return this.moduleLeaderService.getOverviewStatistics(req.user.id);
  }

  @Get('overview/action-required')
  async getActionRequiredGroups(@Request() req, @Query('status') status: string) {
    return this.moduleLeaderService.getActionRequiredGroups(
      req.user.id,
      status || 'MISSED',
    );
  }
}
