import { Controller, Patch, Param, Body } from '@nestjs/common';
import { SupervisorsService } from './supervisors.service';
import { UpdateOnboardingDto } from './dto/onboarding.dto';

@Controller('api/supervisors')
export class SupervisorsController {
  constructor(private readonly supervisorsService: SupervisorsService) {}

  @Patch(':id/onboarding')
  async completeOnboarding(
    @Param('id') id: string,
    @Body() updateOnboardingDto: UpdateOnboardingDto,
  ) {
    return this.supervisorsService.updateOnboarding(id, updateOnboardingDto);
  }
}
