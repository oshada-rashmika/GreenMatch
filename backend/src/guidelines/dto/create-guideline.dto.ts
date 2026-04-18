import {
  ArrayNotEmpty,
  IsArray,
  IsISO8601,
  IsNotEmpty,
  IsString,
} from 'class-validator';

export class CreateGuidelineDto {
  @IsString()
  @IsNotEmpty()
  title: string;

  @IsString()
  @IsNotEmpty()
  instructions: string;

  @IsArray()
  @ArrayNotEmpty()
  @IsString({ each: true })
  deliverables: string[];

  @IsISO8601()
  deadline: string;

  @IsString()
  @IsNotEmpty()
  moduleId: string;
}
