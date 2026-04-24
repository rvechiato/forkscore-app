import { DataSourceOptions } from 'typeorm';
import * as path from 'path';

export const getDatabaseConfig = (): DataSourceOptions => {
  const env = process.env.NODE_ENV || 'development';
  const logging = process.env.DATABASE_LOGGING === 'true';

  return {
    type: 'sqlite',
    database: path.join(process.cwd(), 'database.sqlite'),
    entities: [path.join(__dirname, '../modules/**/infra/entities/*.entity{.ts,.js}')],
    migrations: [path.join(__dirname, '../database/migrations/*{.ts,.js}')],
    logging: logging && env === 'development',
    synchronize: env === 'development',
    migrationsRun: true,
  };
};
