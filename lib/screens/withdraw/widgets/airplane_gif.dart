import 'dart:async';
import 'package:flutter/material.dart';

class AirplaneGif extends StatefulWidget {
  const AirplaneGif({super.key});

  @override
  State<AirplaneGif> createState() => _AirplaneGifState();
}

class _AirplaneGifState extends State<AirplaneGif> {
  int _currentIndex = 0;
  final List<String> _images = [
    'assets/images/airplanegif_1.png',
    'assets/images/airplanegif_2.png',
    'assets/images/airplanegif_3.png',
  ];
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 350), (timer) {
      if (mounted) {
        setState(() {
          _currentIndex = (_currentIndex + 1) % _images.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.8, end: 1.0).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOut),
              ),
              child: child,
            ),
          ),
          child: Image.asset(
            _images[_currentIndex],
            key: ValueKey<int>(_currentIndex),
            width: 100,
            height: 100,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
