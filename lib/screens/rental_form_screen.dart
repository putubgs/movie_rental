import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../constants/app_colors.dart';
import '../constants/text_styles.dart';
import '../widgets/custom_buttons.dart';
import '../widgets/error_widgets.dart';

class RentalFormScreen extends StatefulWidget {
  final Map<String, dynamic> movie;

  const RentalFormScreen({
    super.key,
    required this.movie,
  });

  @override
  State<RentalFormScreen> createState() => _RentalFormScreenState();
}

class _RentalFormScreenState extends State<RentalFormScreen> {
  int _selectedDuration = 1;
  bool _isLoading = false;
  bool _agreeToTerms = false;
  String? _errorMessage;

  static const double _pricePerDay = 5000.0;
  static const int _maxDuration = 7;

  double get _totalPrice => _selectedDuration * _pricePerDay;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Rent Movie'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
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
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      width: 80,
                      height: 120,
                      child: CachedNetworkImage(
                        imageUrl: widget.movie['posterUrl'],
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
                            size: 40,
                            color: AppColors.textLight,
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.movie['title'],
                          style: AppTextStyles.h4,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.star,
                              size: 16,
                              color: AppColors.rating,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${widget.movie['rating']}/10',
                              style: AppTextStyles.movieRating,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Rp${_pricePerDay.toStringAsFixed(0)}/day',
                          style: AppTextStyles.price,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            if (_errorMessage != null)
              FormErrorWidget(message: _errorMessage!),

            Text(
              'Rental Duration',
              style: AppTextStyles.h3,
            ),
            const SizedBox(height: 16),
            
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.textLight.withOpacity(0.2)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Slider(
                          value: _selectedDuration.toDouble(),
                          min: 1,
                          max: _maxDuration.toDouble(),
                          divisions: _maxDuration - 1,
                          activeColor: AppColors.primary,
                          inactiveColor: AppColors.textLight,
                          onChanged: (value) {
                            setState(() {
                              _selectedDuration = value.round();
                            });
                          },
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$_selectedDuration day${_selectedDuration > 1 ? 's' : ''}',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  Wrap(
                    spacing: 8,
                    children: List.generate(_maxDuration, (index) {
                      final duration = index + 1;
                      final isSelected = duration == _selectedDuration;
                      
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedDuration = duration;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primary : AppColors.background,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected ? AppColors.primary : AppColors.textLight,
                            ),
                          ),
                          child: Text(
                            '$duration day${duration > 1 ? 's' : ''}',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: isSelected ? Colors.white : AppColors.textSecondary,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Price per day:',
                        style: AppTextStyles.bodyMedium,
                      ),
                      Text(
                        'Rp${_pricePerDay.toStringAsFixed(0)}',
                        style: AppTextStyles.bodyMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Duration:',
                        style: AppTextStyles.bodyMedium,
                      ),
                      Text(
                        '$_selectedDuration day${_selectedDuration > 1 ? 's' : ''}',
                        style: AppTextStyles.bodyMedium,
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Price:',
                        style: AppTextStyles.h4,
                      ),
                      Text(
                        'Rp${_totalPrice.toStringAsFixed(0)}',
                        style: AppTextStyles.price,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Row(
              children: [
                Checkbox(
                  value: _agreeToTerms,
                  onChanged: (value) {
                    setState(() {
                      _agreeToTerms = value ?? false;
                    });
                  },
                  activeColor: AppColors.primary,
                ),
                Expanded(
                  child: Text(
                    'I agree to the rental terms and conditions',
                    style: AppTextStyles.bodyMedium,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            CustomButton(
              text: 'Confirm Order - Rp${_totalPrice.toStringAsFixed(0)}',
              onPressed: _agreeToTerms ? _handleConfirmOrder : null,
              isLoading: _isLoading,
              type: ButtonType.primary,
            ),

            const SizedBox(height: 16),

            Text(
              'By confirming this order, you agree to return the movie within the specified rental period. Late returns may incur additional charges.',
              style: AppTextStyles.caption,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _handleConfirmOrder() {
    if (!_agreeToTerms) {
      setState(() {
        _errorMessage = 'Please agree to the terms and conditions';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // TODO: Implement order confirmation with Cubit
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        // TODO: Show success message and navigate back
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Movie rented successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
        
        Navigator.of(context).pop();
      }
    });
  }
} 