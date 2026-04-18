import {
  IsISO8601,
  IsNotEmpty,
  IsNotEmptyObject,
  IsObject,
  IsString,
} from 'class-validator';

export class CreateGuidelineDto {
  @IsString()
  @IsNotEmpty()
  title: string;

  @IsString()
  @IsNotEmpty()
  instructions: string;

  @IsObject()
  @IsNotEmptyObject()
  deliverables: Record<string, string>;

  @IsISO8601()
  deadline: string;

  @IsString()
  @IsNotEmpty()
  moduleId: string;
}
