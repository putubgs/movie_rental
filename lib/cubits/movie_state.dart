part of 'movie_cubit.dart';

enum MovieStatus { initial, loading, loadingMore, loaded, failure }

class MovieState extends Equatable {
  final MovieStatus status;
  final String? selectedGenre;
  final double? selectedRating;
  final int? selectedYear;
  final String? searchQuery;
  final String? errorMessage;
  final List<Map<String, dynamic>> movies;
  final int currentPage;
  final int totalPages;
  final List<Map<String, dynamic>> lastFetchedItems;

  const MovieState({
    required this.status,
    this.selectedGenre,
    this.selectedRating,
    this.selectedYear,
    this.searchQuery,
    this.errorMessage,
    this.movies = const [],
    this.currentPage = 0,
    this.totalPages = 0,
    this.lastFetchedItems = const [],
  });

  const MovieState.initial() : this(status: MovieStatus.initial);

  MovieState copyWith({
    MovieStatus? status,
    String? selectedGenre,
    double? selectedRating,
    int? selectedYear,
    String? searchQuery,
    String? errorMessage,
    List<Map<String, dynamic>>? movies,
    int? currentPage,
    int? totalPages,
    List<Map<String, dynamic>>? lastFetchedItems,
  }) {
    return MovieState(
      status: status ?? this.status,
      selectedGenre: selectedGenre ?? this.selectedGenre,
      selectedRating: selectedRating ?? this.selectedRating,
      selectedYear: selectedYear ?? this.selectedYear,
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: errorMessage ?? this.errorMessage,
      movies: movies ?? this.movies,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      lastFetchedItems: lastFetchedItems ?? this.lastFetchedItems,
    );
  }

  bool get isLastPage => currentPage >= totalPages && totalPages > 0;
  bool get hasMovies => movies.isNotEmpty;
  bool get isLoadingMore => status == MovieStatus.loadingMore;
  bool get isLoading => status == MovieStatus.loading;
  bool get hasError => status == MovieStatus.failure;
  bool get canLoadMore => !isLastPage && !isLoading && !isLoadingMore && totalPages > 0;
  
  // Progress percentage for pagination
  double get loadingProgress => totalPages > 0 ? currentPage / totalPages : 0.0;

  @override
  List<Object?> get props => [
        status,
        selectedGenre,
        selectedRating,
        selectedYear,
        searchQuery,
        errorMessage,
        movies,
        currentPage,
        totalPages,
        lastFetchedItems,
      ];
}