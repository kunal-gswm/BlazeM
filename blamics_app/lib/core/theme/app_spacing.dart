import 'package:flutter/material.dart';

class AppSpacing {
  AppSpacing._();

  // Base grid unit
  static const double unit = 4.0;

  // Named spacing values (4px grid)
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;

  // Card border radius
  static const double cardRadius = 8.0;
  static const double badgeRadius = 4.0;

  // Common EdgeInsets
  static const EdgeInsets paddingSm = EdgeInsets.all(sm);
  static const EdgeInsets paddingMd = EdgeInsets.all(md);
  static const EdgeInsets paddingLg = EdgeInsets.all(lg);

  static const EdgeInsets paddingHorizontalLg =
      EdgeInsets.symmetric(horizontal: lg);
  static const EdgeInsets paddingHorizontalMd =
      EdgeInsets.symmetric(horizontal: md);

  static const EdgeInsets paddingVerticalSm =
      EdgeInsets.symmetric(vertical: sm);
  static const EdgeInsets paddingVerticalXs =
      EdgeInsets.symmetric(vertical: xs);

  // Screen-level padding
  static const EdgeInsets screenPadding =
      EdgeInsets.symmetric(horizontal: lg, vertical: sm);

  // Card internal padding
  static const EdgeInsets cardPadding = EdgeInsets.all(md);

  // Section spacing (gap between sections)
  static const SizedBox sectionGap = SizedBox(height: lg);
  static const SizedBox itemGap = SizedBox(height: sm);
  static const SizedBox tinyGap = SizedBox(height: xs);
}
