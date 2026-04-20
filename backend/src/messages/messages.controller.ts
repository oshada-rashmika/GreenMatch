import { Controller, Post, Get, Delete, Param, Body, UseGuards, Request } from '@nestjs/common';
import { MessagesService } from './messages.service';
import { CreateMessageDto } from './dto/create-message.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@UseGuards(JwtAuthGuard)
@Controller('api/messages')
export class MessagesController {
  constructor(private readonly messagesService: MessagesService) {}

  @Post()
  async createMessage(@Request() req, @Body() createMessageDto: CreateMessageDto) {
    // Override whatever the client sends with their true token ID
    createMessageDto.senderId = req.user.id;
    return this.messagesService.createMessage(createMessageDto);
  }

  @Get('project/:projectId')
  async getProjectMessages(@Param('projectId') projectId: string) {
    return this.messagesService.getProjectMessages(projectId);
  }

  @Delete(':messageId')
  async deleteMessage(@Param('messageId') messageId: string) {
    return this.messagesService.deleteMessage(messageId);
  }
}
