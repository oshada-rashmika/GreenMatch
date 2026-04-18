import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { UpdateOnboardingDto } from './dto/onboarding.dto';

@Injectable()
export class SupervisorsService {
  constructor(private prisma: PrismaService) {}

  async updateOnboarding(id: string, updateOnboardingDto: UpdateOnboardingDto) {
    const supervisor = await this.prisma.supervisor.findUnique({
      where: { id },
    });

    if (!supervisor) {
      throw new NotFoundException(`Supervisor with ID ${id} not found`);
    }

    return this.prisma.supervisor.update({
      where: { id },
      data: {
        specifications: updateOnboardingDto.specifications,
        capacityLimit: updateOnboardingDto.capacityLimit,
        isFirstLogin: false,
      },
    });
  }
}
