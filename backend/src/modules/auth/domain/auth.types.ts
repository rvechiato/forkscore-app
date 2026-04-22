/**
 * Domain: Autenticação
 * 
 * Esta camada NÃO deve depender de nenhuma tecnologia externa.
 * Regras puras de negócio: validação de credenciais, tokens, etc.
 */

export interface IAuthPayload {
  userId: string;
  email: string;
  iat?: number;
  exp?: number;
}

export interface ILoginRequest {
  email: string;
  password: string;
}

export interface IAuthResponse {
  accessToken: string;
  refreshToken?: string;
  user: {
    id: string;
    email: string;
    name: string;
  };
}

/**
 * Exceções de domínio para autenticação
 */
export class InvalidCredentialsError extends Error {
  constructor() {
    super('Email ou senha inválidos');
    this.name = 'InvalidCredentialsError';
  }
}

export class UserNotFoundError extends Error {
  constructor(email: string) {
    super(`Usuário não encontrado: ${email}`);
    this.name = 'UserNotFoundError';
  }
}

export class WeakPasswordError extends Error {
  constructor() {
    super('Senha fraca. Mínimo 8 caracteres com maiúsculas, minúsculas e números');
    this.name = 'WeakPasswordError';
  }
}
