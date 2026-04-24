export abstract class DomainException extends Error {
  abstract code: string;
  abstract statusCode: number;

  constructor(message: string) {
    super(message);
    Object.setPrototypeOf(this, new.target.prototype);
  }
}

export class ValidationException extends DomainException {
  code = 'VALIDATION_ERROR';
  statusCode = 400;

  constructor(message: string) {
    super(message);
    Object.setPrototypeOf(this, ValidationException.prototype);
  }
}

export class NotFoundException extends DomainException {
  code = 'NOT_FOUND';
  statusCode = 404;

  constructor(message: string) {
    super(message);
    Object.setPrototypeOf(this, NotFoundException.prototype);
  }
}

export class UnauthorizedException extends DomainException {
  code = 'UNAUTHORIZED';
  statusCode = 401;

  constructor(message: string) {
    super(message);
    Object.setPrototypeOf(this, UnauthorizedException.prototype);
  }
}

export class ForbiddenException extends DomainException {
  code = 'FORBIDDEN';
  statusCode = 403;

  constructor(message: string) {
    super(message);
    Object.setPrototypeOf(this, ForbiddenException.prototype);
  }
}

export class ConflictException extends DomainException {
  code = 'CONFLICT';
  statusCode = 409;

  constructor(message: string) {
    super(message);
    Object.setPrototypeOf(this, ConflictException.prototype);
  }
}
