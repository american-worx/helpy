import 'package:injectable/injectable.dart';

import '../../entities/user.dart';
import '../../repositories/i_auth_repository.dart';

/// Use case for user sign in
@injectable
class SignInUseCase {
  final IAuthRepository _authRepository;

  SignInUseCase(this._authRepository);

  /// Execute sign in with email and password
  Future<User> execute(String email, String password) async {
    // Validate input
    if (email.trim().isEmpty) {
      throw ArgumentError('Email cannot be empty');
    }
    
    if (password.trim().isEmpty) {
      throw ArgumentError('Password cannot be empty');
    }

    // Basic email format validation
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email.trim())) {
      throw ArgumentError('Please enter a valid email address');
    }

    // Password strength validation
    if (password.length < 6) {
      throw ArgumentError('Password must be at least 6 characters long');
    }

    // Call repository to perform sign in
    return await _authRepository.signInWithEmail(email.trim(), password);
  }
}