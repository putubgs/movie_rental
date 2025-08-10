import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/text_styles.dart';
import '../widgets/filter_chips.dart';
import '../widgets/custom_buttons.dart';

class FilterScreen extends StatefulWidget {
  final String? selectedGenre;
  final double? selectedRating;
  final int? selectedYear;
  final Function(String?, double?, int?) onApplyFilters;

  const FilterScreen({
    super.key,
    this.selectedGenre,
    this.selectedRating,
    this.selectedYear,
    required this.onApplyFilters,
  });

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  late String? _selectedGenre;
  late double? _selectedRating;
  late int? _selectedYear;

  final List<String> _genres = [
    'Action',
    'Adventure',
    'Animation',
    'Comedy',
    'Crime',
    'Documentary',
    'Drama',
    'Family',
    'Fantasy',
    'History',
    'Horror',
    'Music',
    'Mystery',
    'Romance',
    'Sci-Fi',
    'Thriller',
    'War',
    'Western',
  ];

  @override
  void initState() {
    super.initState();
    _selectedGenre = widget.selectedGenre;
    _selectedRating = widget.selectedRating;
    _selectedYear = widget.selectedYear;
  }

  void _applyFilters() {
    widget.onApplyFilters(_selectedGenre, _selectedRating, _selectedYear);
    Navigator.of(context).pop();
  }

  void _clearFilters() {
    setState(() {
      _selectedGenre = null;
      _selectedRating = null;
      _selectedYear = null;
    });
  }

  void _applyAndClose() {
    _applyFilters();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Filters'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(44),
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            alignment: Alignment.centerLeft,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (_selectedGenre != null)
                  _ActivePill(
                    label: _selectedGenre!,
                    onClear: () => setState(() => _selectedGenre = null),
                  ),
                if (_selectedRating != null)
                  _ActivePill(
                    label: '≥ ${_selectedRating!.toStringAsFixed(1)}',
                    onClear: () => setState(() => _selectedRating = null),
                  ),
                if (_selectedYear != null)
                  _ActivePill(
                    label: _selectedYear.toString(),
                    onClear: () => setState(() => _selectedYear = null),
                  ),
                if (_selectedGenre == null && _selectedRating == null && _selectedYear == null)
                  const Text('No active filters'),
              ],
            ),
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Clear all',
            onPressed: _clearFilters,
            icon: const Icon(Icons.clear_all),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FilterSection(
                    title: 'Genre',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GenreFilterChips(
                          genres: _genres,
                          selectedGenre: _selectedGenre,
                          onGenreSelected: (genre) {
                            setState(() {
                              _selectedGenre = genre;
                            });
                          },
                        ),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            onPressed: () => setState(() => _selectedGenre = null),
                            icon: const Icon(Icons.restart_alt),
                            label: const Text('Reset genre'),
                          ),
                        ),
                      ],
                    ),
                  ),

                  FilterSection(
                    title: 'Rating',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RatingFilterChip(
                          selectedRating: _selectedRating,
                          onRatingSelected: (rating) {
                            setState(() {
                              _selectedRating = rating;
                            });
                          },
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Selected: ${(_selectedRating ?? 0).toStringAsFixed(1)}'),
                            TextButton(
                              onPressed: () => setState(() => _selectedRating = null),
                              child: const Text('Reset rating'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  FilterSection(
                    title: 'Release Year',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        YearFilterChip(
                          selectedYear: _selectedYear,
                          onYearSelected: (year) {
                            setState(() {
                              _selectedYear = year;
                            });
                          },
                        ),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () => setState(() => _selectedYear = null),
                            child: const Text('Reset year'),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _clearFilters,
                icon: const Icon(Icons.refresh),
                label: const Text('Reset All'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: _applyAndClose,
                icon: const Icon(Icons.check),
                label: const Text('Apply Filters'),
              ),
            ),
          ],
        ),
          ),
        ],
      ),
    );
  }
} 

class _ActivePill extends StatelessWidget {
  final String label;
  final VoidCallback onClear;

  const _ActivePill({required this.label, required this.onClear});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onClear,
            child: const Icon(Icons.close, size: 16, color: AppColors.primary),
          ),
        ],
      ),
    );
  }
}