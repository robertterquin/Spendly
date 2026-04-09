import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendly/app.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://zqnyccxqalsjiakyvavn.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpxbnljY3hxYWxzamlha3l2YXZuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzU3MzEwOTksImV4cCI6MjA5MTMwNzA5OX0.yc9LaxDAu2MAmSzf9rmSEQEY028pcZu2hgVCJPeQN_g',
  );
  runApp(const ProviderScope(child: SpendlyApp()));
}
