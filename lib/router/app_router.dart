import 'package:flutter/material.dart';
import 'package:aa_doudizhu/presentation/screens/home_screen.dart';
import 'package:aa_doudizhu/presentation/screens/room_screen.dart';
import 'package:aa_doudizhu/presentation/screens/lobby_screen.dart';
import 'package:aa_doudizhu/presentation/screens/shop_screen.dart';
import 'package:aa_doudizhu/presentation/screens/inventory_screen.dart';
import 'package:aa_doudizhu/presentation/screens/leaderboard_screen.dart';
import 'package:aa_doudizhu/presentation/screens/profile_screen.dart';
import 'package:aa_doudizhu/presentation/screens/user_demo_screen.dart';

class AppRouter {
  static Route<dynamic>? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case '/room':
        return MaterialPageRoute(builder: (_) => const RoomScreen());
      case '/lobby':
        return MaterialPageRoute(builder: (_) => const LobbyScreen());
      case '/shop':
        return MaterialPageRoute(builder: (_) => const ShopScreen());
      case '/inventory':
        return MaterialPageRoute(builder: (_) => const InventoryScreen());
      case '/leaderboard':
        return MaterialPageRoute(builder: (_) => const LeaderboardScreen());
      case '/profile':
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      case '/user_demo':
        return MaterialPageRoute(builder: (_) => const UserDemoScreen());
      default:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
    }
  }
}
