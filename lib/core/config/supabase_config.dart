import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  // Get these from your Supabase Dashboard → Settings → API
  static const String supabaseUrl = String.fromEnvironment(
    'https://kmpsaobnpfldwdmajtxo.supabase.co',
    defaultValue: 'https://kmpsaobnpfldwdmajtxo.supabase.co', // Replace with your actual URL
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImttcHNhb2JucGZsZHdkbWFqdHhvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDg3MDExMDAsImV4cCI6MjA2NDI3NzEwMH0.mmca0HbinTSsYTpU49t4NiChO-PAFtbDSTIJ-a_mJ7E',
    defaultValue:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImttcHNhb2JucGZsZHdkbWFqdHhvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDg3MDExMDAsImV4cCI6MjA2NDI3NzEwMH0.mmca0HbinTSsYTpU49t4NiChO-PAFtbDSTIJ-a_mJ7E', // Replace with your actual anon key
  );

  static Future<void> initialize() async {
    try {
      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
        debug: true,
      );
      print('Supabase initialized successfully.');
    } catch (e, stack) {
      print('Failed to initialize Supabase: '
          '\$e\nStack trace: \$stack');
    }
  }

  static SupabaseClient get client => Supabase.instance.client;
  static GoTrueClient get auth => client.auth;
  static RealtimeClient get realtime => client.realtime;
}
