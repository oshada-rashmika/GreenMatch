import { IsString, IsNotEmpty, IsInt, Min, Max, IsOptional, IsObject } from 'class-validator';

export class CreateEvaluationDto {
  @IsString()
  @IsNotEmpty()
  projectId: string;

  @IsString()
  @IsNotEmpty()
  supervisorId: string;

  @IsInt()
  @Min(0)
  @Max(100)
  finalMark: number;

  @IsOptional()
  @IsString()
  feedbackText?: string;

  @IsOptional()
  @IsObject()
  criteriaScores?: Record<string, any>;
}
