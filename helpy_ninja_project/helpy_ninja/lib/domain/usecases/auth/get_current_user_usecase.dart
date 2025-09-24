import 'package:injectable/injectable.dart';

import '../../entities/user.dart';
import '../../repositories/i_auth_repository.dart';

/// Use case for getting current authenticated user
@injectable
class GetCurrentUserUseCase {
  final IAuthRepository _authRepository;

  GetCurrentUserUseCase(this._authRepository);

  /// Execute get current user
  Future<User?> execute() async {
    // Check if user is authenticated first
    final isAuthenticated = await _authRepository.isAuthenticated();
    
    if (!isAuthenticated) {
      return null;
    }

    // Get current user from repository
    return await _authRepository.getCurrentUser();
  }
}