// ignore_for_file: unused_local_variable

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'firebase_options.dart';
import 'controllers/auth_controller.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'services/database_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase first
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Firestore
  final firestore = FirebaseFirestore.instance;
  
  // Initialize services in order
  final dbService = DatabaseService();
  Get.put(dbService);
  Get.put(AuthController());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Firebase Auth',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: FirebaseAuth.instance.currentUser != null ? '/home' : '/login',
      getPages: [
        GetPage(
          name: '/login', 
          page: () => LoginScreen(),
          transition: Transition.fadeIn,
        ),
        GetPage(
          name: '/signup', 
          page: () => SignupScreen(),
          transition: Transition.fadeIn,
        ),
        GetPage(
          name: '/home', 
          page: () => HomeScreen(),
          transition: Transition.fadeIn,
        ),
      ],
    );
  }
}
