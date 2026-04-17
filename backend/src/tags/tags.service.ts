import { ConflictException, BadRequestException, Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class TagsService {
  constructor(private readonly prisma: PrismaService) {}

  async getAllTags() {
    return this.prisma.tag.findMany({
      select: {
        id: true,
        name: true,
      },
      orderBy: { name: 'asc' },
    });
  }

  async createTag(name: string) {
    if (!name || name.trim() === '') {
      throw new BadRequestException('Tag name cannot be empty');
    }

    const trimmedName = name.trim();
    const existing = await this.prisma.tag.findUnique({
      where: { name: trimmedName },
    });

    if (existing) {
      throw new ConflictException(`Tag "${trimmedName}" already exists`);
    }

    return this.prisma.tag.create({
      data: { name: trimmedName },
    });
  }
}
