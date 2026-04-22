/**
 * Módulo de Locais
 * Responsável por: Cadastro, busca, atualização de restaurantes/cafés
 */

import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { PlacesService } from './application/places.service';
import { PlacesController } from './presentation/places.controller';
import { PlaceEntity } from './infra/entities/place.entity';

@Module({
  imports: [TypeOrmModule.forFeature([PlaceEntity])],
  providers: [PlacesService],
  controllers: [PlacesController],
})
export class PlacesModule {}
