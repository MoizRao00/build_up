import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: AppColors.glassCardBackground,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.glassCardBorder, width: 1),
          ),
          child: child,
        ),
      ),
    );
  }
}