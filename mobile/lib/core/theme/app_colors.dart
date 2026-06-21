import 'package:flutter/material.dart';

/// Professional market-software color palette.
///
/// Designed for trust, clarity, and information density.
/// Dark theme primary. No neon. No glassmorphism.
class AppColors {
  const AppColors._();

  // ── Background ────────────────────────────────────────────────────
  static const Color scaffoldDark = Color(0xFF090A0D);
  static const Color surfaceDark = Color(0xFF13151B);
  static const Color cardDark = Color(0xFF191C24);
  static const Color cardElevatedDark = Color(0xFF232733);

  // ── Text ──────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFC0C7D5);
  static const Color textTertiary = Color(0xFF8F98A8);
  static const Color textDisabled = Color(0xFF626B7B);

  // ── Accent ────────────────────────────────────────────────────────
  static const Color accentBlue = Color(0xFF4A90D9);
  static const Color accentBlueMuted = Color(0xFF2A5A8F);

  // ── Semantic ──────────────────────────────────────────────────────
  static const Color positive = Color(0xFF2EBD85);
  static const Color negative = Color(0xFFE04F5F);
  static const Color warning = Color(0xFFE5A93B);
  static const Color info = Color(0xFF5B9BD5);

  // ── Status ────────────────────────────────────────────────────────
  static const Color statusUpcoming = Color(0xFF5B9BD5);
  static const Color statusActive = Color(0xFF2EBD85);
  static const Color statusCompleted = Color(0xFF5F6572);
  static const Color statusCancelled = Color(0xFFE04F5F);

  // ── Source priority ───────────────────────────────────────────────
  static const Color sourceOfficial = Color(0xFF2EBD85);
  static const Color sourceSecondary = Color(0xFF5B9BD5);
  static const Color sourceUnofficial = Color(0xFFE5A93B);

  // ── Borders / Dividers ────────────────────────────────────────────
  static const Color border = Color(0xFF32394A);
  static const Color divider = Color(0xFF242A38);

  // ── Stale data indicator ──────────────────────────────────────────
  static const Color staleBannerBg = Color(0xFF1C2030);
  static const Color staleBannerText = Color(0xFF7A8190);
}
