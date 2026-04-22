/**
 * Presentation: Controllers de Autenticação
 * 
 * Esta camada apenas recebe requisições HTTP e as passa para a Application.
 * Controllers são thin: validação de DTO, roteamento, respostas HTTP.
 */

import { Controller, Post, Body, HttpCode, BadRequestException } from '@nestjs/common';
import { AuthService } from '../application/auth.service';
import { ILoginRequest, IAuthResponse } from '../domain/auth.types';

class LoginDto {
  email: string;
  password: string;
}

class SignupDto {
  email: string;
  password: string;
  name: string;
}

@Controller('/auth')
export class AuthController {
  constructor(private authService: AuthService) {}

  @Post('/login')
  @HttpCode(200)
  async login(@Body() loginDto: LoginDto): Promise<IAuthResponse> {
    try {
      return await this.authService.login({
        email: loginDto.email,
        password: loginDto.password,
      });
    } catch (error) {
      throw new BadRequestException(error.message);
    }
  }

  @Post('/signup')
  async signup(@Body() signupDto: SignupDto): Promise<IAuthResponse> {
    try {
      return await this.authService.signup(
        signupDto.email,
        signupDto.password,
        signupDto.name,
      );
    } catch (error) {
      throw new BadRequestException(error.message);
    }
  }
}
