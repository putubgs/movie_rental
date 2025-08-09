import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/text_styles.dart';

class FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Color? textColor;

  const FilterChip({
    super.key,
    required this.label,
    this.isSelected = false,
    this.onTap,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: backgroundColor ?? (isSelected ? AppColors.primary : AppColors.surface),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.textLight,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected) ...[
              const Icon(Icons.check, size: 16, color: Colors.white),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                color: textColor ?? (isSelected ? Colors.white : AppColors.textSecondary),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GenreFilterChips extends StatelessWidget {
  final List<String> genres;
  final String? selectedGenre;
  final Function(String?) onGenreSelected;

  const GenreFilterChips({
    super.key,
    required this.genres,
    this.selectedGenre,
    required this.onGenreSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          FilterChip(
            label: 'All',
            isSelected: selectedGenre == null,
            onTap: () => onGenreSelected(null),
          ),
          const SizedBox(width: 8),
          ...genres.map((genre) => Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: genre,
              isSelected: selectedGenre == genre,
              onTap: () => onGenreSelected(genre),
            ),
          )),
        ],
      ),
    );
  }
}

class RatingFilterChip extends StatelessWidget {
  final double? selectedRating;
  final Function(double?) onRatingSelected;

  const RatingFilterChip({
    super.key,
    this.selectedRating,
    required this.onRatingSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Minimum Rating',
            style: AppTextStyles.label,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Slider(
                  value: selectedRating ?? 0,
                  min: 0,
                  max: 10,
                  divisions: 20,
                  activeColor: AppColors.primary,
                  inactiveColor: AppColors.textLight,
                  onChanged: (value) => onRatingSelected(value),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${(selectedRating ?? 0).toStringAsFixed(1)}',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class YearFilterChip extends StatelessWidget {
  final int? selectedYear;
  final Function(int?) onYearSelected;

  const YearFilterChip({
    super.key,
    this.selectedYear,
    required this.onYearSelected,
  });

  @override
  Widget build(BuildContext context) {
    final currentYear = DateTime.now().year;
    final years = List.generate(10, (index) => currentYear - index);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Release Year',
            style: AppTextStyles.label,
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                FilterChip(
                  label: 'All Years',
                  isSelected: selectedYear == null,
                  onTap: () => onYearSelected(null),
                ),
                const SizedBox(width: 8),
                ...years.map((year) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: year.toString(),
                    isSelected: selectedYear == year,
                    onTap: () => onYearSelected(year),
                  ),
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class FilterSection extends StatelessWidget {
  final String title;
  final Widget child;
  final bool isExpanded;
  final VoidCallback? onToggle;

  const FilterSection({
    super.key,
    required this.title,
    required this.child,
    this.isExpanded = false,
    this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.textLight.withOpacity(0.2)),
      ),
      child: ExpansionTile(
        title: Text(
          title,
          style: AppTextStyles.h4,
        ),
        initiallyExpanded: isExpanded,
        onExpansionChanged: (expanded) => onToggle?.call(),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: child,
          ),
        ],
      ),
    );
  }
}

class ClearFiltersButton extends StatelessWidget {
  final VoidCallback? onClear;

  const ClearFiltersButton({
    super.key,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ElevatedButton(
        onPressed: onClear,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.textLight,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: const Text('Clear All Filters'),
      ),
    );
  }
} 