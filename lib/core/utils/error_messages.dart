/// Utility class for parsing and translating error messages to Vietnamese
///
/// This class provides methods to convert Supabase authentication errors
/// and other common errors into user-friendly Vietnamese messages.
class ErrorMessages {
  ErrorMessages._();

  /// Parses Supabase auth error messages and returns Vietnamese translation
  ///
  /// Common Supabase auth errors:
  /// - 'Invalid login credentials' - Wrong email/password
  /// - 'Email not confirmed' - User hasn't verified email
  /// - 'User already registered' - Email already exists
  /// - 'Password should be at least 6 characters' - Weak password
  /// - 'Unable to validate email address: invalid format' - Bad email format
  /// - 'Email rate limit exceeded' - Too many requests
  /// - 'For security purposes, you can only request this once every 60 seconds'
  static String parseSupabaseError(String errorMessage) {
    final lowerMessage = errorMessage.toLowerCase();

    // Login errors
    if (lowerMessage.contains('invalid login credentials') ||
        lowerMessage.contains('invalid credentials')) {
      return 'Email hoặc mật khẩu không chính xác';
    }

    // Email confirmation
    if (lowerMessage.contains('email not confirmed') ||
        lowerMessage.contains('email is not confirmed')) {
      return 'Vui lòng xác nhận email trước khi đăng nhập. Kiểm tra hộp thư của bạn';
    }

    // User already exists
    if (lowerMessage.contains('user already registered') ||
        lowerMessage.contains('already been registered') ||
        lowerMessage.contains('already exists')) {
      return 'Email đã được sử dụng. Vui lòng sử dụng email khác hoặc đăng nhập';
    }

    // Password too weak
    if (lowerMessage.contains('password should be at least') ||
        lowerMessage.contains('password is too weak') ||
        lowerMessage.contains('password must be')) {
      return 'Mật khẩu phải có ít nhất 6 ký tự';
    }

    // Invalid email format
    if (lowerMessage.contains('invalid email') ||
        lowerMessage.contains('unable to validate email') ||
        lowerMessage.contains('invalid format')) {
      return 'Email không hợp lệ';
    }

    // Rate limiting
    if (lowerMessage.contains('rate limit') ||
        lowerMessage.contains('too many requests') ||
        lowerMessage.contains('request this once every')) {
      return 'Bạn đã thử quá nhiều lần. Vui lòng đợi một phút rồi thử lại';
    }

    // Network/Connection errors
    if (lowerMessage.contains('network') ||
        lowerMessage.contains('connection') ||
        lowerMessage.contains('timeout') ||
        lowerMessage.contains('socket')) {
      return 'Lỗi kết nối mạng. Vui lòng kiểm tra internet và thử lại';
    }

    // Session expired
    if (lowerMessage.contains('session') ||
        lowerMessage.contains('token') ||
        lowerMessage.contains('expired')) {
      return 'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại';
    }

    // Server errors
    if (lowerMessage.contains('server error') ||
        lowerMessage.contains('internal error') ||
        lowerMessage.contains('500')) {
      return 'Lỗi máy chủ. Vui lòng thử lại sau';
    }

    // Default fallback - return original message if no match
    // This helps with debugging while still showing something to user
    if (errorMessage.isNotEmpty) {
      return 'Đã xảy ra lỗi: $errorMessage';
    }

    return 'Đã xảy ra lỗi không xác định. Vui lòng thử lại';
  }

  /// Parses any exception and returns Vietnamese error message
  static String parseException(dynamic exception) {
    if (exception == null) {
      return 'Đã xảy ra lỗi không xác định';
    }

    final message = exception.toString();

    // Remove common exception prefixes for cleaner parsing
    String cleanMessage = message
        .replaceFirst('Exception: ', '')
        .replaceFirst('AuthException: ', '')
        .replaceFirst('ServerException: ', '')
        .replaceFirst('AppAuthException: ', '');

    return parseSupabaseError(cleanMessage);
  }
}
