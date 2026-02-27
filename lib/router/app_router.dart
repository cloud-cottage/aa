import 'package:flutter/material.dart';
import 'package:aa_doudizhu/presentation/screens/home_screen.dart';
import 'package:aa_doudizhu/presentation/screens/room_screen.dart';
import 'package:aa_doudizhu/presentation/screens/lobby_screen.dart';

class AppRouter {
  static Route<dynamic>? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case '/room':
        return MaterialPageRoute(builder: (_) => const RoomScreen());
      case '/lobby':
        return MaterialPageRoute(builder: (_) => const LobbyScreen());
      default:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
    }
  }
}
