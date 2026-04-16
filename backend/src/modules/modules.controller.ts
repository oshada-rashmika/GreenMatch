import {
  Body,
  Controller,
  Get,
  Param,
  Post,
  Request,
  UseGuards,
} from '@nestjs/common';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../auth/guards/roles.guard';
import { Roles } from '../auth/decorators/roles.decorator';
import { Role } from '../auth/enums/role.enum';
import { ModulesService } from './modules.service';

@Controller('modules')
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles(Role.MODULE_LEADER)
export class ModulesController {
  constructor(private readonly modulesService: ModulesService) {}

  @Get()
  async getAcademicModules(@Request() req) {
    return this.modulesService.getAcademicModules(req.user.id);
  }

  @Post()
  async createAcademicModule(@Request() req, @Body() body: Record<string, any>) {
    return this.modulesService.createAcademicModule(req.user.id, {
      moduleCode: body.moduleCode,
      moduleName: body.moduleName,
      academicYear: body.academicYear,
      batch: body.batch,
    });
  }

  @Post(':id/supervisors')
  async assignSupervisors(
    @Request() req,
    @Param('id') moduleId: string,
    @Body() body: Record<string, any>,
  ) {
    return this.modulesService.assignSupervisors(
      req.user.id,
      moduleId,
      Array.isArray(body.supervisorIds)
          ? body.supervisorIds
          : [],
    );
  }
}