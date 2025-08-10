import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import 'home_screen.dart';
import 'auth_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/auth_cubit.dart';
import '../cubits/rental_cubit.dart';
import 'rental_form_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
            context.read<AuthCubit>().logout();
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const AuthScreen()),
              (route) => false,
            );
            return;
          }
          setState(() => _currentIndex = i);
          if (i == 1) {
            context.read<RentalCubit>().loadRentals();
          }
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

  String _inferStatus(Map<String, dynamic> r) {
    final raw = (r['status'] as String?)?.toLowerCase();
    final endAt = r['endAt'];
    DateTime? dt;
    if (endAt != null) {
      try {
        dt = (endAt is DateTime)
            ? endAt
            : (endAt is Timestamp)
                ? endAt.toDate()
                : DateTime.tryParse(endAt.toString());
      } catch (_) {}
    }
    final now = DateTime.now();
    final isTimeExpired = dt != null && dt.isBefore(now);
    if (raw == 'expired' || raw == 'inactive' || isTimeExpired) return 'expired';
    return 'active';
  }

  String _statusText(Map<String, dynamic> r) {
    final status = _inferStatus(r);
    if (status == 'expired') return 'Expired';
    final endAt = r['endAt'];
    try {
      final dt = (endAt is DateTime)
          ? endAt
          : (endAt is Timestamp)
              ? endAt.toDate()
              : DateTime.tryParse(endAt.toString());
      if (dt == null) return 'Active';
      final now = DateTime.now();
      final remaining = dt.isAfter(now) ? dt.difference(now).inDays + 1 : 0;
      return remaining > 0
          ? 'Active - $remaining day${remaining > 1 ? 's' : ''} left'
          : 'Active';
    } catch (_) {
      return 'Active';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your Rentals')),
      body: BlocBuilder<RentalCubit, RentalState>(
        builder: (context, state) {
          if (state.status == RentalStatus.loading && state.rentals.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.status == RentalStatus.failure) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(state.errorMessage ?? 'Failed to load rentals'),
              ),
            );
          }

          final rentals = state.rentals;
          final active = rentals.where((r) => _inferStatus(r) == 'active').toList();
          final expired = rentals.where((r) => _inferStatus(r) == 'expired').toList();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('Active', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              if (active.isEmpty)
                const Text('No active rentals')
              else
                ...active.map((r) => _RentalTile(
                      title: (r['movieTitle'] ?? '').toString(),
                      statusColor: AppColors.rentalActive,
                      statusText: _statusText(r),
                      onRerent: () {},
                    )),
              const SizedBox(height: 24),
              Text('Expired', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              if (expired.isEmpty)
                const Text('No expired rentals')
              else
                ...expired.map((r) => _RentalTile(
                      title: (r['movieTitle'] ?? '').toString(),
                      statusColor: AppColors.rentalExpired,
                      statusText: 'Expired',
                      canRerent: true,
                      onRerent: () {
                        final movie = {
                          'id': r['movieId'],
                          'title': r['movieTitle'],
                          'poster_path': r['posterPath'],
                          'vote_average': 0,
                        };
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => RentalFormScreen(movie: movie, rentalId: (r['id'] as String)),
                          ),
                        );
                      },
                    )),
            ],
          );
        },
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

