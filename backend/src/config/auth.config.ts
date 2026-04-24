export interface AuthConfig {
  jwtSecret: string;
  jwtExpirationHours: number;
  jwtRefreshExpirationDays: number;
}

export const getAuthConfig = (): AuthConfig => {
  return {
    jwtSecret: process.env.JWT_SECRET || 'your-secret-key',
    jwtExpirationHours: parseInt(process.env.JWT_EXPIRATION_HOURS || '24', 10),
    jwtRefreshExpirationDays: parseInt(process.env.JWT_REFRESH_TOKEN_EXPIRATION_DAYS || '7', 10),
  };
};
