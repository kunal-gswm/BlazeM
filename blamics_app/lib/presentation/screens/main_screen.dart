import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import 'dashboard_screen.dart';
import 'timeline_screen.dart';
import 'ipo_list_screen.dart';
import 'corporate_actions_screen.dart';
import 'menu_screen.dart';
import 'high_low_screen.dart';
import 'sector_heatmap_screen.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  int _currentIndex = 0;

  List<Widget> get _screens => const [
    DashboardScreen(),
    TimelineScreen(),
    CorporateActionsScreen(),
    IpoListScreen(),
    MenuScreen(),
    SectorHeatmapScreen(),
    HighLowScreen(),
  ];

  void _showNavigationMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          margin: const EdgeInsets.only(
            left: AppSpacing.lg,
            right: AppSpacing.lg,
            bottom: AppSpacing.xl,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface1,
            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: AppSpacing.sm),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              _buildNavMenuItem(context, 0, Icons.dashboard_outlined, 'Dashboard'),
              _buildNavMenuItem(context, 1, Icons.timeline, 'Timeline'),
              _buildNavMenuItem(context, 2, Icons.event_note_outlined, 'Corporate Actions'),
              _buildNavMenuItem(context, 3, Icons.rocket_launch_outlined, 'IPOs'),
              _buildNavMenuItem(context, 5, Icons.grid_view_rounded, 'Sector Heatmap'),
              _buildNavMenuItem(context, 6, Icons.swap_vert_rounded, '52-Week High/Low'),
              _buildNavMenuItem(context, 4, Icons.settings_outlined, 'Settings & Info'),
              const SizedBox(height: AppSpacing.sm),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNavMenuItem(BuildContext context, int index, IconData icon, String title) {
    final isSelected = _currentIndex == index;
    return ListTile(
      dense: true,
      leading: Icon(
        icon,
        color: isSelected ? AppColors.primary : AppColors.textSecondary,
        size: 22,
      ),
      title: Text(
        title,
        style: AppTypography.bodyMedium.copyWith(
          color: isSelected ? AppColors.primary : AppColors.textPrimary,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      trailing: isSelected
          ? Icon(Icons.circle, size: 8, color: AppColors.primary)
          : null,
      onTap: () {
        setState(() => _currentIndex = index);
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showNavigationMenu(context),
        backgroundColor: AppColors.primary, // Make it pop a bit more since it's an icon
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        child: const Icon(
          Icons.local_fire_department_rounded, // Flame icon for BlazeM
          color: Colors.white,
          size: 28,
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: AppColors.surface1,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildBottomNavItem(0, Icons.dashboard_outlined, 'Dashboard'),
              _buildBottomNavItem(1, Icons.timeline, 'Timeline'),
              const SizedBox(width: 48), // Space for FAB
              _buildBottomNavItem(2, Icons.event_note_outlined, 'Actions'),
              _buildBottomNavItem(3, Icons.rocket_launch_outlined, 'IPOs'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    return InkWell(
      onTap: () => setState(() => _currentIndex = index),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTypography.navLabel.copyWith(
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

