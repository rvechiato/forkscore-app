/**
 * Infrastructure: Estratégia JWT para Passport
 * 
 * Esta camada implementa portas (interfaces) definidas no domínio.
 * Aqui vai toda a complexidade técnica: JWT, bcrypt, banco de dados, etc.
 */

import { Injectable } from '@nestjs/common';
import { PassportStrategy } from '@nestjs/passport';
import { ExtractJwt, Strategy } from 'passport-jwt';
import { IAuthPayload } from '../../domain/auth.types';

@Injectable()
export class JwtStrategy extends PassportStrategy(Strategy) {
  constructor() {
    super({
      jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
      ignoreExpiration: false,
      secretOrKey: process.env.JWT_SECRET || 'your-secret-key',
    });
  }

  validate(payload: IAuthPayload) {
    return { userId: payload.userId, email: payload.email };
  }
}
