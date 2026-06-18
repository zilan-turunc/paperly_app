import 'package:supabase_flutter/supabase_flutter.dart';
import 'env.dart';

SupabaseClient get supabase => Supabase.instance.client;

Future<void> initSupabase() async {
  if (!Env.hasSupabase) return;
  await Supabase.initialize(
    url: Env.supabaseUrl,
    // ignore: deprecated_member_use
    anonKey: Env.supabaseAnonKey,
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce,
    ),
  );
}
