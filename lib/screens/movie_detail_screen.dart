import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
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
                  Hero(
                    tag: 'movie-${movie['id']}',
                    child: CachedNetworkImage(
                      imageUrl: movie['posterUrl'],
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
                  
                  if (movie['isAdult'])
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
                          '18+',
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
                          movie['title'],
                          style: AppTextStyles.h2,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        children: [
                          RatingBarIndicator(
                            rating: movie['rating'] / 2, // Convert 10-scale to 5-scale
                            itemBuilder: (context, index) => const Icon(
                              Icons.star,
                              color: AppColors.rating,
                            ),
                            itemCount: 5,
                            itemSize: 20,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${movie['rating']}/10',
                            style: AppTextStyles.movieRating,
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  Wrap(
                    spacing: 8,
                    children: movie['genres'].map<Widget>((genre) {
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
                          genre,
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
                  _Synopsis(text: _getSynopsis(movie['title'])),

                  const SizedBox(height: 32),

                  _buildDetailRow('Release Year', '2023'),
                  _buildDetailRow('Duration', '2h 15m'),
                  _buildDetailRow('Director', 'Christopher Nolan'),
                  _buildDetailRow('Cast', 'Leonardo DiCaprio, Joseph Gordon-Levitt'),

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
    switch (title) {
      case 'The Shawshank Redemption':
        return 'Two imprisoned men bond over a number of years, finding solace and eventual redemption through acts of common decency.';
      case 'The Godfather':
        return 'The aging patriarch of an organized crime dynasty transfers control of his clandestine empire to his reluctant son.';
      case 'Pulp Fiction':
        return 'The lives of two mob hitmen, a boxer, a gangster and his wife, and a pair of diner bandits intertwine in four tales of violence and redemption.';
      case 'The Dark Knight':
        return 'When the menace known as the Joker wreaks havoc and chaos on the people of Gotham, Batman must accept one of the greatest psychological and physical tests of his ability to fight injustice.';
      case 'Fight Club':
        return 'An insomniac office worker and a devil-may-care soapmaker form an underground fight club that evolves into something much, much more.';
      case 'Inception':
        return 'A thief who steals corporate secrets through the use of dream-sharing technology is given the inverse task of planting an idea into the mind of a C.E.O.';
      default:
        return 'A compelling story that explores themes of redemption, friendship, and the human condition. This film has captivated audiences worldwide with its powerful narrative and outstanding performances.';
    }
  }
} 

class _Synopsis extends StatefulWidget {
  final String text;
  const _Synopsis({required this.text});

  @override
  State<_Synopsis> createState() => _SynopsisState();
}

class _SynopsisState extends State<_Synopsis> {
  bool _expanded = false;
  static const int _trimLines = 5;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 200),
          firstChild: Text(
            widget.text,
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textSecondary,
              height: 1.6,
            ),
            maxLines: _trimLines,
            overflow: TextOverflow.ellipsis,
          ),
          secondChild: Text(
            widget.text,
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
          crossFadeState:
              _expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () => setState(() => _expanded = !_expanded),
          child: Text(_expanded ? 'Show less' : 'Read more'),
        ),
      ],
    );
  }
}