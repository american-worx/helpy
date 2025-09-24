import 'package:injectable/injectable.dart';

import '../../repositories/i_auth_repository.dart';

/// Use case for user sign out
@injectable
class SignOutUseCase {
  final IAuthRepository _authRepository;

  SignOutUseCase(this._authRepository);

  /// Execute sign out
  Future<void> execute() async {
    // Call repository to perform sign out
    await _authRepository.signOut();
  }
}