// Project

/// Base exception for server-related errors
///
/// Thrown when backend operations fail due to network issues,
/// server errors, or invalid responses from Supabase or external APIs.
class ServerException implements Exception {
  /// Human-readable error message
  final String message;

  /// Optional error code from the server
  final String? code;

  /// Original exception that caused this error (if any)
  final dynamic originalException;

  const ServerException(
    this.message, {
    this.code,
    this.originalException,
  });

  /// Create a ServerException from a [dynamic] error
  ///
  /// Attempts to extract meaningful message and code from various error types.
  factory ServerException.fromError(dynamic error) {
    if (error == null) {
      return const ServerException('Unknown server error occurred');
    }

    // Handle Map-like errors (common in Supabase)
    if (error is Map<String, dynamic>) {
      final message = error['message'] as String? ?? 'Unknown error';
      final code = error['code'] as String?;
      return ServerException(message, code: code);
    }

    // Handle Exception types
    if (error is Exception) {
      final message = error.toString().replaceAll('Exception: ', '');
      return ServerException(message, originalException: error);
    }

    // Handle String errors
    if (error is String) {
      return ServerException(error);
    }

    // Fallback for unknown types
    return ServerException(
      'An unexpected error occurred: ${error.toString()}',
      originalException: error,
    );
  }

  @override
  String toString() {
    if (code != null) {
      return 'ServerException [$code]: $message';
    }
    return 'ServerException: $message';
  }
}

/// Exception thrown when network connectivity issues occur
///
/// Indicates device is offline or server is unreachable.
class NetworkException extends ServerException {
  const NetworkException([
    super.message = 'Network connection failed. Please check your internet connection.',
  ]) : super(code: 'NETWORK_ERROR');
}

/// Exception thrown when authentication fails
///
/// Used for login/signup failures, invalid credentials, or session expiration.
class AuthException extends ServerException {
  const AuthException(
    super.message, {
    super.code = 'AUTH_ERROR',
  });

  /// Create AuthException from Supabase auth error
  factory AuthException.fromSupabaseError(dynamic error) {
    final serverError = ServerException.fromError(error);
    final message = _mapSupabaseAuthError(serverError.message);
    final code = serverError.code;

    return AuthException(message, code: code);
  }

  /// Map Supabase auth error messages to user-friendly Vietnamese messages
  static String _mapSupabaseAuthError(String message) {
    final lowerMessage = message.toLowerCase();

    if (lowerMessage.contains('email already registered') ||
        lowerMessage.contains('user already registered')) {
      return 'Email này đã được đăng ký. Vui lòng sử dụng email khác.';
    }
    if (lowerMessage.contains('invalid login credentials') ||
        lowerMessage.contains('invalid email or password')) {
      return 'Email hoặc mật khẩu không đúng. Vui lòng thử lại.';
    }
    if (lowerMessage.contains('email not confirmed')) {
      return 'Email chưa được xác nhận. Vui lòng kiểm tra hộp thư.';
    }
    if (lowerMessage.contains('invalid email')) {
      return 'Định dạng email không hợp lệ.';
    }
    if (lowerMessage.contains('password too short')) {
      return 'Mật khẩu phải có ít nhất 6 ký tự.';
    }
    if (lowerMessage.contains('weak password')) {
      return 'Mật khẩu quá yếu. Vui lòng sử dụng mật khẩu mạnh hơn.';
    }
    if (lowerMessage.contains('user not found')) {
      return 'Không tìm thấy tài khoản. Vui lòng kiểm tra lại email.';
    }

    return message;
  }
}

/// Exception thrown when API rate limit is exceeded
///
/// Indicates too many requests were made in a short time period.
class RateLimitException extends ServerException {
  const RateLimitException([
    super.message = 'Too many requests. Please try again later.',
  ]) : super(code: 'RATE_LIMIT_EXCEEDED');
}

/// Exception thrown when a request times out
///
/// Indicates server did not respond within the expected time.
class TimeoutException extends ServerException {
  const TimeoutException([
    super.message = 'Request timed out. Please check your connection.',
  ]) : super(code: 'REQUEST_TIMEOUT');
}
