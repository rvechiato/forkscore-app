import { Controller, Get } from '@nestjs/common';

@Controller('/health')
export class HealthCheckController {
  @Get()
  healthCheck() {
    return {
      status: 'ok',
      timestamp: new Date().toISOString(),
      service: 'ForkScore API v0.1.0',
      environment: process.env.NODE_ENV || 'development',
    };
  }
}
