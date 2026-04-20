import {
  Body,
  Controller,
  Get,
  Param,
  Post,
  UseGuards,
  UsePipes,
  ValidationPipe,
} from '@nestjs/common';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../auth/guards/roles.guard';
import { Roles } from '../auth/decorators/roles.decorator';
import { Role } from '../auth/enums/role.enum';
import { GuidelinesService } from './guidelines.service';
import { CreateGuidelineDto } from './dto/create-guideline.dto';

@Controller('api')
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles(Role.MODULE_LEADER, Role.STUDENT, Role.SUPERVISOR)
export class GuidelinesController {
  constructor(private readonly guidelinesService: GuidelinesService) {}

  @Post('guidelines')
  @UsePipes(
    new ValidationPipe({
      whitelist: true,
      forbidNonWhitelisted: true,
    }),
  )
  async createGuideline(@Body() createGuidelineDto: CreateGuidelineDto) {
    return this.guidelinesService.createGuideline(createGuidelineDto);
  }

  @Get('module-leaders/:leaderId/guidelines')
  @Roles(Role.MODULE_LEADER)
  async getGuidelinesByModuleLeader(@Param('leaderId') leaderId: string) {
    return this.guidelinesService.getGuidelinesByModuleLeader(leaderId);
  }

  @Get('students/guidelines')
  @Roles(Role.STUDENT, Role.SUPERVISOR)
  async getGuidelinesForStudents() {
    return this.guidelinesService.getAllGuidelines();
  }
}
