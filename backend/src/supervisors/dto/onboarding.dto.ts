import { IsArray, IsNumber, IsString } from 'class-validator';

export class UpdateOnboardingDto {
  @IsArray()
  @IsString({ each: true })
  specifications: string[];

  @IsNumber()
  capacityLimit: number;
}
