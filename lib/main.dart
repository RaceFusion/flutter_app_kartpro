import 'package:flutter/material.dart';
import 'views/home.dart';
import 'views/login.dart';
import 'views/register.dart';
import 'views/sensor_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'KartPro',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/login': (context) => LoginScreen(), // Sin 'const'
        '/register': (context) => RegisterScreen(), // Sin 'const'
        '/sensor_view': (context) => const SensorView(),
      },
    );
  }
}
