import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../services/dio_api_client.dart';
import 'package:dio/dio.dart';
import 'dart:convert';

part 'movie_state.dart';

class MovieCubit extends Cubit<MovieState> {
  late DioApiClient _client;
  bool _clientReady = false;
  final DioApiClient? _injected;
  
  MovieCubit({DioApiClient? client})
      : _injected = client,
        super(const MovieState.initial());

  void _ensureService() {
    if (_clientReady) return;
    
    if (_injected != null) {
      _client = _injected!;
      if (!_client.isInitialized) {
        throw StateError('Injected DioApiClient is not initialized');
      }
      _clientReady = true;
      print("✅ Using injected DioApiClient");
      return;
    }
    
    // Fallback to compile-time environment only when not injected
    final key = const String.fromEnvironment('TMDB_API_KEY', defaultValue: '');
    if (key.isEmpty) {
      throw StateError('No API key available. Set TMDB_API_KEY in .env or compile-time.');
    }
    
    DioApiClient.instance.initialize(key);
    _client = DioApiClient.instance;
    _clientReady = true;
    print("✅ Using fallback DioApiClient");
  }

  Future<void> fetchMovies() async {
    try {
      _ensureService();
    } catch (e) {
      emit(state.copyWith(
        status: MovieStatus.failure, 
        errorMessage: 'Service initialization failed: $e'
      ));
      return;
    }

    emit(state.copyWith(status: MovieStatus.loading));
    
    try {
      print("🎬 Fetching discover movies (include_adult=true, page 1)...");
      
      final res = await _client.dio.get('discover/movie', 
        queryParameters: _buildQuery(page: 1),
      );
      
      print("✅ Response received: ${res.statusCode}");
      
      final data = _normalizeResponse(res);
      
      if (data['results'] is! List) {
        emit(state.copyWith(
          status: MovieStatus.failure, 
          errorMessage: 'Unexpected response format'
        ));
        return;
      }
      
      final results = (data['results'] as List).cast<Map<String, dynamic>>();
      // Debug: show adult count to confirm 18+ detection
      try {
        final adultCount = results.where((m) => m['adult'] == true).length;
        print("🔎 Adult titles in page 1: $adultCount / ${results.length}");
      } catch (_) {}
      final totalPages = data['total_pages'] as int? ?? 1;
      
      print("✅ Successfully fetched ${results.length} movies (page 1 of $totalPages)");
      
      emit(state.copyWith(
        status: MovieStatus.loaded,
        movies: results,
        currentPage: 1,
        totalPages: totalPages,
        lastFetchedItems: results,
        errorMessage: null, // Clear any previous errors
      ));
      
    } catch (e) {
      print("❌ Movie fetch failed: $e");
      emit(state.copyWith(
        status: MovieStatus.failure, 
        errorMessage: 'Failed to fetch movies: ${_getErrorMessage(e)}'
      ));
    }
  }

  Future<void> fetchNextPage() async {
    // Don't fetch if already loading or on last page
    if (state.status == MovieStatus.loading || 
        state.status == MovieStatus.loadingMore ||
        state.isLastPage) {
      print("⏸️ Skipping pagination: already loading or on last page");
      return;
    }

    try {
      _ensureService();
    } catch (e) {
      print("❌ Service not ready for pagination: $e");
      return;
    }

    final nextPage = state.currentPage + 1;
    
    emit(state.copyWith(status: MovieStatus.loadingMore));
    
    try {
      print("📄 Fetching page $nextPage of ${state.totalPages}...");
      
      Response res;
      if ((state.searchQuery ?? '').isNotEmpty) {
        res = await _client.dio.get('search/movie', queryParameters: {
          'language': 'en-US',
          'query': state.searchQuery,
          'include_adult': true,
          if (state.selectedYear != null) 'year': state.selectedYear.toString(),
          'page': nextPage.toString(),
        });
      } else {
        res = await _client.dio.get('discover/movie', 
          queryParameters: _buildQuery(page: nextPage),
        );
      }
      
      if (res.statusCode != 200) {
        print("❌ Pagination failed with status: ${res.statusCode}");
        emit(state.copyWith(status: MovieStatus.loaded)); // Revert to loaded state
        return;
      }
      
      final data = _normalizeResponse(res);
      
      if (data['results'] is! List) {
        print("❌ Pagination response format error");
        emit(state.copyWith(status: MovieStatus.loaded)); // Revert to loaded state
        return;
      }
      
      var newResults = (data['results'] as List).cast<Map<String, dynamic>>();
      if ((state.searchQuery ?? '').isNotEmpty) {
        newResults = _applyClientFilters(newResults);
      }
      final combinedMovies = [...state.movies, ...newResults];
      
      print("✅ Page $nextPage loaded: ${newResults.length} new movies");
      print("📊 Total movies now: ${combinedMovies.length}");
      
      emit(state.copyWith(
        status: MovieStatus.loaded,
        movies: combinedMovies,
        currentPage: nextPage,
        lastFetchedItems: newResults,
      ));
      
    } catch (e) {
      print("❌ Pagination failed: $e");
      // Don't change movies list, just revert loading state
      emit(state.copyWith(
        status: MovieStatus.loaded,
        errorMessage: 'Failed to load more movies: ${_getErrorMessage(e)}'
      ));
    }
  }

  Future<void> refreshMovies() async {
    print("🔄 Refreshing movies...");
    await fetchMovies();
  }

  String _getErrorMessage(dynamic error) {
    if (error.toString().contains('401')) {
      return 'Authentication failed. Please check your API token.';
    } else if (error.toString().contains('404')) {
      return 'API endpoint not found.';
    } else if (error.toString().contains('Network')) {
      return 'Network error. Please check your internet connection.';
    }
    return error.toString();
  }

  Map<String, dynamic> _normalizeResponse(Response res) {
    final body = res.data;
    if (body is Map<String, dynamic>) return body;
    if (body is Map) return Map<String, dynamic>.from(body);
    if (body is String) {
      final s = body.trim();
      if (s.isEmpty) {
        throw const FormatException('Empty response body');
      }
      return json.decode(s) as Map<String, dynamic>;
    }
    throw FormatException('Unexpected response type: ${body.runtimeType}');
  }

  void applyFilters({String? genre, double? rating, int? year}) {
    print("🔍 Applying filters - Genre: $genre, Rating: $rating, Year: $year");
    emit(state.copyWith(
      selectedGenre: genre,
      selectedRating: rating,
      selectedYear: year,
    ));
    // Restart from first page with new filters
    fetchMoviesWithCurrentFilters();
  }

  // Explicit clear helpers to override nullable fields
  void clearGenreFilter() {
    final newState = MovieState(
      status: state.status,
      selectedGenre: null,
      selectedRating: state.selectedRating,
      selectedYear: state.selectedYear,
      errorMessage: state.errorMessage,
      movies: state.movies,
      currentPage: state.currentPage,
      totalPages: state.totalPages,
      lastFetchedItems: state.lastFetchedItems,
      searchQuery: state.searchQuery,
    );
    emit(newState);
    fetchMoviesWithCurrentFilters();
  }

  void clearRatingFilter() {
    final newState = MovieState(
      status: state.status,
      selectedGenre: state.selectedGenre,
      selectedRating: null,
      selectedYear: state.selectedYear,
      errorMessage: state.errorMessage,
      movies: state.movies,
      currentPage: state.currentPage,
      totalPages: state.totalPages,
      lastFetchedItems: state.lastFetchedItems,
      searchQuery: state.searchQuery,
    );
    emit(newState);
    fetchMoviesWithCurrentFilters();
  }

  void clearYearFilter() {
    final newState = MovieState(
      status: state.status,
      selectedGenre: state.selectedGenre,
      selectedRating: state.selectedRating,
      selectedYear: null,
      errorMessage: state.errorMessage,
      movies: state.movies,
      currentPage: state.currentPage,
      totalPages: state.totalPages,
      lastFetchedItems: state.lastFetchedItems,
      searchQuery: state.searchQuery,
    );
    emit(newState);
    fetchMoviesWithCurrentFilters();
  }

  void clearFilters() {
    print("🗑️ Clearing all filters");
    emit(MovieState(
      status: state.status,
      selectedGenre: null,
      selectedRating: null,
      selectedYear: null,
      searchQuery: '',
      errorMessage: null,
      movies: state.movies,
      currentPage: 0,
      totalPages: 0,
      lastFetchedItems: const [],
    ));
    fetchMoviesWithCurrentFilters();
  }

  // Helper method to check if more pages are available
  bool get canLoadMore => !state.isLastPage && 
                         state.status != MovieStatus.loading && 
                         state.status != MovieStatus.loadingMore;

  // Helper method to get loading status info
  String get statusInfo {
    switch (state.status) {
      case MovieStatus.initial:
        return 'Ready to load movies';
      case MovieStatus.loading:
        return 'Loading movies...';
      case MovieStatus.loadingMore:
        return 'Loading more movies...';
      case MovieStatus.loaded:
        return 'Showing ${state.movies.length} movies (page ${state.currentPage} of ${state.totalPages})';
      case MovieStatus.failure:
        return 'Error: ${state.errorMessage ?? 'Unknown error'}';
    }
  }

  // Search movies (across all pages) via server-side API
  Future<void> search(String query) async {
    final trimmed = query.trim();
    emit(state.copyWith(searchQuery: trimmed));
    await fetchMoviesWithCurrentFilters();
  }

  Future<void> fetchMoviesWithCurrentFilters() async {
    try {
      _ensureService();
    } catch (e) {
      emit(state.copyWith(status: MovieStatus.failure, errorMessage: e.toString()));
      return;
    }

    emit(state.copyWith(status: MovieStatus.loading));
    try {
      Response res;
      if ((state.searchQuery ?? '').isNotEmpty) {
        res = await _client.dio.get('search/movie', queryParameters: {
          'language': 'en-US',
          'query': state.searchQuery,
          'include_adult': true,
          if (state.selectedYear != null) 'year': state.selectedYear.toString(),
          'page': '1',
        });
      } else {
        res = await _client.dio.get('discover/movie', queryParameters: _buildQuery(page: 1));
      }

      final data = _normalizeResponse(res);
      if (data['results'] is! List) {
        emit(state.copyWith(status: MovieStatus.failure, errorMessage: 'Unexpected response format'));
        return;
      }

      var results = (data['results'] as List).cast<Map<String, dynamic>>();
      if ((state.searchQuery ?? '').isNotEmpty) {
        // In search mode, TMDB doesn't support genre/rating filters, so filter client-side
        results = _applyClientFilters(results);
      }
      final totalPages = data['total_pages'] as int? ?? 1;
      emit(state.copyWith(
        status: MovieStatus.loaded,
        movies: results,
        currentPage: 1,
        totalPages: totalPages,
        lastFetchedItems: results,
      ));
    } catch (e) {
      emit(state.copyWith(status: MovieStatus.failure, errorMessage: _getErrorMessage(e)));
    }
  }

  Map<String, dynamic> _buildQuery({required int page}) {
    final Map<String, dynamic> q = {
      'language': 'en-US',
      'sort_by': 'popularity.desc',
      'include_adult': true,
      'include_video': false,
      'page': page.toString(),
    };
    // Genre filter: accept either name or numeric id string
    if ((state.selectedGenre ?? '').isNotEmpty) {
      final g = state.selectedGenre!;
      final id = _genreNameToId[g.toLowerCase()];
      if (id != null) q['with_genres'] = id.toString();
    }
    if (state.selectedYear != null) {
      q['primary_release_year'] = state.selectedYear.toString();
    }
    if (state.selectedRating != null) {
      // TMDB uses vote_average.gte for minimum rating
      q['vote_average.gte'] = state.selectedRating!.toStringAsFixed(1);
      // Also require at least some votes to avoid empty high averages
      q['vote_count.gte'] = '50';
    }
    return q;
  }

  List<Map<String, dynamic>> _applyClientFilters(List<Map<String, dynamic>> items) {
    return items.where((movie) {
      // Genre filtering by ids
      if ((state.selectedGenre ?? '').isNotEmpty) {
        final g = state.selectedGenre!.toLowerCase();
        final id = _genreNameToId[g];
        final ids = (movie['genre_ids'] as List?)?.whereType<int>().toList() ?? const [];
        if (id != null && !ids.contains(id)) {
          return false;
        }
      }

      // Rating filter
      if (state.selectedRating != null) {
        final rating = (movie['vote_average'] as num?)?.toDouble() ?? 0.0;
        if (rating < state.selectedRating!) return false;
      }

      // Year filter (search endpoint supports 'year' param, but we also double-check here)
      if (state.selectedYear != null) {
        final date = (movie['release_date'] as String?) ?? '';
        if (date.length < 4 || date.substring(0, 4) != state.selectedYear.toString()) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  static const Map<String, int> _genreNameToId = {
    'action': 28,
    'adventure': 12,
    'animation': 16,
    'comedy': 35,
    'crime': 80,
    'documentary': 99,
    'drama': 18,
    'family': 10751,
    'fantasy': 14,
    'history': 36,
    'horror': 27,
    'music': 10402,
    'mystery': 9648,
    'romance': 10749,
    'sci-fi': 878,
    'science fiction': 878,
    'tv movie': 10770,
    'thriller': 53,
    'war': 10752,
    'western': 37,
  };
}