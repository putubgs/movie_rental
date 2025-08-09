import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../constants/app_colors.dart';
import '../constants/text_styles.dart';

class _PosterImage extends StatelessWidget {
  final String url;
  const _PosterImage({required this.url});

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        color: AppColors.background,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        color: AppColors.background,
        child: const Icon(
          Icons.movie,
          size: 50,
          color: AppColors.textLight,
        ),
      ),
    );
  }
}

class MovieCard extends StatelessWidget {
  final String title;
  final String posterUrl;
  final double rating;
  final List<String> genres;
  final bool isAdult;
  final VoidCallback? onTap;
  final bool showRating;
  final String? heroTag;
  final String? releaseDate;
  final int? movieId;

  const MovieCard({
    super.key,
    required this.title,
    required this.posterUrl,
    required this.rating,
    required this.genres,
    this.isAdult = false,
    this.onTap,
    this.showRating = true,
    this.heroTag,
    this.releaseDate,
    this.movieId,
  });

  /// Factory constructor for TMDB API data
  factory MovieCard.fromTmdbData({
    required Map<String, dynamic> movieData,
    VoidCallback? onTap,
    bool showRating = true,
    String? heroTag,
  }) {
    return MovieCard(
      title: movieData['title']?.toString() ?? 'Unknown Title',
      posterUrl: _buildPosterUrl(movieData['poster_path']),
      rating: (movieData['vote_average'] as num?)?.toDouble() ?? 0.0,
      genres: _mapGenreIds(movieData['genre_ids']),
      isAdult: movieData['adult'] == true,
      releaseDate: movieData['release_date']?.toString(),
      movieId: movieData['id'] as int?,
      onTap: onTap,
      showRating: showRating,
      heroTag: heroTag ?? movieData['id']?.toString(),
    );
  }

  /// Build full poster URL from TMDB path
  static String _buildPosterUrl(dynamic posterPath) {
    if (posterPath == null || posterPath.toString().isEmpty) {
      return '';
    }
    // TMDB image base URL with w342 size for movie cards
    return 'https://image.tmdb.org/t/p/w342$posterPath';
  }

  /// Map genre IDs to genre names (simplified mapping)
  static List<String> _mapGenreIds(dynamic genreIds) {
    if (genreIds is! List) return [];
    
    final Map<int, String> genreMap = {
      28: 'Action',
      12: 'Adventure',
      16: 'Animation',
      35: 'Comedy',
      80: 'Crime',
      99: 'Documentary',
      18: 'Drama',
      10751: 'Family',
      14: 'Fantasy',
      36: 'History',
      27: 'Horror',
      10402: 'Music',
      9648: 'Mystery',
      10749: 'Romance',
      878: 'Sci-Fi',
      10770: 'TV Movie',
      53: 'Thriller',
      10752: 'War',
      37: 'Western',
    };

    return genreIds
        .where((id) => genreMap.containsKey(id))
        .map<String>((id) => genreMap[id]!)
        .take(3) // Limit to 3 genres max
        .toList();
  }

  String get _releaseYear {
    if (releaseDate == null || releaseDate!.isEmpty) return '';
    try {
      return releaseDate!.substring(0, 4);
    } catch (e) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Poster with adult badge and rating overlay
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                    child: SizedBox.expand(
                      child: posterUrl.isEmpty
                          ? Container(
                              color: AppColors.background,
                              child: const Center(
                                child: Icon(
                                  Icons.movie,
                                  size: 50,
                                  color: AppColors.textLight,
                                ),
                              ),
                            )
                          : (heroTag == null
                              ? _PosterImage(url: posterUrl)
                              : Hero(
                                  tag: heroTag ?? posterUrl,
                                  child: _PosterImage(url: posterUrl),
                                )),
                    ),
                  ),
                  // Adult censor overlay (blur + scrim)
                  if (isAdult)
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12),
                        ),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                          child: Container(
                            color: Colors.black.withOpacity(0.25),
                            alignment: Alignment.center,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.6),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(Icons.visibility_off, color: Colors.white, size: 14),
                                  SizedBox(width: 6),
                                  Text('18+ Sensitive', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  
                  // Rating overlay (top-left)
                  if (showRating && rating > 0)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.star,
                              size: 12,
                              color: AppColors.rating,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              rating.toStringAsFixed(1),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  
                  // Note: badge moved to white info area to avoid overflow on small thumbs
                ],
              ),
            ),
            
            // Movie info
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Title row with optional Adult badge on the right (in white area)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: AppTextStyles.movieTitle,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (_releaseYear.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(
                                  _releaseYear,
                                  style: AppTextStyles.caption.copyWith(
                                    color: AppColors.textLight,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        if (isAdult)
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.adultBadge,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'Adult',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    
                    // Genres
                    if (genres.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        genres.take(2).join(' • '),
                        style: AppTextStyles.caption,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MovieCardHorizontal extends StatelessWidget {
  final String title;
  final String posterUrl;
  final double rating;
  final List<String> genres;
  final bool isAdult;
  final VoidCallback? onTap;
  final String? overview;
  final String? releaseDate;
  final int? movieId;

  const MovieCardHorizontal({
    super.key,
    required this.title,
    required this.posterUrl,
    required this.rating,
    required this.genres,
    this.isAdult = false,
    this.onTap,
    this.overview,
    this.releaseDate,
    this.movieId,
  });

  /// Factory constructor for TMDB API data
  factory MovieCardHorizontal.fromTmdbData({
    required Map<String, dynamic> movieData,
    VoidCallback? onTap,
  }) {
    return MovieCardHorizontal(
      title: movieData['title']?.toString() ?? 'Unknown Title',
      posterUrl: MovieCard._buildPosterUrl(movieData['poster_path']),
      rating: (movieData['vote_average'] as num?)?.toDouble() ?? 0.0,
      genres: MovieCard._mapGenreIds(movieData['genre_ids']),
      isAdult: movieData['adult'] == true,
      overview: movieData['overview']?.toString(),
      releaseDate: movieData['release_date']?.toString(),
      movieId: movieData['id'] as int?,
      onTap: onTap,
    );
  }

  String get _releaseYear {
    if (releaseDate == null || releaseDate!.isEmpty) return '';
    try {
      return releaseDate!.substring(0, 4);
    } catch (e) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 132,
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Poster
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(12),
                  ),
                       child: SizedBox(
                         width: 86,
                         height: 132,
                    child: posterUrl.isEmpty
                        ? Container(
                            color: AppColors.background,
                            child: const Center(
                              child: Icon(
                                Icons.movie,
                                size: 30,
                                color: AppColors.textLight,
                              ),
                            ),
                          )
                        : CachedNetworkImage(
                            imageUrl: posterUrl,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: AppColors.background,
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: AppColors.background,
                              child: const Icon(
                                Icons.movie,
                                size: 30,
                                color: AppColors.textLight,
                              ),
                            ),
                          ),
                  ),
                ),
                    // Adult censor overlay (blur + scrim) — compact label for horizontal card
                    if (isAdult)
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: const BorderRadius.horizontal(
                            left: Radius.circular(12),
                          ),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                            child: Container(
                              color: Colors.black.withOpacity(0.25),
                              alignment: Alignment.center,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.6),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Text(
                                  '18+',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                // Note: badge moved to white info area below for horizontal card
              ],
            ),
            
            // Movie info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Title and year with optional Adult badge aligned to end
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: AppTextStyles.movieTitle,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (_releaseYear.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(
                                  _releaseYear,
                                  style: AppTextStyles.caption.copyWith(
                                    color: AppColors.textLight,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        if (isAdult)
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.adultBadge,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'Adult',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    
                    // Rating and genres
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Rating
                        Row(
                          children: [
                            Icon(
                              Icons.star,
                              size: 16,
                              color: AppColors.rating,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              rating.toStringAsFixed(1),
                              style: AppTextStyles.movieRating,
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 4),
                        
                        // Genres
                        if (genres.isNotEmpty)
                          Text(
                            genres.take(3).join(' • '),
                            style: AppTextStyles.caption,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Loading card for pagination states
class MovieCardLoading extends StatelessWidget {
  const MovieCardLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Expanded(
            flex: 3,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child: Container(
                width: double.infinity,
                color: AppColors.background,
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    height: 16,
                    color: AppColors.background,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 80,
                    height: 12,
                    color: AppColors.background,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Load more button widget for pagination
class LoadMoreButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;
  final int currentPage;
  final int totalPages;

  const LoadMoreButton({
    super.key,
    this.onPressed,
    this.isLoading = false,
    this.currentPage = 0,
    this.totalPages = 0,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Container(
        padding: const EdgeInsets.all(20),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      child: Column(
        children: [
          ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
            child: Text('Load More Movies'),
          ),
          if (totalPages > 0) ...[
            const SizedBox(height: 8),
            Text(
              'Page $currentPage of $totalPages',
              style: AppTextStyles.caption,
            ),
            const SizedBox(height: 4),
            LinearProgressIndicator(
              value: currentPage / totalPages,
              backgroundColor: AppColors.background,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ],
        ],
      ),
    );
  }
}