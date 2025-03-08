import 'package:flutter/material.dart';

import 'constants/app_colors.dart';
import 'helpers/location_helper.dart';
import 'models/user_model.dart';
import 'screens/login_screen.dart';
import 'screens/main_screen.dart';
import 'screens/start_km_screen.dart';
import 'services/auth_service.dart';
import 'services/usage_car_service.dart';
import 'widgets/custom_loading.dart';
import 'widgets/custom_message.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Future<Widget> _checkInitialScreen() async {
    WidgetsFlutterBinding.ensureInitialized();

    final token = await AuthService().getToken();
    if (token == null) {
      return const LoginScreen();
    }

    User? user = await AuthService().getUserData();
    String? username = user?.username;

    if (user == null || username == null) {
      return const LoginScreen();
    }

    final usageCar = await UsageCarService().fetchUsageCar(username);
    final position = await LocationHelper.getCurrentLocation();

    if (position == null) {
      CustomMessage.show(context, "Gagal mendapatkan lokasi",
          backgroundColor: AppColors.primaryRed);
      return const LoginScreen();
    }

    if (usageCar == null) {
      return const StartKmScreen();
    } else {
      return MainScreen(
        username: user.username!,
        latitude: position.latitude.toString(),
        longitude: position.longitude.toString(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(fontFamily: 'Gilroy'),
      debugShowCheckedModeBanner: false,
      home: FutureBuilder<Widget>(
        future: _checkInitialScreen(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CustomLoadingScreen(); // Gunakan custom loading
          } else if (snapshot.hasData) {
            return snapshot.data!;
          } else {
            return const LoginScreen();
          }
        },
      ),
    );
  }
}
