import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/env.dart';

final authStateProvider = StreamProvider<AuthState?>((ref) {
  if (!Env.hasSupabase) return Stream.value(null);
  return Supabase.instance.client.auth.onAuthStateChange;
});

final currentUserProvider = Provider<User?>((ref) {
  if (!Env.hasSupabase) return null;
  return Supabase.instance.client.auth.currentUser;
});

class AuthNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> signInWithEmail(String email, String password) async {
    if (!Env.hasSupabase) throw Exception('Auth not configured');
    await Supabase.instance.client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signUpWithEmail(String email, String password) async {
    if (!Env.hasSupabase) throw Exception('Auth not configured');
    await Supabase.instance.client.auth.signUp(
      email: email,
      password: password,
    );
  }

  Future<void> signInWithGoogle() async {
    if (!Env.hasSupabase) throw Exception('Auth not configured');
    if (!Env.hasGoogle) throw Exception('Google sign-in not configured');

    final googleSignIn = GoogleSignIn(
      clientId: Env.googleIosClientId.isNotEmpty ? Env.googleIosClientId : null,
      serverClientId: Env.googleWebClientId,
    );

    final account = await googleSignIn.signIn();
    if (account == null) throw Exception('Sign in cancelled');

    final auth = await account.authentication;
    if (auth.idToken == null) throw Exception('No ID token received');

    await Supabase.instance.client.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: auth.idToken!,
      accessToken: auth.accessToken,
    );
  }

  Future<void> resetPassword(String email) async {
    if (!Env.hasSupabase) throw Exception('Auth not configured');
    await Supabase.instance.client.auth.resetPasswordForEmail(email);
  }

  Future<void> signOut() async {
    if (!Env.hasSupabase) return;
    await Supabase.instance.client.auth.signOut();
  }
}

final authNotifierProvider =
    AsyncNotifierProvider<AuthNotifier, void>(AuthNotifier.new);
