class ForgotPasswordRequest {
  final String email;

  ForgotPasswordRequest({required this.email});

  Map<String, dynamic> toJson() => {'email': email};
}

class VerifyCodeRequest {
  final String email;
  final int otp;

  VerifyCodeRequest({required this.email, required this.otp});

  Map<String, dynamic> toJson() => {'email': email, 'otp': otp};
}

class ResetPasswordRequest {
  final String email;
  final int otp;
  final String newPassword;
  final String newPasswordConfirmation;

  ResetPasswordRequest({
    required this.email,
    required this.otp,
    required this.newPassword,
    required this.newPasswordConfirmation,
  });

  Map<String, dynamic> toJson() => {
    'email': email,
    'otp': otp,
    'new_password': newPassword,
    'new_password_confirmation': newPasswordConfirmation,
  };
}

class ApiResponse {
  final int status;
  final String message;
  final dynamic data;

  ApiResponse({
    required this.status,
    required this.message,
    this.data,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(
      status: json['status'] ?? 0,
      message: json['message'] ?? '',
      data: json['data'],
    );
  }
}