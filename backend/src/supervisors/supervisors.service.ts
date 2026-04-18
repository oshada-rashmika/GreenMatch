import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { UpdateOnboardingDto } from './dto/onboarding.dto';

@Injectable()
export class SupervisorsService {
  constructor(private prisma: PrismaService) {}

  async getSupervisorProfile(id: string) {
    const supervisor = await this.prisma.supervisor.findUnique({
      where: { id },
      include: {
        supervisedProjects: {
          select: {
            id: true,
            title: true,
            status: true,
          },
        },
        expertiseTags: {
          include: {
            tag: true,
          },
        },
        meetings: {
          select: {
            id: true,
            status: true,
            scheduledDate: true,
          },
        },
      },
    });

    if (!supervisor) {
      throw new NotFoundException(`Supervisor with ID ${id} not found`);
    }

    // Calculate active projects count
    const activeProjectsCount = supervisor.supervisedProjects.filter(
      (p) => p.status === 'MATCHED',
    ).length;

    return {
      ...supervisor,
      activeProjectsCount,
    };
  }

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

  async getEvaluatedProjects(supervisorId: string) {
    return this.prisma.project.findMany({
      where: {
        supervisorId: supervisorId,
        status: 'MATCHED',
      },
      include: {
        evaluation: true,
        group: {
          include: {
            members: {
              include: {
                student: true,
              },
            },
          },
        },
      },
    });
  }
}
