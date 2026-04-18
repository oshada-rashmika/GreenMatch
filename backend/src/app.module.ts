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
import { TagsModule } from './tags/tags.module';
import { ModuleLeaderModule } from './module-leader/module-leader.module';
import { SupervisorsModule } from './supervisors/supervisors.module';

@Module({
  imports: [
    ScheduleModule.forRoot(),
    PrismaModule, 
    AuthModule, 
    ProjectsModule,
    MeetingsModule,
    UsersModule,
    ModulesModule,
    TagsModule,
    ModuleLeaderModule,
    SupervisorsModule,
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
