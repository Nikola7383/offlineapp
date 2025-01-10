import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../verification/token_encryption.dart';
import 'verification_state.dart';

final verificationProvider =
    StateNotifierProvider<VerificationNotifier, VerificationState>((ref) {
  return VerificationNotifier();
});

class VerificationNotifier extends StateNotifier<VerificationState> {
  VerificationNotifier() : super(const VerificationState()) {
    _initializeConnectivity();
  }

  final _encryption = TokenEncryption();
  final _connectivity = Connectivity();

  Future<void> _initializeConnectivity() async {
    final connectivityResult = await _connectivity.checkConnectivity();
    _updateConnectivityState(connectivityResult);

    _connectivity.onConnectivityChanged.listen(_updateConnectivityState);
  }

  void _updateConnectivityState(ConnectivityResult result) {
    state = state.copyWith(
      isOffline: result == ConnectivityResult.none,
    );
  }

  Future<void> generateToken({
    required String context,
    Duration validity = const Duration(minutes: 5),
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final token = await _encryption.generateToken(
        context: context,
        validity: validity,
      );

      state = state.copyWith(
        isLoading: false,
        lastVerificationTime: DateTime.now(),
      );

      return token;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  Future<void> verifyToken(String tokenData) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final isValid = await _encryption.verifyToken(tokenData);

      state = state.copyWith(
        isLoading: false,
        isVerified: isValid,
        lastVerificationTime: isValid ? DateTime.now() : null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }
}
