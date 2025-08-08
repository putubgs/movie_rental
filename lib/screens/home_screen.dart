import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/text_styles.dart';
import '../widgets/movie_card.dart';
import '../widgets/custom_text_fields.dart';
import '../widgets/filter_chips.dart';
import '../widgets/loading_indicators.dart';
import '../widgets/error_widgets.dart';
import 'movie_detail_screen.dart';
import 'filter_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();
  bool _isLoading = false;
  bool _isGridView = true;
  String? _selectedGenre;
  double? _selectedRating;
  int? _selectedYear;

  // Mock data for demonstration
  final List<Map<String, dynamic>> _mockMovies = [
    {
      'id': 1,
      'title': 'The Shawshank Redemption',
      'posterUrl': 'https://image.tmdb.org/t/p/w500/q6y0Go1tsGEsmtFryDOJo3dEmqu.jpg',
      'rating': 9.3,
      'genres': ['Drama', 'Crime'],
      'isAdult': false,
    },
    {
      'id': 2,
      'title': 'The Godfather',
      'posterUrl': 'https://image.tmdb.org/t/p/w500/3bhkrj58Vtu7enYsRolD1fZdja1.jpg',
      'rating': 9.2,
      'genres': ['Crime', 'Drama'],
      'isAdult': false,
    },
    {
      'id': 3,
      'title': 'Pulp Fiction',
      'posterUrl': 'https://image.tmdb.org/t/p/w500/d5iIlFn5s0ImszYzBPb8JPIfbXD.jpg',
      'rating': 8.9,
      'genres': ['Crime', 'Drama'],
      'isAdult': true,
    },
    {
      'id': 4,
      'title': 'The Dark Knight',
      'posterUrl': 'https://image.tmdb.org/t/p/w500/qJ2tW6WMUDux911r6m7haRef0WH.jpg',
      'rating': 9.0,
      'genres': ['Action', 'Crime', 'Drama'],
      'isAdult': false,
    },
    {
      'id': 5,
      'title': 'Fight Club',
      'posterUrl': 'https://image.tmdb.org/t/p/w500/pB8BM7pdSp6B6Ih7QZ4DrQ3PmJK.jpg',
      'rating': 8.8,
      'genres': ['Drama'],
      'isAdult': true,
    },
    {
      'id': 6,
      'title': 'Inception',
      'posterUrl': 'https://image.tmdb.org/t/p/w500/9gk7adHYeDvHkCSEqAvQNLV5Uge.jpg',
      'rating': 8.8,
      'genres': ['Action', 'Adventure', 'Sci-Fi'],
      'isAdult': false,
    },
  ];

  final List<String> _genres = [
    'Action',
    'Adventure',
    'Comedy',
    'Crime',
    'Drama',
    'Horror',
    'Romance',
    'Sci-Fi',
    'Thriller',
  ];

  @override
  void initState() {
    super.initState();
    _loadMovies();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadMovies() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isLoading = false;
    });
  }

  List<Map<String, dynamic>> get _filteredMovies {
    return _mockMovies.where((movie) {
      // Search filter
      if (_searchController.text.isNotEmpty) {
        if (!movie['title'].toLowerCase().contains(_searchController.text.toLowerCase())) {
          return false;
        }
      }

      // Genre filter
      if (_selectedGenre != null) {
        if (!movie['genres'].contains(_selectedGenre)) {
          return false;
        }
      }

      // Rating filter
      if (_selectedRating != null) {
        if (movie['rating'] < _selectedRating!) {
          return false;
        }
      }

      // Year filter (mock - would be real year in actual implementation)
      // For now, we'll skip year filtering

      return true;
    }).toList();
  }

  void _onMovieTap(Map<String, dynamic> movie) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MovieDetailScreen(movie: movie),
      ),
    );
  }

  void _onFilterTap() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FilterScreen(
          selectedGenre: _selectedGenre,
          selectedRating: _selectedRating,
          selectedYear: _selectedYear,
          onApplyFilters: (genre, rating, year) {
            setState(() {
              _selectedGenre = genre;
              _selectedRating = rating;
              _selectedYear = year;
            });
          },
        ),
      ),
    );
  }

  void _clearFilters() {
    setState(() {
      _selectedGenre = null;
      _selectedRating = null;
      _selectedYear = null;
      _searchController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Movie Rental'),
        actions: [
          IconButton(
            icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
            onPressed: () {
              setState(() {
                _isGridView = !_isGridView;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _onFilterTap,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: SearchTextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {});
              },
              onClear: () {
                setState(() {
                  _searchController.clear();
                });
              },
            ),
          ),

          // Active Filters
          if (_selectedGenre != null || _selectedRating != null || _selectedYear != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Text(
                    'Active filters: ',
                    style: AppTextStyles.bodySmall,
                  ),
                  Expanded(
                    child: Wrap(
                      spacing: 8,
                      children: [
                        if (_selectedGenre != null)
                          Chip(
                            label: Text(_selectedGenre!),
                            onDeleted: () {
                              setState(() {
                                _selectedGenre = null;
                              });
                            },
                          ),
                        if (_selectedRating != null)
                          Chip(
                            label: Text('Rating ≥ ${_selectedRating!.toStringAsFixed(1)}'),
                            onDeleted: () {
                              setState(() {
                                _selectedRating = null;
                              });
                            },
                          ),
                        if (_selectedYear != null)
                          Chip(
                            label: Text(_selectedYear.toString()),
                            onDeleted: () {
                              setState(() {
                                _selectedYear = null;
                              });
                            },
                          ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: _clearFilters,
                    child: Text(
                      'Clear All',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Movie List
          Expanded(
            child: _isLoading
                ? const MovieListShimmer()
                : _filteredMovies.isEmpty
                    ? NoMoviesFoundWidget(onRefresh: _loadMovies)
                    : _isGridView
                        ? _buildGridView()
                        : _buildListView(),
          ),
        ],
      ),
    );
  }

  Widget _buildGridView() {
    return PullToRefreshIndicator(
      onRefresh: _loadMovies,
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.6,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: _filteredMovies.length,
        itemBuilder: (context, index) {
          final movie = _filteredMovies[index];
          return MovieCard(
            title: movie['title'],
            posterUrl: movie['posterUrl'],
            rating: movie['rating'].toDouble(),
            genres: List<String>.from(movie['genres']),
            isAdult: movie['isAdult'],
            heroTag: 'movie-${movie['id']}',
            onTap: () => _onMovieTap(movie),
          );
        },
      ),
    );
  }

  Widget _buildListView() {
    return PullToRefreshIndicator(
      onRefresh: _loadMovies,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _filteredMovies.length,
        itemBuilder: (context, index) {
          final movie = _filteredMovies[index];
          return MovieCardHorizontal(
            title: movie['title'],
            posterUrl: movie['posterUrl'],
            rating: movie['rating'].toDouble(),
            genres: List<String>.from(movie['genres']),
            isAdult: movie['isAdult'],
            onTap: () => _onMovieTap(movie),
          );
        },
      ),
    );
  }
} 