import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';  // <-- add this import
import 'package:awesome_notifications/awesome_notifications.dart';

import 'intro_screen.dart';
import 'welcome_screen.dart';
import 'sign_in_screen.dart';
import 'global_navigator.dart';
import 'alert_listener.dart';
import 'auth_wrapper.dart'; // Import the new wrapper

import 'theme_notifier.dart'; // <-- import your theme notifier

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  AwesomeNotifications().initialize(
    null,
    [
      NotificationChannel(
        channelKey: 'alerts_channel',
        channelName: 'Alerts',
        channelDescription: 'Notifications for alerts',
        importance: NotificationImportance.High,
        defaultColor: Colors.red,
        ledColor: Colors.white,
        playSound: false,
      ),
    ],
  );

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeNotifier(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return AlertListener(
      child: MaterialApp(
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        title: 'Alviora',
        themeMode: themeNotifier.themeMode, // <-- use theme mode here
        theme: ThemeData(
          brightness: Brightness.light,
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: Colors.white,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: IconThemeData(color: Colors.blue),
            titleTextStyle: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.8),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Colors.black12),
              ),
              minimumSize: const Size(double.infinity, 50),
            ),
          ),
        ),
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: Colors.black,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: IconThemeData(color: Colors.lightBlueAccent),
            titleTextStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[900],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Colors.white24),
              ),
              minimumSize: const Size(double.infinity, 50),
            ),
          ),
        ),
        home: const AuthWrapper(), // Changed from IntroScreen
        routes: {
          '/welcome': (context) => const WelcomeScreen(),
          '/signin': (context) => const SignInScreen(),
          '/home': (context) => const AlvioraHomePage(),
        },
      ),
    );
  }
}

class AlvioraHomePage extends StatelessWidget {
  const AlvioraHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alviora Home'),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: Theme.of(context).brightness == Brightness.light
                  ? [Colors.white, const Color(0xFF90C3FD)]
                  : [Colors.grey[900]!, Colors.blueGrey[900]!],
              stops: const [0.0, 0.93],
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: Theme.of(context).brightness == Brightness.light
                ? [Colors.white, Colors.white, const Color(0xFF90C3FD), const Color(0xFF90C3FD)]
                : [Colors.black, Colors.black, Colors.blueGrey.shade900, Colors.blueGrey.shade900],
            stops: const [0.0, 0.74, 0.92, 1.0],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _buildFeatureButton(context, 'Mood Detection', Icons.mood),
              const SizedBox(height: 16),
              _buildFeatureButton(context, 'Health Monitor', Icons.monitor_heart),
              const SizedBox(height: 16),
              _buildFeatureButton(context, '360° Camera View', Icons.camera),
              const SizedBox(height: 16),
              _buildFeatureButton(context, 'Emergency Alert', Icons.warning),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureButton(BuildContext context, String text, IconData icon) {
    return ElevatedButton.icon(
      icon: Icon(icon),
      label: Text(text),
      style: Theme.of(context).elevatedButtonTheme.style,
      onPressed: () {},
    );
  }
}
