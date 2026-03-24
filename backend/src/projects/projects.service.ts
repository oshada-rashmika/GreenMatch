import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class ProjectsService {
  constructor(private prisma: PrismaService) {}

  async submitProposal(studentId: string, data: { title: string, abstract: string, moduleId: string, groupName?: string, tagIds?: string[], memberStudentIds?: string[] }) {
    // Create the Project, ProjectGroup, and GroupMembers in a single Prisma nested write.
    // The submitting student is automatically designated as the group leader.
    return this.prisma.project.create({
      data: {
        title: data.title,
        abstract: data.abstract,
        module: { connect: { id: data.moduleId } },
        status: 'PENDING',
        tags: {
          create: data.tagIds?.map(tagId => ({ tagId })) || [],
        },
        group: {
          create: {
            groupName: data.groupName,
            members: {
              create: [
                { studentId: studentId, isLeader: true },
                // Filter out the submitting student if accidentally passed in the array, then map
                ...(data.memberStudentIds?.filter(id => id !== studentId).map(id => ({ studentId: id, isLeader: false })) || [])
              ]
            }
          }
        }
      }
    });
  }

  async getPendingProjectsForSupervisor() {
    return this.prisma.project.findMany({
      where: {
        status: 'PENDING',
      },
      select: {
        id: true,
        title: true,
        abstract: true,
        tags: {
          select: {
            tag: {
              select: {
                id: true,
                name: true,
              }
            }
          }
        }
        // CRITICAL SECURITY CONSTRAINT: 
        // Group, GroupMembers, and Student relations are explicitly omitted 
        // from the standard select to enforce the 'Blind Match' anonymity logic.
      }
    });
  }

  async matchProject(supervisorId: string, projectId: string) {
    // Wrapped in a transaction to prevent race conditions when multiple supervisors
    // attempt to match with the same project simultaneously.
    return this.prisma.$transaction(async (prisma) => {
      const project = await prisma.project.findUnique({ where: { id: projectId } });
      
      if (!project) {
        throw new NotFoundException('Project not found');
      }
      
      if (project.status === 'MATCHED' || project.supervisorId) {
        throw new BadRequestException('Project is already matched to a supervisor');
      }

      return prisma.project.update({
        where: { id: projectId },
        data: {
          status: 'MATCHED',
          supervisorId: supervisorId,
        }
      });
    });
  }
}
