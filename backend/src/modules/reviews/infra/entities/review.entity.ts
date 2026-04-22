/**
 * Entities para o sistema de avaliação
 * (To be implemented with full validation)
 */

import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn } from 'typeorm';

@Entity('reviews')
export class ReviewEntity {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  userId: string;

  @Column()
  placeId: string;

  @Column({ default: false })
  isJustificationProvided: boolean;

  @CreateDateColumn()
  createdAt: Date;
}

@Entity('review_criteria')
export class ReviewCriteriaEntity {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  reviewId: string;

  @Column()
  criterion: string; // 'sabor' | 'atendimento' | 'custo' | 'infra'

  @Column()
  rating: number; // 0-5

  @Column()
  comment: string; // min 10 chars

  @Column({ default: false })
  isJustified: boolean;

  @CreateDateColumn()
  createdAt: Date;
}
