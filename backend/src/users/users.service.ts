import { Injectable, ConflictException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import * as bcrypt from 'bcrypt';

@Injectable()
export class UsersService {
  constructor(private prisma: PrismaService) {}

  async registerStudent(data: Record<string, any>) {
    // Duplicate entry guard
    const existing = await this.prisma.student.findFirst({
      where: {
        OR: [{ email: data.email }, { studentId: data.studentId }]
      }
    });
    if (existing) {
      throw new ConflictException('A Student with this email or student ID already exists.');
    }

    // Securely hash the password
    const passwordHash = await bcrypt.hash(data.password, 10);
    const { password, ...createData } = data;
    
    // Save to DB and return the profile securely (excluding passwordHash)
    return this.prisma.student.create({
      data: {
        email: createData.email,
        studentId: createData.studentId,
        fullName: createData.fullName,
        degree: createData.degree,
        passwordHash,
      },
      select: { id: true, email: true, studentId: true, fullName: true, degree: true, createdAt: true }
    });
  }

  async registerSupervisor(data: Record<string, any>) {
    // Duplicate entry guard
    const existing = await this.prisma.supervisor.findFirst({
      where: {
        OR: [{ email: data.email }, { staffId: data.staffId }]
      }
    });
    if (existing) {
      throw new ConflictException('A Supervisor with this email or staff ID already exists.');
    }

    // Securely hash the password
    const passwordHash = await bcrypt.hash(data.password, 10);
    const { password, ...createData } = data;
    
    // Save to DB and return the profile securely
    return this.prisma.supervisor.create({
      data: {
        email: createData.email,
        staffId: createData.staffId,
        fullName: createData.fullName,
        passwordHash,
      },
      select: { id: true, email: true, staffId: true, fullName: true, createdAt: true }
    });
  }

  async registerModuleLeader(data: Record<string, any>) {
    // Duplicate entry guard
    const existing = await this.prisma.moduleLeader.findFirst({
      where: {
        OR: [{ email: data.email }, { staffId: data.staffId }]
      }
    });
    if (existing) {
      throw new ConflictException('A ModuleLeader with this email or staff ID already exists.');
    }

    // Securely hash the password
    const passwordHash = await bcrypt.hash(data.password, 10);
    const { password, ...createData } = data;
    
    // Save to DB and return the profile securely
    return this.prisma.moduleLeader.create({
      data: {
        email: createData.email,
        staffId: createData.staffId,
        fullName: createData.fullName,
        passwordHash,
      },
      select: { id: true, email: true, staffId: true, fullName: true, createdAt: true }
    });
  }
  async getProfile(userId: string, role: string) {
    if (role === 'STUDENT') {
      return this.prisma.student.findUnique({
        where: { id: userId },
        select: { id: true, email: true, studentId: true, fullName: true, degree: true, createdAt: true }
      });
    } else if (role === 'SUPERVISOR') {
      return this.prisma.supervisor.findUnique({
        where: { id: userId },
        select: { id: true, email: true, staffId: true, fullName: true, createdAt: true }
      });
    } else if (role === 'MODULE_LEADER') {
      return this.prisma.moduleLeader.findUnique({
        where: { id: userId },
        select: { id: true, email: true, staffId: true, fullName: true, createdAt: true }
      });
    }
    throw new Error('Invalid role');
  }
}
