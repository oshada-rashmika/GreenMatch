import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CreateMessageDto } from './dto/create-message.dto';
import { MessageSenderType } from '@prisma/client';

@Injectable()
export class MessagesService {
  constructor(private prisma: PrismaService) {}

  async createMessage(createMessageDto: CreateMessageDto) {
    const { projectId, content, senderType, senderId, senderName } = createMessageDto;

    // Verify project exists
    const project = await this.prisma.project.findUnique({
      where: { id: projectId },
    });

    if (!project) {
      throw new NotFoundException(`Project with ID ${projectId} not found`);
    }

    // Create message
    const message = await this.prisma.message.create({
      data: {
        projectId,
        content,
        senderType: senderType as MessageSenderType,
        senderName,
        studentId: senderType === 'STUDENT' ? senderId : undefined,
        supervisorId: senderType === 'SUPERVISOR' ? senderId : undefined,
      },
      include: {
        student: {
          select: { id: true, fullName: true, email: true },
        },
        supervisor: {
          select: { id: true, fullName: true, email: true },
        },
      },
    });

    return message;
  }

  async getProjectMessages(projectId: string) {
    // Verify project exists
    const project = await this.prisma.project.findUnique({
      where: { id: projectId },
    });

    if (!project) {
      throw new NotFoundException(`Project with ID ${projectId} not found`);
    }

    const messages = await this.prisma.message.findMany({
      where: { projectId },
      include: {
        student: {
          select: { id: true, fullName: true, email: true },
        },
        supervisor: {
          select: { id: true, fullName: true, email: true },
        },
      },
      orderBy: { createdAt: 'asc' },
    });

    return messages;
  }

  async deleteMessage(messageId: string) {
    const message = await this.prisma.message.findUnique({
      where: { id: messageId },
    });

    if (!message) {
      throw new NotFoundException(`Message with ID ${messageId} not found`);
    }

    return this.prisma.message.delete({
      where: { id: messageId },
    });
  }
}
