import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:aa_doudizhu/presentation/screens/home_screen.dart';
import 'package:aa_doudizhu/presentation/screens/user_demo_screen.dart';
import 'package:aa_doudizhu/presentation/screens/game_screen_simple.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/game',
        builder: (context, state) => const GameScreen(),
      ),
      GoRoute(
        path: '/user_demo',
        builder: (context, state) => const UserDemoScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('页面未找到: ${state.uri}'),
      ),
    ),
  );
}
