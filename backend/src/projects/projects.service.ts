import {
  BadRequestException,
  Injectable,
  Logger,
  NotFoundException,
} from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { MatchProjectDto } from './dto/match-project.dto';

@Injectable()
export class ProjectsService {
  private readonly logger = new Logger(ProjectsService.name);

  constructor(private prisma: PrismaService) { }

  async submitProposal(
    studentId: string,
    data: {
      title: string;
      abstract: string;
      moduleId: string;
      groupName?: string;
      tagIds?: string[];
      memberStudentIds?: string[];
    },
  ) {
    return this.prisma.project.create({
      data: {
        title: data.title,
        abstract: data.abstract,
        module: { connect: { id: data.moduleId } },
        status: 'PENDING',
        tags: {
          create: data.tagIds?.map((tagId) => ({ tagId })) ?? [],
        },
        group: {
          create: {
            groupName: data.groupName,
            members: {
              create: [
                { studentId: studentId, isLeader: true },
                ...(data.memberStudentIds
                  ?.filter((id) => id !== studentId)
                  .map((id) => ({ studentId: id, isLeader: false })) ?? []),
              ],
            },
          },
        },
      },
    });
  }

  async getPendingAnonymousProjects() {
    return this.prisma.project.findMany({
      where: {
        status: 'PENDING',
      },
      select: {
        id: true,
        title: true,
        abstract: true,
        status: true,
        createdAt: true,
        tags: {
          select: {
            tag: {
              select: {
                id: true,
                name: true,
              },
            },
          },
        },
      },
      orderBy: {
        createdAt: 'desc',
      },
    });
  }

  async getAllProjectsForModuleLeader() {
    return this.prisma.project.findMany({
      select: {
        id: true,
        title: true,
        status: true,
        createdAt: true,
        module: {
          select: {
            moduleCode: true,
            moduleName: true,
          },
        },
        supervisor: {
          select: {
            fullName: true,
          },
        },
        group: {
          select: {
            id: true,
            groupName: true,
          },
        },
      },
      orderBy: {
        createdAt: 'desc',
      },
    });
  }

  async matchProject(
    projectId: string,
    supervisorId: string,
    matchDto: MatchProjectDto,
  ) {
    if (!matchDto.confirmMatch) {
      throw new BadRequestException(
        'confirmMatch must be true to proceed with matching.',
      );
    }

    return this.prisma.$transaction(async (tx) => {
      const project = await tx.project.findUnique({
        where: { id: projectId },
      });

      if (!project) {
        throw new NotFoundException(
          `Project with id "${projectId}" was not found.`,
        );
      }

      if (project.status === 'MATCHED' || project.supervisorId !== null) {
        throw new BadRequestException(
          'This project has already been matched to a supervisor.',
        );
      }

      if (matchDto.message) {
        this.logger.log(
          `Supervisor ${supervisorId} included a message for project ${projectId}: "${matchDto.message}"`,
        );
      }

      return tx.project.update({
        where: { id: projectId },
        data: {
          status: 'MATCHED',
          supervisor: { connect: { id: supervisorId } },
        },
        select: {
          id: true,
          title: true,
          status: true,
          supervisorId: true,
          updatedAt: true,
        },
      });
    });
  }
}
