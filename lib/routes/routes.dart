import 'package:flutter/material.dart';
import '../screens/home_screen.dart';
import '../screens/active_users_screen.dart';
import '../screens/statistics_screen.dart';

class AppRoutes {
  static const String home = '/';
  static const String activeUsers = '/active-users';
  static const String statistics = '/statistics';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      home: (context) => const HomeScreen(),
      activeUsers: (context) => const ActiveUsersScreen(),
      statistics: (context) => const StatisticsScreen(),
    };
  }
}
