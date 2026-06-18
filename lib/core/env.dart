class Env {
  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL', defaultValue: '');
  static const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');
  static const openAiApiKey = String.fromEnvironment('OPENAI_API_KEY', defaultValue: '');
  static const googleWebClientId = String.fromEnvironment('GOOGLE_WEB_CLIENT_ID', defaultValue: '');
  static const googleIosClientId = String.fromEnvironment('GOOGLE_IOS_CLIENT_ID', defaultValue: '');

  static bool get hasSupabase => supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
  static bool get hasOpenAi => openAiApiKey.isNotEmpty;
  static bool get hasGoogle => googleWebClientId.isNotEmpty;
}
