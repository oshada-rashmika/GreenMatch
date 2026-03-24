import { Controller, Post, Body, UnauthorizedException, HttpCode, HttpStatus } from '@nestjs/common';
import { AuthService } from './auth.service';
import { Role } from './enums/role.enum';

@Controller('auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  @HttpCode(HttpStatus.OK)
  @Post('student/login')
  async studentLogin(@Body() signInDto: Record<string, any>) {
    const user = await this.authService.validateStudent(signInDto.email, signInDto.password);
    if (!user) {
      throw new UnauthorizedException('Invalid credentials');
    }
    return this.authService.login(user, Role.STUDENT);
  }

  @HttpCode(HttpStatus.OK)
  @Post('supervisor/login')
  async supervisorLogin(@Body() signInDto: Record<string, any>) {
    const user = await this.authService.validateSupervisor(signInDto.email, signInDto.password);
    if (!user) {
      throw new UnauthorizedException('Invalid credentials');
    }
    return this.authService.login(user, Role.SUPERVISOR);
  }

  @HttpCode(HttpStatus.OK)
  @Post('module-leader/login')
  async moduleLeaderLogin(@Body() signInDto: Record<string, any>) {
    const user = await this.authService.validateModuleLeader(signInDto.email, signInDto.password);
    if (!user) {
      throw new UnauthorizedException('Invalid credentials');
    }
    return this.authService.login(user, Role.MODULE_LEADER);
  }
}
