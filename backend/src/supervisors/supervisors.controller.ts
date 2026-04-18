import { Controller, Get, Patch, Param, Body } from '@nestjs/common';
import { SupervisorsService } from './supervisors.service';
import { UpdateOnboardingDto } from './dto/onboarding.dto';

@Controller('api/supervisors')
export class SupervisorsController {
  constructor(private readonly supervisorsService: SupervisorsService) {}

  @Get(':id')
  async getSupervisorProfile(@Param('id') id: string) {
    return this.supervisorsService.getSupervisorProfile(id);
  }

  @Get(':id/evaluated-projects')
  async getEvaluatedProjects(@Param('id') id: string) {
    return this.supervisorsService.getEvaluatedProjects(id);
  }

  @Patch(':id/onboarding')
  async completeOnboarding(
    @Param('id') id: string,
    @Body() updateOnboardingDto: UpdateOnboardingDto,
  ) {
    return this.supervisorsService.updateOnboarding(id, updateOnboardingDto);
  }
}
