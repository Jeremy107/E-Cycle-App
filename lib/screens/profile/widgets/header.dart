import 'package:flutter/material.dart';
import 'package:e_cycle/constants/app_styles.dart';

Widget Header = Container(
  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  child: Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          Icons.person_rounded,
          color: Colors.white,
          size: 28,
        ),
      ),
      const SizedBox(width: 12),
      Text(
        "Profil",
        style: AppStyles.titleStyle.copyWith(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    ],
  ),
);
