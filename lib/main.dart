import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'my_widget/my_routes.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://oxxsnyhoocpvzebhjweb.supabase.co',
    anonKey: 'sb_secret_ja54pKn7WD4Aog89sHlIrw_qi_8zqS0',
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      routes: AppRoutes.routes,
      initialRoute: AppRoutes.splash,
    );
  }
}

