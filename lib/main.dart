import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:waterriderdemo/screens/cubit/location_cubit.dart';
import 'package:waterriderdemo/screens/forget_password.dart';
import 'core/shared_preferences.dart';
import 'screens/my_trips.dart';
import 'package:waterriderdemo/screens/signupverification_screen.dart';
import 'screens/login_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/signup_screen.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await CacheHelper.init();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<LocationCubit>(create: (context) => LocationCubit(),),
      ],
      child: MaterialApp(
        title: 'WATER RIDERS',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          fontFamily: 'Pacifico',
        ),
        home: const SplashScreen(),
        routes: {
          '/login': (context) => LoginScreen(),
          '/signup': (context) => const SignUpScreen(),
          '/signupVerification': (context) => const SignUpVerificationScreen(),
          '/home': (context) => const MyTripsScreen(),
          '/forgetPassword': (context) => const ForgetPasswordScreen(),
        },
        onGenerateRoute: (settings) {
          if (settings.name == '/signup') {
            return MaterialPageRoute(
              builder: (context) {
                return SignUpScreen(onSignUpComplete: () {
                  Navigator.pushReplacementNamed(context, '/signupVerification');
                });
              },
            );
          }
          return null;
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
