import { Controller, Post, Get, Body, Param, UseGuards, Request } from '@nestjs/common';
import { ProjectsService } from './projects.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../auth/guards/roles.guard';
import { Roles } from '../auth/decorators/roles.decorator';
import { Role } from '../auth/enums/role.enum';
import { MatchProjectDto } from './dto/match-project.dto';

@Controller('projects')
@UseGuards(JwtAuthGuard, RolesGuard)
export class ProjectsController {
  constructor(private readonly projectsService: ProjectsService) { }

  @Post('submit')
  @Roles(Role.STUDENT)
  async submitProposal(@Request() req, @Body() body: Record<string, any>) {
    const studentId = req.user.id;
    return this.projectsService.submitProposal(studentId, {
      title: body.title,
      abstract: body.abstract,
      moduleId: body.moduleId,
      groupName: body.groupName,
      tagIds: body.tagIds,
      memberStudentIds: body.memberStudentIds,
    });
  }

  @Get('anonymous')
  @Roles(Role.SUPERVISOR)
  async getAnonymousFeed() {
    return this.projectsService.getPendingAnonymousProjects();
  }

  @Post(':id/match')
  @Roles(Role.SUPERVISOR)
  async matchProject(
    @Request() req,
    @Param('id') projectId: string,
    @Body() matchDto: MatchProjectDto,
  ) {
    const supervisorId = req.user.id;
    return this.projectsService.matchProject(projectId, supervisorId, matchDto);
  }
}
