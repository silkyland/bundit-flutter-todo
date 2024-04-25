import 'package:flutter/material.dart';
import 'package:layout_example/screens/my_homepage.dart';

Route<dynamic>? onRouteGenerator(RouteSettings settings) {
  final Map<String, dynamic>? params = settings.arguments as Map<String, dynamic>?;
  switch (settings.name) {
    case '/':
      return MaterialPageRoute(builder: (context) => const MyHomePage(title: 'Flutter Demo Home Page'));
    default:
      return MaterialPageRoute(builder: (context) => const MyHomePage(title: 'Flutter Demo Home Page'));
  }
}
