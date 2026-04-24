export class InvalidEmailError extends Error {
  constructor(email: string) {
    super(`Invalid email format: ${email}`);
    this.name = 'InvalidEmailError';
  }
}

export class InvalidPasswordError extends Error {
  constructor(message: string = 'Password does not meet requirements') {
    super(message);
    this.name = 'InvalidPasswordError';
  }
}

export class InvalidNameError extends Error {
  constructor(name: string) {
    super(`Invalid name: ${name}`);
    this.name = 'InvalidNameError';
  }
}

export class UserNotFoundError extends Error {
  constructor(identifier: string) {
    super(`User not found: ${identifier}`);
    this.name = 'UserNotFoundError';
  }
}

export class EmailAlreadyExistsError extends Error {
  constructor(email: string) {
    super(`Email already exists: ${email}`);
    this.name = 'EmailAlreadyExistsError';
  }
}
