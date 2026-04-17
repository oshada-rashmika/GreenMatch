import {
  BadRequestException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class ModulesService {
  constructor(private readonly prisma: PrismaService) {}

  async getAllModules() {
    return this.prisma.module.findMany({
      select: {
        id: true,
        moduleCode: true,
        moduleName: true,
      },
      orderBy: { moduleCode: 'asc' },
    });
  }

  async getAcademicModules(moduleLeaderId: string) {
    const [modules, supervisors] = await Promise.all([
      this.prisma.module.findMany({
        where: { moduleLeaderId },
        select: {
          id: true,
          moduleCode: true,
          moduleName: true,
          academicYear: true,
          batch: true,
          supervisors: {
            select: {
              supervisor: {
                select: {
                  id: true,
                  fullName: true,
                  email: true,
                },
              },
            },
          },
          createdAt: true,
        },
        orderBy: {
          createdAt: 'desc',
        },
      }),
      this.prisma.supervisor.findMany({
        select: {
          id: true,
          fullName: true,
          email: true,
          staffId: true,
        },
        orderBy: { fullName: 'asc' },
      }),
    ]);

    return {
      modules,
      supervisors,
    };
  }

  async createAcademicModule(
    moduleLeaderId: string,
    data: {
      moduleCode: string;
      moduleName: string;
      academicYear: string;
      batch: string;
      milestoneMatchDate?: string;
      milestoneReviewDate?: string;
      milestoneMidtermDate?: string;
      milestoneFinalDate?: string;
      milestoneVivaDate?: string;
    },
  ) {
    const moduleCode = data.moduleCode.trim();
    const moduleName = data.moduleName.trim();
    const academicYear = data.academicYear.trim();
    const batch = data.batch.trim();

    if (!moduleCode || !moduleName || !academicYear || !batch) {
      throw new BadRequestException('All module fields are required.');
    }

    return this.prisma.module.create({
      data: {
        moduleCode,
        moduleName,
        academicYear,
        batch,
        moduleLeaderId,
        milestoneMatchDate: data.milestoneMatchDate ? new Date(data.milestoneMatchDate) : null,
        milestoneReviewDate: data.milestoneReviewDate ? new Date(data.milestoneReviewDate) : null,
        milestoneMidtermDate: data.milestoneMidtermDate ? new Date(data.milestoneMidtermDate) : null,
        milestoneFinalDate: data.milestoneFinalDate ? new Date(data.milestoneFinalDate) : null,
        milestoneVivaDate: data.milestoneVivaDate ? new Date(data.milestoneVivaDate) : null,
      },
      select: {
        id: true,
        moduleCode: true,
        moduleName: true,
        academicYear: true,
        batch: true,
        milestoneMatchDate: true,
        milestoneReviewDate: true,
        milestoneMidtermDate: true,
        milestoneFinalDate: true,
        milestoneVivaDate: true,
        createdAt: true,
      },
    });
  }

  async assignSupervisors(
    moduleLeaderId: string,
    moduleId: string,
    supervisorIds: string[],
  ) {
    const targetModule = await this.prisma.module.findFirst({
      where: {
        id: moduleId,
        moduleLeaderId,
      },
      select: { id: true },
    });

    if (!targetModule) {
      throw new NotFoundException('Module not found for this module leader.');
    }

    const deduplicatedSupervisorIds = [...new Set(supervisorIds)];

    const validSupervisors = await this.prisma.supervisor.findMany({
      where: {
        id: {
          in: deduplicatedSupervisorIds,
        },
      },
      select: { id: true },
    });

    if (deduplicatedSupervisorIds.length != validSupervisors.length) {
      throw new BadRequestException('One or more supervisors are invalid.');
    }

    await this.prisma.$transaction([
      this.prisma.moduleSupervisor.deleteMany({
        where: { moduleId },
      }),
      this.prisma.moduleSupervisor.createMany({
        data: deduplicatedSupervisorIds.map((supervisorId) => ({
          moduleId,
          supervisorId,
        })),
      }),
    ]);

    return this.prisma.module.findUnique({
      where: { id: moduleId },
      select: {
        id: true,
        moduleCode: true,
        moduleName: true,
        academicYear: true,
        batch: true,
        supervisors: {
          select: {
            supervisor: {
              select: {
                id: true,
                fullName: true,
                email: true,
              },
            },
          },
        },
      },
    });
  }
}