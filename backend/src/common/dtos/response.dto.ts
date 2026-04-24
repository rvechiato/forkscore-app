export class ApiResponse<T = any> {
  status: 'success' | 'error';
  data?: T;
  code?: string;
  message?: string;
  timestamp: Date;
  path?: string;

  constructor(status: 'success' | 'error', data?: T, code?: string, message?: string) {
    this.status = status;
    this.data = data;
    this.code = code;
    this.message = message;
    this.timestamp = new Date();
  }

  static success<T>(data: T, message?: string): ApiResponse<T> {
    return new ApiResponse('success', data, undefined, message);
  }

  static error<T>(code: string, message?: string, data?: T): ApiResponse<T> {
    return new ApiResponse('error', data, code, message);
  }
}
