import 'package:flutter/material.dart';
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
  });

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
            // Poster with adult badge
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                    child: SizedBox.expand(
                      child: heroTag == null
                          ? _PosterImage(url: posterUrl)
                          : Hero(
                              tag: heroTag!,
                              child: _PosterImage(url: posterUrl),
                            ),
                    ),
                  ),
                  if (isAdult)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.adultBadge,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          '18+',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
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
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                  // Title
                  Text(
                    title,
                    style: AppTextStyles.movieTitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 6),
                  
                  // Rating
                  if (showRating) ...[
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
                    const SizedBox(height: 6),
                  ],
                  
                  // Genres
                  const SizedBox(height: 2),
                  if (genres.isNotEmpty)
                    Text(
                      genres.take(2).join(', '),
                      style: AppTextStyles.caption,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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

class MovieCardHorizontal extends StatelessWidget {
  final String title;
  final String posterUrl;
  final double rating;
  final List<String> genres;
  final bool isAdult;
  final VoidCallback? onTap;

  const MovieCardHorizontal({
    super.key,
    required this.title,
    required this.posterUrl,
    required this.rating,
    required this.genres,
    this.isAdult = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 120,
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
                    width: 80,
                    height: 120,
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
                          size: 30,
                          color: AppColors.textLight,
                        ),
                      ),
                    ),
                  ),
                ),
                if (isAdult)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.adultBadge,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        '18+',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            
            // Movie info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Title
                    Text(
                      title,
                      style: AppTextStyles.movieTitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const SizedBox(height: 8),
                    
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
                    
                    const SizedBox(height: 8),
                    
                    // Genres
                    if (genres.isNotEmpty)
                      Text(
                        genres.take(2).join(', '),
                        style: AppTextStyles.caption,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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