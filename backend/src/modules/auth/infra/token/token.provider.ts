import { Injectable } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { BcryptHasher } from '../hash/bcrypt.hasher';
import { IdGenerator } from '../../shared/infra/id.generator';
import { getAuthConfig } from '../../../config/auth.config';

export interface TokenPair {
  accessToken: string;
  refreshToken: string;
}

@Injectable()
export class TokenProvider {
  constructor(
    private readonly jwtService: JwtService,
    private readonly bcryptHasher: BcryptHasher,
    private readonly idGenerator: IdGenerator,
  ) {}

  generateTokens(userId: string, email: string): TokenPair {
    const authConfig = getAuthConfig();

    const accessToken = this.jwtService.sign(
      { sub: userId, email },
      {
        expiresIn: `${authConfig.jwtExpirationHours}h`,
      },
    );

    const refreshToken = this.jwtService.sign(
      { sub: userId, type: 'refresh' },
      {
        expiresIn: `${authConfig.jwtRefreshExpirationDays}d`,
      },
    );

    return { accessToken, refreshToken };
  }

  verifyRefreshToken(token: string): { userId: string } | null {
    try {
      const payload = this.jwtService.verify(token) as any;
      if (payload.type !== 'refresh') {
        return null;
      }
      return { userId: payload.sub };
    } catch {
      return null;
    }
  }
}
