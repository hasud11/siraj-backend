import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // الهوية الأساسية لسِراج
  static const Color primary = Color(0xFF25213F);
  static const Color primaryDark = Color(0xFF17152D);

  // البنفسجي
  static const Color purple = Color(0xFF8E7CC3);
  static const Color purpleLight = Color(0xFFEDE6F5);

  // الوردي
  static const Color pink = Color(0xFFE7A6C8);
  static const Color pinkLight = Color(0xFFF6E5EF);

  // الذهبي
  static const Color gold = Color(0xFFD9A84E);

  // الخلفيات
  static const Color cream = Color(0xFFF8F3EA);
  static const Color white = Color(0xFFFFFFFF);

  // النصوص
  static const Color textDark = Color(0xFF292640);
  static const Color textMuted = Color(0xFF777386);

  // حالات النظام
  static const Color success = Color(0xFF5D9B78);
  static const Color warning = Color(0xFFE5A24C);
  static const Color danger = Color(0xFFD95C61);

  // ألوان شفافة جاهزة للاستخدام
  static Color purpleSoft(double opacity) {
    return purple.withValues(alpha: opacity);
  }

  static Color pinkSoft(double opacity) {
    return pink.withValues(alpha: opacity);
  }

  static Color primarySoft(double opacity) {
    return primary.withValues(alpha: opacity);
  }
}