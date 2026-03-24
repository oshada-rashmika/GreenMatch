import { Controller, Post, Body } from '@nestjs/common';
import { UsersService } from './users.service';

@Controller('users')
export class UsersController {
  constructor(private readonly usersService: UsersService) {}

  // Intentionally omitting @UseGuards() to keep these endpoints public for registration
  @Post('register/student')
  async registerStudent(@Body() body: Record<string, any>) {
    return this.usersService.registerStudent(body);
  }

  @Post('register/supervisor')
  async registerSupervisor(@Body() body: Record<string, any>) {
    return this.usersService.registerSupervisor(body);
  }

  @Post('register/module-leader')
  async registerModuleLeader(@Body() body: Record<string, any>) {
    return this.usersService.registerModuleLeader(body);
  }
}
