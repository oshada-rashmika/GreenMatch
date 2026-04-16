import { Module } from '@nestjs/common';
import { ScheduleModule } from '@nestjs/schedule';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { PrismaModule } from './prisma/prisma.module';
import { AuthModule } from './auth/auth.module';
import { ProjectsModule } from './projects/projects.module';
import { MeetingsModule } from './meetings/meetings.module';
import { UsersModule } from './users/users.module';
import { ModulesModule } from './modules/modules.module';

@Module({
  imports: [
    ScheduleModule.forRoot(),
    PrismaModule, 
    AuthModule, 
    ProjectsModule,
    MeetingsModule,
    UsersModule,
    ModulesModule,
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
