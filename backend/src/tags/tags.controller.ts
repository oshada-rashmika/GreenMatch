import { Controller, Get, Post, Body, UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../auth/guards/roles.guard';
import { Roles } from '../auth/decorators/roles.decorator';
import { Role } from '../auth/enums/role.enum';
import { TagsService } from './tags.service';

@Controller('tags')
@UseGuards(JwtAuthGuard, RolesGuard)
export class TagsController {
  constructor(private readonly tagsService: TagsService) {}

  @Get()
  async getAllTags() {
    return this.tagsService.getAllTags();
  }

  @Post()
  @Roles(Role.MODULE_LEADER)
  async createTag(@Body() body: { name: string }) {
    return this.tagsService.createTag(body.name);
  }
}
