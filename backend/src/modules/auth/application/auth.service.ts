import { Injectable, Inject } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { ConflictException, UnauthorizedException } from '../../../common/exceptions/domain.exception';
import { BcryptHasher } from '../hash/bcrypt.hasher';
import { TokenProvider, TokenPair } from '../token/token.provider';
import { IUserRepository, USER_REPOSITORY } from '../../users/domain/ports/user.repository';
import { UserEntity } from '../../users/infra/entities/user.entity';
import { IdGenerator } from '../../shared/infra/id.generator';

@Injectable()
export class AuthService {
  constructor(
    @Inject(USER_REPOSITORY)
    private readonly userRepository: IUserRepository,
    private readonly hasher: BcryptHasher,
    private readonly tokenProvider: TokenProvider,
    private readonly idGenerator: IdGenerator,
  ) {}

  async register(email: string, password: string, name: string): Promise<TokenPair & { userId: string }> {
    // Check if user already exists
    const existingUser = await this.userRepository.findByEmail(email);
    if (existingUser) {
      throw new ConflictException(`Email ${email} already registered`);
    }

    // Create new user
    const userId = this.idGenerator.generate();
    const passwordHash = await this.hasher.hash(password);

    const user = new UserEntity();
    user.id = userId;
    user.email = email;
    user.passwordHash = passwordHash;
    user.name = name;

    await this.userRepository.save(user);

    const tokens = this.tokenProvider.generateTokens(userId, email);
    return { userId, ...tokens };
  }

  async login(email: string, password: string): Promise<TokenPair & { userId: string }> {
    const user = await this.userRepository.findByEmail(email);
    if (!user) {
      throw new UnauthorizedException('Invalid email or password');
    }

    const isPasswordValid = await this.hasher.compare(password, user.passwordHash);
    if (!isPasswordValid) {
      throw new UnauthorizedException('Invalid email or password');
    }

    const tokens = this.tokenProvider.generateTokens(user.id, user.email);
    return { userId: user.id, ...tokens };
  }

  async refreshTokens(refreshToken: string): Promise<TokenPair> {
    const payload = this.tokenProvider.verifyRefreshToken(refreshToken);
    if (!payload) {
      throw new UnauthorizedException('Invalid refresh token');
    }

    const user = await this.userRepository.findById(payload.userId);
    if (!user) {
      throw new UnauthorizedException('User not found');
    }

    return this.tokenProvider.generateTokens(user.id, user.email);
  }
}
