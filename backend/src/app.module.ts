import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { TypeOrmModule } from '@nestjs/typeorm';
import { AuthModule } from '@modules/auth/auth.module';
import { UsersModule } from '@modules/users/users.module';
import { PlacesModule } from '@modules/places/places.module';
import { ReviewsModule } from '@modules/reviews/reviews.module';
import { HealthCheckController } from './health-check.controller';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      envFilePath: '.env',
    }),
    TypeOrmModule.forRoot({
      type: 'sqlite',
      database: process.env.DATABASE_PATH || './forkscore.db',
      entities: ['src/**/*.entity.ts'],
      migrations: ['database/migrations/*.ts'],
      synchronize: process.env.NODE_ENV !== 'production',
      logging: process.env.DATABASE_LOGGING === 'true',
    }),
    AuthModule,
    UsersModule,
    PlacesModule,
    ReviewsModule,
  ],
  controllers: [HealthCheckController],
})
export class AppModule {}
