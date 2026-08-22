import 'package:flutter/material.dart';
import 'package:amharic_catholic_bible/theme/app_colors.dart';
import 'package:amharic_catholic_bible/theme/app_tokens.dart';
import 'package:amharic_catholic_bible/theme/app_typography.dart';
import 'package:amharic_catholic_bible/features/main_navigation_controller.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  Future<void> _navigateToHome() async {
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const MainNavigationController(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: Center(
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0.85, end: 1.0),
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeOutCubic,
          builder: (context, scale, child) {
            return Transform.scale(
              scale: scale,
              child: Opacity(
                opacity: ((scale - 0.85) / 0.15).clamp(0.0, 1.0),
                child: child,
              ),
            );
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.xl),
                decoration: const BoxDecoration(
                  color: Color(0x1AC8A951),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.church,
                  size: 56,
                  color: AppColors.liturgicalGold,
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              Text(
                'ANLEYLAB',
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 3.0,
                  color: AppColors.liturgicalGold,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'መጽሐፍ ቅዱስ',
                style: AppTypography.appTitle(context, isDark: isDark).copyWith(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'የካቶሊክ አማርኛ መጽሐፍ ቅዱስ',
                style: AppTypography.secondaryText(isDark: isDark),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
