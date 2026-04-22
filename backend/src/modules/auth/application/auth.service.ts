/**
 * Application: Serviço de Autenticação
 * 
 * Esta camada orquestra as regras de domínio.
 * Coordena entre domínio e infraestrutura (repositórios, JWT, etc.)
 */

import { Injectable } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcrypt';
import { Repository } from 'typeorm';
import { InjectRepository } from '@nestjs/typeorm';
import { UserEntity } from '@modules/users/infra/entities/user.entity';
import {
  ILoginRequest,
  IAuthResponse,
  InvalidCredentialsError,
  UserNotFoundError,
  WeakPasswordError,
} from '../domain/auth.types';

@Injectable()
export class AuthService {
  constructor(
    @InjectRepository(UserEntity)
    private usersRepository: Repository<UserEntity>,
    private jwtService: JwtService,
  ) {}

  /**
   * Efetua login do usuário
   * @param loginRequest Email e senha
   * @returns Token JWT e dados do usuário
   */
  async login(loginRequest: ILoginRequest): Promise<IAuthResponse> {
    const { email, password } = loginRequest;

    // Busca usuário no repositório
    const user = await this.usersRepository.findOne({ where: { email } });
    if (!user) {
      throw new UserNotFoundError(email);
    }

    // Valida senha
    const isPasswordValid = await bcrypt.compare(password, user.passwordHash);
    if (!isPasswordValid) {
      throw new InvalidCredentialsError();
    }

    // Gera JWT
    const accessToken = this.jwtService.sign({
      userId: user.id,
      email: user.email,
    });

    return {
      accessToken,
      user: {
        id: user.id,
        email: user.email,
        name: user.name,
      },
    };
  }

  /**
   * Registra novo usuário
   * @param email Email único
   * @param password Senha em plain text (será hasheada)
   * @param name Nome completo
   * @returns Dados do usuário criado com token
   */
  async signup(email: string, password: string, name: string): Promise<IAuthResponse> {
    // Valida força da senha
    this.validatePasswordStrength(password);

    // Verifica se email já existe
    const existingUser = await this.usersRepository.findOne({ where: { email } });
    if (existingUser) {
      throw new Error('Email já registrado');
    }

    // Hash da senha
    const hashedPassword = await bcrypt.hash(password, 10);

    // Cria novo usuário
    const newUser = this.usersRepository.create({
      email,
      passwordHash: hashedPassword,
      name,
    });

    const savedUser = await this.usersRepository.save(newUser);

    // Gera JWT
    const accessToken = this.jwtService.sign({
      userId: savedUser.id,
      email: savedUser.email,
    });

    return {
      accessToken,
      user: {
        id: savedUser.id,
        email: savedUser.email,
        name: savedUser.name,
      },
    };
  }

  /**
   * Valida força da senha conforme regras de domínio
   */
  private validatePasswordStrength(password: string): void {
    if (password.length < 8) {
      throw new WeakPasswordError();
    }

    const hasUppercase = /[A-Z]/.test(password);
    const hasLowercase = /[a-z]/.test(password);
    const hasNumber = /[0-9]/.test(password);

    if (!hasUppercase || !hasLowercase || !hasNumber) {
      throw new WeakPasswordError();
    }
  }

  /**
   * Valida JWT e retorna payload
   */
  validateToken(token: string) {
    try {
      return this.jwtService.verify(token);
    } catch (error) {
      throw new Error('Token inválido ou expirado');
    }
  }
}
