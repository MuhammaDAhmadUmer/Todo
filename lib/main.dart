import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:api_practice/Provider/task.dart';
import 'package:api_practice/Provider/user.dart';
import 'package:api_practice/utils/app_theme.dart';
import 'package:api_practice/views/splash.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => TaskProvider()),
      ],
      child: MaterialApp(
        title: 'To-Do',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const SplashView(),
      ),
    );
  }
}
