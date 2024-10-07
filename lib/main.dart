import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:my_schedule/auth/auth.dart';
import 'package:my_schedule/box/boxes.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: "https://vuphmshlifryuczfphoz.supabase.co",
    anonKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZ1cGhtc2hsaWZyeXVjemZwaG96Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3Mjc2NTUzNDcsImV4cCI6MjA0MzIzMTM0N30.jcGi4KNAo5KNZCrT2wdbNOPy3WcCG6uWRzjVlFZ0RpA",
  );
  await Hive.initFlutter();


  // BOXES
  await Hive.initFlutter();
  boxUserCredentials = await Hive.openBox<String>('userIdBox');

  runApp(const MyApp());
}

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return  const MaterialApp(
      debugShowCheckedModeBanner: false,
      home:  AuthScreen()
    );
  }
}