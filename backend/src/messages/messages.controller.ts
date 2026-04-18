import { Controller, Post, Get, Delete, Param, Body } from '@nestjs/common';
import { MessagesService } from './messages.service';
import { CreateMessageDto } from './dto/create-message.dto';

@Controller('api/messages')
export class MessagesController {
  constructor(private readonly messagesService: MessagesService) {}

  @Post()
  async createMessage(@Body() createMessageDto: CreateMessageDto) {
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
