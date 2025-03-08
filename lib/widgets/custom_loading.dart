import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

// Widget custom loading baru
class CustomLoadingScreen extends StatelessWidget {
  const CustomLoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Ganti dari hitam ke putih
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animasi loading dengan rotation
            TweenAnimationBuilder(
              tween: Tween<double>(begin: 0, end: 2 * 3.14159),
              duration: const Duration(seconds: 2),
              builder: (context, double angle, child) {
                return Transform.rotate(
                  angle: angle,
                  child: const Icon(
                    Icons.directions_car,
                    size: 60,
                    color: AppColors.primaryRed,
                  ),
                );
              },
              onEnd: () {}, // Biarkan kosong untuk loop
            ),
            const SizedBox(height: 20),
            // Teks animasi
            const Text(
              'Memuat Data...',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryRed,
              ),
            ),
            const SizedBox(height: 20),
            // Progress bar
            SizedBox(
              width: 200,
              child: LinearProgressIndicator(
                color: AppColors.primaryRed,
                backgroundColor: Colors.grey[300],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
