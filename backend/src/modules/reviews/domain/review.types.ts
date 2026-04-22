/**
 * Domain: Tipos e Interfaces de Avaliação
 * 
 * 4 CRITÉRIOS OBRIGATÓRIOS (Per Constitution v1.0.0):
 * - Sabor
 * - Atendimento
 * - Custo-benefício / Opções
 * - Infraestrutura
 */

export enum ReviewCriterion {
  SABOR = 'sabor',
  ATENDIMENTO = 'atendimento',
  CUSTO = 'custo',
  INFRA = 'infra',
}

export interface IReviewCriteria {
  id: string;
  reviewId: string;
  criterion: ReviewCriterion;
  rating: number; // 0-5
  comment: string; // min 10 chars
  isJustified: boolean; // true if rating < 3
  createdAt: Date;
}

export interface IReview {
  id: string;
  userId: string;
  placeId: string;
  criteria: IReviewCriteria[];
  createdAt: Date;
  updatedAt: Date;
}

/**
 * Exceções de domínio para avaliações
 */
export class InvalidRatingError extends Error {
  constructor() {
    super('Rating deve estar entre 0 e 5 estrelas');
    this.name = 'InvalidRatingError';
  }
}

export class InvalidCommentError extends Error {
  constructor() {
    super('Comentário deve ter no mínimo 10 caracteres');
    this.name = 'InvalidCommentError';
  }
}

export class MissingJustificationError extends Error {
  constructor() {
    super('Ratings abaixo de 3 estrelas requerem justificativa');
    this.name = 'MissingJustificationError';
  }
}

/**
 * Validadores de domínio
 */
export class ReviewValidator {
  static validateRating(rating: number): void {
    if (rating < 0 || rating > 5 || !Number.isInteger(rating)) {
      throw new InvalidRatingError();
    }
  }

  static validateComment(comment: string): void {
    if (!comment || comment.trim().length < 10) {
      throw new InvalidCommentError();
    }
  }

  static validateJustification(rating: number, isJustified: boolean): void {
    if (rating < 3 && !isJustified) {
      throw new MissingJustificationError();
    }
  }

  static calculateAverageRating(criteria: IReviewCriteria[]): number {
    if (criteria.length === 0) return 0;
    const sum = criteria.reduce((acc, c) => acc + c.rating, 0);
    return sum / criteria.length;
  }
}
