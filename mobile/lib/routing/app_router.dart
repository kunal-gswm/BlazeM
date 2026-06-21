import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'route_names.dart';
import '../features/dashboard/screens/dashboard_screen.dart';
import '../features/ipo/screens/ipo_list_screen.dart';
import '../features/ipo/screens/ipo_detail_screen.dart';
import '../features/event_timeline/screens/event_timeline_screen.dart';

// Placeholder screens — replaced as features are built.
// Each import will point to the actual feature screen.
class _PlaceholderScreen extends StatelessWidget {
  const _PlaceholderScreen(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text(title, style: const TextStyle(fontSize: 16))),
    );
  }
}

/// Shell scaffold with bottom navigation.
class _ShellScaffold extends StatelessWidget {
  const _ShellScaffold({required this.child, required this.currentIndex});
  final Widget child;
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) => _onTap(context, index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.rocket_launch_outlined),
            selectedIcon: Icon(Icons.rocket_launch),
            label: 'IPOs',
          ),
          NavigationDestination(
            icon: Icon(Icons.event_note_outlined),
            selectedIcon: Icon(Icons.event_note),
            label: 'Actions',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_outlined),
            selectedIcon: Icon(Icons.account_balance),
            label: 'Bonds',
          ),
          NavigationDestination(
            icon: Icon(Icons.more_horiz),
            selectedIcon: Icon(Icons.more_horiz),
            label: 'More',
          ),
        ],
      ),
    );
  }

  void _onTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.goNamed(RouteNames.dashboard);
      case 1:
        context.goNamed(RouteNames.ipoList);
      case 2:
        context.goNamed(RouteNames.corporateActions);
      case 3:
        context.goNamed(RouteNames.bondList);
      case 4:
        // "More" tab — go to news for now, will become drawer/menu later.
        context.goNamed(RouteNames.newsList);
    }
  }
}

/// Calculates the bottom nav index from the current route.
int _indexFromRoute(String location) {
  if (location.startsWith('/ipo')) {
    return 1;
  }
  if (location.startsWith('/corporate-actions')) {
    return 2;
  }
  if (location.startsWith('/bonds')) {
    return 3;
  }
  if (location.startsWith('/news') ||
      location.startsWith('/watchlist') ||
      location.startsWith('/search')) {
    return 4;
  }
  return 0; // dashboard
}

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    // Shell route with bottom navigation
    ShellRoute(
      builder: (context, state, child) {
        final index = _indexFromRoute(state.uri.path);
        return _ShellScaffold(currentIndex: index, child: child);
      },
      routes: [
        GoRoute(
          path: '/',
          name: RouteNames.dashboard,
          builder: (context, state) => const DashboardScreen(),
        ),
        GoRoute(
          path: '/ipo',
          name: RouteNames.ipoList,
          builder: (context, state) => const IpoListScreen(),
          routes: [
            GoRoute(
              path: ':id',
              name: RouteNames.ipoDetail,
              builder: (context, state) => IpoDetailScreen(
                id: state.pathParameters['id']!,
              ),
              routes: [
                GoRoute(
                  path: 'gmp',
                  name: RouteNames.ipoGmp,
                  builder: (context, state) => _PlaceholderScreen(
                    'GMP ${state.pathParameters['id']}',
                  ),
                ),
              ],
            ),
          ],
        ),
        GoRoute(
          path: '/corporate-actions',
          name: RouteNames.corporateActions,
          builder: (context, state) =>
              const _PlaceholderScreen('Corporate Actions'),
          routes: [
            GoRoute(
              path: ':id',
              name: RouteNames.corporateActionDetail,
              builder: (context, state) => _PlaceholderScreen(
                'Action ${state.pathParameters['id']}',
              ),
            ),
          ],
        ),
        GoRoute(
          path: '/bonds',
          name: RouteNames.bondList,
          builder: (context, state) =>
              const _PlaceholderScreen('Bonds'),
          routes: [
            GoRoute(
              path: ':id',
              name: RouteNames.bondDetail,
              builder: (context, state) => _PlaceholderScreen(
                'Bond ${state.pathParameters['id']}',
              ),
            ),
          ],
        ),
        GoRoute(
          path: '/news',
          name: RouteNames.newsList,
          builder: (context, state) =>
              const _PlaceholderScreen('News'),
          routes: [
            GoRoute(
              path: ':id',
              name: RouteNames.newsDetail,
              builder: (context, state) => _PlaceholderScreen(
                'News ${state.pathParameters['id']}',
              ),
            ),
          ],
        ),
        GoRoute(
          path: '/watchlist',
          name: RouteNames.watchlist,
          builder: (context, state) =>
              const _PlaceholderScreen('Watchlist'),
        ),
        GoRoute(
          path: '/timeline',
          name: RouteNames.eventTimeline,
          builder: (context, state) => const EventTimelineScreen(),
        ),
        GoRoute(
          path: '/search',
          name: RouteNames.search,
          builder: (context, state) =>
              const _PlaceholderScreen('Search'),
        ),
      ],
    ),

    // Event timeline — outside shell (no bottom nav)
    GoRoute(
      path: '/events/:id/timeline',
      name: RouteNames.eventTimeline,
      builder: (context, state) => _PlaceholderScreen(
        'Timeline ${state.pathParameters['id']}',
      ),
    ),
  ],
);
