import 'package:e_cycle/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  bool _disposed = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    _initAnimation();
  }

  void _initAnimation() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    // ✅ Safe animation start
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_disposed && mounted) {
        _animationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _disposed = true;
    _animationController.dispose();
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Opacity(
            opacity: _fadeAnimation.value,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildTopOrnament(),
                Transform.scale(
                  scale: _scaleAnimation.value,
                  child: _buildLogo(),
                ),
                _buildBottomOrnament(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTopOrnament() {
    return Image.asset(
      'assets/images/ornamen_atas.png',
      fit: BoxFit.contain,
      cacheWidth: 400,
      // ✅ Error handling untuk missing assets
      errorBuilder: (context, error, stackTrace) {
        return Container(
          height: 100,
          color: Colors.transparent,
        );
      },
    );
  }

  Widget _buildLogo() {
    return Image.asset(
      'assets/images/logo.png',
      width: 150,
      fit: BoxFit.contain,
      cacheWidth: 300,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: 150,
          height: 150,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(75),
          ),
          child: const Icon(
            Icons.eco,
            size: 80,
            color: Colors.white,
          ),
        );
      },
    );
  }

  Widget _buildBottomOrnament() {
    return Image.asset(
      'assets/images/ornamen_bawah.png',
      fit: BoxFit.contain,
      cacheWidth: 400,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          height: 100,
          color: Colors.transparent,
        );
      },
    );
  }
}
