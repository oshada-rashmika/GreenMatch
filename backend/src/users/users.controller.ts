import { Controller, Post, Body, Get, UseGuards, Request } from '@nestjs/common';
import { UsersService } from './users.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

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

  @UseGuards(JwtAuthGuard)
  @Get('profile')
  async getProfile(@Request() req: any) {
    return this.usersService.getProfile(req.user.id, req.user.role);
  }
}
