import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class RuqyahScreen extends StatelessWidget {
  const RuqyahScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(title: const Text('برنامجي الروحي')),
      body: const Center(
        child: Text(
          'البرنامج الروحي',
          style: TextStyle(
            color: AppColors.textDark,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
