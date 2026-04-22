/**
 * Módulo de Avaliações
 * Responsável por: Criação, edição, visualização de reviews com critérios
 */

import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ReviewsService } from './application/reviews.service';
import { ReviewsController } from './presentation/reviews.controller';
import { ReviewEntity } from './infra/entities/review.entity';
import { ReviewCriteriaEntity } from './infra/entities/review-criteria.entity';

@Module({
  imports: [TypeOrmModule.forFeature([ReviewEntity, ReviewCriteriaEntity])],
  providers: [ReviewsService],
  controllers: [ReviewsController],
})
export class ReviewsModule {}
