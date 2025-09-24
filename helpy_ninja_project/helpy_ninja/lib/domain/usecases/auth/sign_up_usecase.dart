import 'package:injectable/injectable.dart';

import '../../entities/user.dart';
import '../../repositories/i_auth_repository.dart';

/// Use case for user registration
@injectable
class SignUpUseCase {
  final IAuthRepository _authRepository;

  SignUpUseCase(this._authRepository);

  /// Execute sign up with email, password, and name
  Future<User> execute(String email, String password, String name) async {
    // Validate input
    if (email.trim().isEmpty) {
      throw ArgumentError('Email cannot be empty');
    }
    
    if (password.trim().isEmpty) {
      throw ArgumentError('Password cannot be empty');
    }

    if (name.trim().isEmpty) {
      throw ArgumentError('Name cannot be empty');
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

    // Check for strong password (optional but recommended)
    if (!_isStrongPassword(password)) {
      throw ArgumentError('Password must contain at least one uppercase letter, one lowercase letter, and one number');
    }

    // Name validation
    if (name.trim().length < 2) {
      throw ArgumentError('Name must be at least 2 characters long');
    }

    if (name.trim().length > 50) {
      throw ArgumentError('Name must be less than 50 characters');
    }

    // Call repository to perform sign up
    return await _authRepository.signUpWithEmail(
      email.trim(), 
      password, 
      name.trim(),
    );
  }

  /// Check if password meets strength requirements
  bool _isStrongPassword(String password) {
    // At least one uppercase letter
    if (!password.contains(RegExp(r'[A-Z]'))) return false;
    
    // At least one lowercase letter
    if (!password.contains(RegExp(r'[a-z]'))) return false;
    
    // At least one number
    if (!password.contains(RegExp(r'[0-9]'))) return false;
    
    return true;
  }
}