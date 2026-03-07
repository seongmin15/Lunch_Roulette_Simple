import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('점심 룰렛'),
      ),
      body: const Center(
        child: Text('점심 룰렛 앱에 오신 것을 환영합니다!'),
      ),
    );
  }
}
