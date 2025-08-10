import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/text_styles.dart';
import '../widgets/movie_card.dart';
import '../widgets/custom_text_fields.dart';
import '../widgets/filter_chips.dart';
import '../widgets/loading_indicators.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/movie_cubit.dart';
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
  bool _isGridView = true;
  String? _selectedGenre;
  double? _selectedRating;
  int? _selectedYear;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final movieCubit = context.read<MovieCubit>();
      if (movieCubit.state.movies.isEmpty && movieCubit.state.status == MovieStatus.initial) {
        movieCubit.fetchMovies();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _getFilteredMovies(List<Map<String, dynamic>> movies) {
    return movies;
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
            context.read<MovieCubit>().applyFilters(
              genre: genre,
              rating: rating,
              year: year,
            );
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
    final cubit = context.read<MovieCubit>();
    cubit.clearFilters();
  }

  Future<void> _onRefresh() async {
    await context.read<MovieCubit>().refreshMovies();
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
            child: Row(
              children: [
                Expanded(
                  child: SearchTextField(
                    controller: _searchController,
                    onChanged: null,
                    onClear: () {
                      setState(() {
                        _searchController.clear();
                      });
                      context.read<MovieCubit>().search('');
                    },
                    onSubmitted: (value) => context.read<MovieCubit>().search(value),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () => context.read<MovieCubit>().search(_searchController.text),
                  icon: const Icon(Icons.search),
                  label: const Text('Search'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
              ],
            ),
          ),

          // Active Filters
          BlocBuilder<MovieCubit, MovieState>(
            buildWhen: (previous, current) => 
              previous.selectedGenre != current.selectedGenre ||
              previous.selectedRating != current.selectedRating ||
              previous.selectedYear != current.selectedYear ||
              previous.searchQuery != current.searchQuery,
            builder: (context, state) {
              final hasFilters = state.selectedGenre != null || 
                               state.selectedRating != null || 
                               state.selectedYear != null ||
                               (state.searchQuery ?? '').isNotEmpty;
                               
              if (!hasFilters) return const SizedBox.shrink();

              return Container(
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
                          if (state.selectedGenre != null)
                            Chip(
                              label: Text(state.selectedGenre!),
                              onDeleted: () {
                                setState(() {
                                  _selectedGenre = null;
                                });
                                context.read<MovieCubit>().clearGenreFilter();
                              },
                            ),
                          if (state.selectedRating != null)
                            Chip(
                              label: Text('Rating ≥ ${state.selectedRating!.toStringAsFixed(1)}'),
                              onDeleted: () {
                                setState(() {
                                  _selectedRating = null;
                                });
                                context.read<MovieCubit>().clearRatingFilter();
                              },
                            ),
                          if (state.selectedYear != null)
                            Chip(
                              label: Text(state.selectedYear.toString()),
                              onDeleted: () {
                                setState(() {
                                  _selectedYear = null;
                                });
                                context.read<MovieCubit>().clearYearFilter();
                              },
                            ),
                           if ((state.searchQuery ?? '').isNotEmpty)
                            Chip(
                               label: Text('Search: ${state.searchQuery}'),
                              onDeleted: () {
                                setState(() {
                                  _searchController.clear();
                                });
                                context.read<MovieCubit>().search('');
                              },
                            ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        _clearFilters();
                        context.read<MovieCubit>().search('');
                      },
                      child: Text(
                        'Clear All',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          Expanded(
            child: BlocBuilder<MovieCubit, MovieState>(
              builder: (context, state) {
                if (state.status == MovieStatus.loading && state.movies.isEmpty) {
                  return const MovieListShimmer();
                }

                if (state.status == MovieStatus.failure && state.movies.isEmpty) {
                  return ErrorMessage(
                    message: state.errorMessage ?? 'Failed to load movies. Check your TMDB key or network.',
                    actionText: 'Retry',
                    onActionPressed: () => context.read<MovieCubit>().fetchMovies(),
                  );
                }

                if (state.movies.isEmpty) {
                  return NoMoviesFoundWidget(
                    onRefresh: () => context.read<MovieCubit>().fetchMovies(),
                  );
                }

                final filteredMovies = _getFilteredMovies(state.movies);

                if (filteredMovies.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.search_off,
                          size: 64,
                          color: AppColors.textLight,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No movies found matching your criteria',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textLight,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _clearFilters,
                          child: const Text('Clear Filters'),
                        ),
                      ],
                    ),
                  );
                }

                return _isGridView 
                  ? _buildGridView(filteredMovies, state) 
                  : _buildListView(filteredMovies, state);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridView(List<Map<String, dynamic>> movies, MovieState state) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (state.canLoadMore && !state.isLoadingMore) {
          final metrics = notification.metrics;
          if (metrics.pixels >= metrics.maxScrollExtent - 200) {
            context.read<MovieCubit>().fetchNextPage();
          }
        }
        return false;
      },
      child: RefreshIndicator(
        onRefresh: _onRefresh,
        child: GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.6,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: movies.length + (state.isLoadingMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == movies.length) {
              return const MovieCardLoading();
            }

            final movie = movies[index];
            return MovieCard.fromTmdbData(
              movieData: movie,
              onTap: () => _onMovieTap(movie),
              heroTag: 'grid_movie_${movie['id']}',
            );
          },
        ),
      ),
    );
  }

  Widget _buildListView(List<Map<String, dynamic>> movies, MovieState state) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (state.canLoadMore && !state.isLoadingMore) {
          final metrics = notification.metrics;
          if (metrics.pixels >= metrics.maxScrollExtent - 200) {
            context.read<MovieCubit>().fetchNextPage();
          }
        }
        return false;
      },
      child: RefreshIndicator(
        onRefresh: _onRefresh,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: movies.length + (state.isLoadingMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == movies.length) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: const CircularProgressIndicator(strokeWidth: 2.5),
                  ),
                ),
              );
            }

            final movie = movies[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: MovieCardHorizontal.fromTmdbData(
                movieData: movie,
                onTap: () => _onMovieTap(movie),
              ),
            );
          },
        ),
      ),
    );
  }
}