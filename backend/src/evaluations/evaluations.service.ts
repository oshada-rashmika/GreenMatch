import { Injectable, ConflictException, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CreateEvaluationDto } from './dto/create-evaluation.dto';

@Injectable()
export class EvaluationsService {
  constructor(private prisma: PrismaService) { }

  async createEvaluation(createEvaluationDto: CreateEvaluationDto) {
    const { projectId, supervisorId, finalMark, feedbackText, criteriaScores } = createEvaluationDto;

    const project = await this.prisma.project.findUnique({
      where: { id: projectId },
    });

    if (!project) {
      throw new NotFoundException(`Project with ID ${projectId} not found`);
    }

    const supervisor = await this.prisma.supervisor.findUnique({
      where: { id: supervisorId },
    });

    if (!supervisor) {
      throw new NotFoundException(`Supervisor with ID ${supervisorId} not found`);
    }

    const existingEvaluation = await this.prisma.evaluation.findUnique({
      where: { projectId },
    });

    if (existingEvaluation) {
      throw new ConflictException(`An evaluation for project ${projectId} already exists`);
    }

    return this.prisma.evaluation.create({
      data: {
        projectId,
        supervisorId,
        finalMark,
        feedbackText,
        criteriaScores: criteriaScores ?? undefined,
      },
    });
  }
}
