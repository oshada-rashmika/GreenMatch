import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CreateGuidelineDto } from './dto/create-guideline.dto';

@Injectable()
export class GuidelinesService {
  constructor(private readonly prisma: PrismaService) {}

  async createGuideline(createGuidelineDto: CreateGuidelineDto) {
    return this.prisma.guideline.create({
      data: {
        title: createGuidelineDto.title.trim(),
        instructions: createGuidelineDto.instructions.trim(),
        deliverables: createGuidelineDto.deliverables,
        deadline: new Date(createGuidelineDto.deadline),
        moduleId: createGuidelineDto.moduleId,
      },
      include: {
        module: {
          select: {
            moduleCode: true,
            moduleName: true,
          },
        },
      },
    });
  }

  async getGuidelinesByModuleLeader(leaderId: string) {
    return this.prisma.guideline.findMany({
      where: {
        module: {
          moduleLeaderId: leaderId,
        },
      },
      include: {
        module: {
          select: {
            moduleCode: true,
            moduleName: true,
          },
        },
      },
      orderBy: {
        createdAt: 'desc',
      },
    });
  }
}
