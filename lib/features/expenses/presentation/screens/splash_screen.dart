
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:spendly/core/router/app_rounter.dart';
import 'package:spendly/core/theme/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _timer = Timer(const Duration(seconds: 4), () {
      if (!mounted) return;
      context.go(AppRoutes.dashboard);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode =
        Theme.of(context).brightness == Brightness.dark;

    final backgroundColor = isDarkMode
        ? AppColors.darkBackground
        : AppColors.lightBackground;

    final primaryColor = isDarkMode
        ? AppColors.darkPrimary
        : AppColors.lightPrimary;

    final textColor = isDarkMode
        ? AppColors.darkText
        : AppColors.lightText;

    final secondaryTextColor = isDarkMode
        ? AppColors.darkSecondaryText
        : AppColors.lightSecondaryText;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_balance_wallet_rounded,
              size: 80.r,
              color: primaryColor,
            ),
            SizedBox(height: 16.h),
            Text(
              'Spendly',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Track your expenses, simply.',
              style: TextStyle(
                fontSize: 16,
                color: secondaryTextColor,
              ),
            ),
            SizedBox(height: 28.h),
          ],
        ),
      ),
    );
  }
}
