import 'package:flutter/material.dart';
import 'package:lunch_roulette_app/app/router.dart';
import 'package:lunch_roulette_app/app/theme.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: '점심 룰렛',
      theme: appTheme,
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
