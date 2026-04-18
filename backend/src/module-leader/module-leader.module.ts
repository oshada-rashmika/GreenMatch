import { Module } from '@nestjs/common';
import { ModuleLeaderController } from './module-leader.controller';
import { ModuleLeaderService } from './module-leader.service';
import { PrismaModule } from '../prisma/prisma.module';

@Module({
  imports: [PrismaModule],
  controllers: [ModuleLeaderController],
  providers: [ModuleLeaderService],
})
export class ModuleLeaderModule {}
