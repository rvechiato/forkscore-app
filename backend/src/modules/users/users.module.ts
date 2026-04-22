/**
 * Módulo de Usuários
 * Responsável por: Criação, atualização, visualização de perfis
 */

import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { UsersService } from './application/users.service';
import { UsersController } from './presentation/users.controller';
import { UserEntity } from './infra/entities/user.entity';

@Module({
  imports: [TypeOrmModule.forFeature([UserEntity])],
  providers: [UsersService],
  controllers: [UsersController],
  exports: [UsersService],
})
export class UsersModule {}
