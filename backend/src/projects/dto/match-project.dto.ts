import {
  IsBoolean,
  IsNotEmpty,
  IsOptional,
  IsString,
  MaxLength,
} from 'class-validator';

export class MatchProjectDto {
  @IsBoolean()
  @IsNotEmpty()
  confirmMatch: boolean;

  @IsString()
  @IsOptional()
  @MaxLength(500)
  message?: string;
}
