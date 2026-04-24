import { Controller, Post, Body, HttpCode, HttpStatus } from '@nestjs/common';
import { AuthService } from '../application/auth.service';
import { ApiResponse } from '../../../common/dtos/response.dto';

class RegisterDto {
  email: string;
  password: string;
  name: string;
}

class LoginDto {
  email: string;
  password: string;
}

class RefreshTokenDto {
  refreshToken: string;
}

@Controller('auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  @Post('register')
  @HttpCode(HttpStatus.CREATED)
  async register(@Body() body: RegisterDto) {
    try {
      const result = await this.authService.register(body.email, body.password, body.name);
      return ApiResponse.success(result, 'User registered successfully');
    } catch (error: any) {
      return ApiResponse.error('REGISTRATION_ERROR', error.message);
    }
  }

  @Post('login')
  @HttpCode(HttpStatus.OK)
  async login(@Body() body: LoginDto) {
    try {
      const result = await this.authService.login(body.email, body.password);
      return ApiResponse.success(result, 'Login successful');
    } catch (error: any) {
      return ApiResponse.error('LOGIN_ERROR', error.message);
    }
  }

  @Post('refresh')
  @HttpCode(HttpStatus.OK)
  async refresh(@Body() body: RefreshTokenDto) {
    try {
      const result = await this.authService.refreshTokens(body.refreshToken);
      return ApiResponse.success(result, 'Tokens refreshed successfully');
    } catch (error: any) {
      return ApiResponse.error('REFRESH_ERROR', error.message);
    }
  }
}
