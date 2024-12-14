import 'package:flutter/material.dart';
import 'package:notes_app/notes_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://ptmgtvqxpvirgjjcxmhc.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InB0bWd0dnF4cHZpcmdqamN4bWhjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzI5NTM2ODIsImV4cCI6MjA0ODUyOTY4Mn0.Bh5MIwjPqyr7gvN4wM-Zo6kDhVCY_dRH9Awfh1Gfavo',
  );
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: NotesPage(),
      debugShowCheckedModeBanner: false
    );
  }
}
