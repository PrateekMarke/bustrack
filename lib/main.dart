import 'package:bustrack/const/app_theme.dart';
import 'package:bustrack/firebase_options.dart';
import 'package:bustrack/view/auth/auth_controller.dart';
import 'package:bustrack/view/splash_screen/splash_screen.dart';
import 'package:bustrack/xdummy/authscreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';



import 'package:provider/provider.dart';Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,);
  runApp( MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});


  @override
  // Widget build(BuildContext context) {
  //   return MultiProvider(
  //     providers: [
  //       ChangeNotifierProvider(create: (_) => AuthController()),
  //     ],
  //     child: MaterialApp(
  //       theme: AppTheme.darkTheme,
  //         home: const SplashScreen(),
  //         ),
  //   );
  // }
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.darkTheme,home: AuthScreen(),
    );}
}
