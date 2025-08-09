import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/dio_api_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../constants/app_colors.dart';
import '../constants/text_styles.dart';
import '../widgets/custom_buttons.dart';
import 'rental_form_screen.dart';

class MovieDetailScreen extends StatelessWidget {
  final Map<String, dynamic> movie;

  const MovieDetailScreen({
    super.key,
    required this.movie,
  });

  @override
  Widget build(BuildContext context) {
    final String title = (movie['title'] ?? movie['name'] ?? '').toString();
    final String posterUrl = (movie['posterUrl'] as String?) ??
        (movie['poster_path'] != null ? 'https://image.tmdb.org/t/p/w500${movie['poster_path']}' : '');
    final double rating = ((movie['rating'] ?? movie['vote_average']) as num?)?.toDouble() ?? 0.0;
    final bool isAdult = (movie['isAdult'] as bool?) ?? (movie['adult'] as bool?) ?? false;
    final List<String> genres = _extractGenres(movie);
    final String overview = (movie['overview'] as String?)?.trim() ?? '';
    final String releaseDate = (movie['release_date'] as String?)?.trim() ?? '';
    final String releaseYear = releaseDate.isNotEmpty && releaseDate.length >= 4 ? releaseDate.substring(0, 4) : '';
    final int? runtime = (movie['runtime'] is num) ? (movie['runtime'] as num).toInt() : null; // present only on detail payload
    final String? originalLanguage = (movie['original_language'] as String?)?.toUpperCase();
    final int? movieId = (movie['id'] as num?)?.toInt();
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 400,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  posterUrl.isEmpty
                      ? Container(color: AppColors.background)
                      : Hero(
                          tag: movie['id'] != null ? 'movie-${movie['id']}' : posterUrl,
                          child: CachedNetworkImage(
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
                                size: 100,
                                color: AppColors.textLight,
                              ),
                            ),
                          ),
                        ),
                  // Censor blur overlay for adult titles
                  if (isAdult)
                    Positioned.fill(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                        child: Container(
                          color: Colors.black.withOpacity(0.25),
                          alignment: Alignment.center,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              '18+ Sensitive',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                  
                  if (isAdult)
                    Positioned(
                      top: 60,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.adultBadge,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Adult',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                       Expanded(
                         child: Text(
                           title,
                           style: AppTextStyles.h2,
                         ),
                       ),
                      const SizedBox(width: 16),
                      Column(
                        children: [
                          RatingBarIndicator(
                            rating: (rating / 2).clamp(0, 5), // Convert 10-scale to 5-scale
                            itemBuilder: (context, index) => const Icon(
                              Icons.star,
                              color: AppColors.rating,
                            ),
                            itemCount: 5,
                            itemSize: 20,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${rating.toStringAsFixed(1)}/10',
                            style: AppTextStyles.movieRating,
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                   Wrap(
                    spacing: 8,
                    children: genres.map<Widget>((genre) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          genre.toString(),
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 24),

                  Text(
                    'Synopsis',
                    style: AppTextStyles.h3,
                  ),
                  const SizedBox(height: 8),
                  SynopsisText(text: overview.isNotEmpty ? overview : 'No overview available.'),

                  const SizedBox(height: 32),

                  if (releaseYear.isNotEmpty)
                    _buildDetailRow('Release Year', releaseYear),
                  if (runtime != null && runtime > 0)
                    _buildDetailRow('Duration', _formatRuntime(runtime)),
                  if (originalLanguage != null && originalLanguage.isNotEmpty)
                    _buildDetailRow('Language', originalLanguage),
                  // Cast (fetched on demand from /movie/{id}/credits)
                  if (movieId != null)
                    FutureBuilder<List<String>>(
                      future: _fetchTopCast(movieId),
                      builder: (context, snapshot) {
                        final cast = snapshot.data ?? const <String>[];
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return _buildDetailRow('Cast', 'Loading…');
                        }
                        if (cast.isEmpty) {
                          return _buildDetailRow('Cast', 'N/A');
                        }
                        return _buildDetailRow('Cast', cast.join(', '));
                      },
                    ),

                  const SizedBox(height: 32),

                  RentButton(
                    price: 5000.0,
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => RentalFormScreen(movie: movie),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<String> _extractGenres(Map<String, dynamic> movie) {
    // If full genre objects present: [{'id':..,'name':..}, ...]
    if (movie['genres'] is List) {
      final List list = movie['genres'] as List;
      return list
          .map((e) => e is Map && e['name'] != null ? e['name'].toString() : null)
          .whereType<String>()
          .take(5)
          .toList();
    }
    // If only genre_ids present, reuse the short mapping used in MovieCard
    if (movie['genre_ids'] is List) {
      final ids = (movie['genre_ids'] as List).whereType<int>();
      const genreMap = {
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
      return ids.where(genreMap.containsKey).map((id) => genreMap[id]!).take(5).toList();
    }
    return const [];
  }

  String _formatRuntime(int minutes) {
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    if (hours > 0 && mins > 0) return '${hours}h ${mins}m';
    if (hours > 0) return '${hours}h';
    return '${mins}m';
  }

  Future<List<String>> _fetchTopCast(int movieId) async {
    try {
      final dio = DioApiClient.instance.dio;
      final Response res = await dio.get('movie/$movieId/credits');
      final data = res.data;
      if (data is Map && data['cast'] is List) {
        final List cast = data['cast'] as List;
        return cast
            .whereType<Map>()
            .map((m) => m['name'])
            .whereType<String>()
            .take(5)
            .toList();
      }
    } catch (_) {}
    return const <String>[];
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: AppTextStyles.label,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  String _getSynopsis(String title) {
    // Deprecated dummy synopsis; kept as fallback only
    return 'No overview available.';
  }
} 

class SynopsisText extends StatelessWidget {
  final String text;
  const SynopsisText({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTextStyles.bodyLarge.copyWith(
        color: AppColors.textSecondary,
        height: 1.6,
      ),
    );
  }
}