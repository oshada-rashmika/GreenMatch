import { BadRequestException, Injectable } from '@nestjs/common';
import { Prisma } from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';
import { CreateGuidelineDto } from './dto/create-guideline.dto';

@Injectable()
export class GuidelinesService {
  constructor(private readonly prisma: PrismaService) {}

  async createGuideline(createGuidelineDto: CreateGuidelineDto) {
    const sanitizedDeliverables = Object.entries(
      createGuidelineDto.deliverables ?? {},
    ).reduce<Record<string, string>>((acc, [deliverableName, structure]) => {
      const cleanName = deliverableName.trim();
      const cleanStructure = String(structure ?? '').trim();

      if (cleanName.length > 0 && cleanStructure.length > 0) {
        acc[cleanName] = cleanStructure;
      }

      return acc;
    }, {});

    if (Object.keys(sanitizedDeliverables).length === 0) {
      throw new BadRequestException(
        'At least one deliverable with structure details is required.',
      );
    }

    return this.prisma.guideline.create({
      data: {
        title: createGuidelineDto.title.trim(),
        instructions: createGuidelineDto.instructions.trim(),
        deliverables:
          sanitizedDeliverables as unknown as Prisma.InputJsonValue,
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
