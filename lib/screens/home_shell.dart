import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import 'home_screen.dart';
import 'auth_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _currentIndex = 0;

  final _pages = const [
    HomeScreen(),
    _RentalsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final Widget page = _currentIndex < _pages.length ? _pages[_currentIndex] : _pages[0];
    return Scaffold(
      body: page,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) {
          if (i == 2) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const AuthScreen()),
              (route) => false,
            );
            return;
          }
          setState(() => _currentIndex = i);
        },
        indicatorColor: AppColors.primary.withOpacity(0.1),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.movie_outlined), label: 'Movies'),
          NavigationDestination(icon: Icon(Icons.receipt_long_outlined), label: 'Rentals'),
          NavigationDestination(icon: Icon(Icons.logout), label: 'Logout'),
        ],
      ),
    );
  }
}

class _RentalsScreen extends StatelessWidget {
  const _RentalsScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your Rentals')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Active', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          _RentalTile(
            title: 'Inception',
            statusColor: AppColors.rentalActive,
            statusText: 'Active - 2 days left',
            onRerent: () {},
          ),
          const SizedBox(height: 24),
          Text('Expired', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          _RentalTile(
            title: 'Pulp Fiction',
            statusColor: AppColors.rentalExpired,
            statusText: 'Expired',
            onRerent: () {},
            canRerent: true,
          ),
        ],
      ),
    );
  }
}

class _RentalTile extends StatelessWidget {
  final String title;
  final String statusText;
  final Color statusColor;
  final bool canRerent;
  final VoidCallback onRerent;

  const _RentalTile({
    required this.title,
    required this.statusText,
    required this.statusColor,
    required this.onRerent,
    this.canRerent = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(title),
        subtitle: Text(statusText, style: TextStyle(color: statusColor)),
        trailing: canRerent
            ? TextButton.icon(
                onPressed: onRerent,
                icon: const Icon(Icons.refresh),
                label: const Text('Re-rent'),
              )
            : null,
        onTap: () => showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Rental Details'),
            content: const Text('Return date countdown and details...'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

