import { Controller, Post, Body } from '@nestjs/common';
import { EvaluationsService } from './evaluations.service';
import { CreateEvaluationDto } from './dto/create-evaluation.dto';

@Controller('api/evaluations')
export class EvaluationsController {
  constructor(private readonly evaluationsService: EvaluationsService) {}

  @Post()
  async createEvaluation(@Body() createEvaluationDto: CreateEvaluationDto) {
    return this.evaluationsService.createEvaluation(createEvaluationDto);
  }
}
