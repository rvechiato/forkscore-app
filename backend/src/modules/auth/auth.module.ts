import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { JwtModule } from '@nestjs/jwt';
import { PassportModule } from '@nestjs/passport';
import { UserEntity } from '../users/infra/entities/user.entity';
import { AuthService } from './application/auth.service';
import { AuthController } from './presentation/auth.controller';
import { JwtStrategy } from './infra/strategies/jwt.strategy';
import { BcryptHasher } from './infra/hash/bcrypt.hasher';
import { TokenProvider } from './infra/token/token.provider';
import { UserRepository } from '../users/infra/repositories/user.repository';
import { USER_REPOSITORY } from '../users/domain/ports/user.repository';
import { IdGenerator } from '../shared/infra/id.generator';
import { getAuthConfig } from '../../config/auth.config';

@Module({
  imports: [
    TypeOrmModule.forFeature([UserEntity]),
    PassportModule,
    JwtModule.register({
      secret: getAuthConfig().jwtSecret,
      signOptions: { expiresIn: '24h' },
    }),
  ],
  providers: [
    AuthService,
    JwtStrategy,
    BcryptHasher,
    TokenProvider,
    IdGenerator,
    {
      provide: USER_REPOSITORY,
      useClass: UserRepository,
    },
  ],
  controllers: [AuthController],
  exports: [AuthService, BcryptHasher, TokenProvider],
})
export class AuthModule {}
