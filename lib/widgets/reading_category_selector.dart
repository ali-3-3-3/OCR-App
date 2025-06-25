import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../constants/app_colors.dart';

class ReadingCategorySelector extends StatelessWidget {
  final ReadingCategory selectedCategory;
  final ValueChanged<ReadingCategory> onCategoryChanged;

  const ReadingCategorySelector({
    super.key,
    required this.selectedCategory,
    required this.onCategoryChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: ReadingCategory.values
          .map((category) => _buildCategoryChip(category))
          .toList(),
    );
  }

  Widget _buildCategoryChip(ReadingCategory category) {
    final isSelected = category == selectedCategory;
    
    return FilterChip(
      label: Text(category.displayName),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          onCategoryChanged(category);
        }
      },
      selectedColor: AppColors.primary.withOpacity(0.2),
      checkmarkColor: AppColors.primary,
      side: BorderSide(
        color: isSelected ? AppColors.primary : AppColors.greyLight,
      ),
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primary : AppColors.textSecondary,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }
}

// Expanded version for settings or detailed selection
class ReadingCategorySelectorExpanded extends StatelessWidget {
  final ReadingCategory selectedCategory;
  final ValueChanged<ReadingCategory> onCategoryChanged;

  const ReadingCategorySelectorExpanded({
    super.key,
    required this.selectedCategory,
    required this.onCategoryChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Reading Category',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        ...ReadingCategory.values
            .map((category) => _buildCategoryTile(context, category))
            ,
      ],
    );
  }

  Widget _buildCategoryTile(BuildContext context, ReadingCategory category) {
    final isSelected = category == selectedCategory;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => onCategoryChanged(category),
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        child: Container(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary.withOpacity(0.1) : null,
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.greyLight,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.greyLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getCategoryIcon(category),
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.displayName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: isSelected ? AppColors.primary : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _getCategoryDescription(category),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                const Icon(
                  Icons.check_circle,
                  color: AppColors.primary,
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(ReadingCategory category) {
    switch (category) {
      case ReadingCategory.morning:
        return Icons.wb_sunny;
      case ReadingCategory.afternoon:
        return Icons.wb_sunny_outlined;
      case ReadingCategory.evening:
        return Icons.nights_stay;
      case ReadingCategory.beforeMedication:
        return Icons.medication;
      case ReadingCategory.afterMedication:
        return Icons.medication_liquid;
      case ReadingCategory.beforeExercise:
        return Icons.fitness_center;
      case ReadingCategory.afterExercise:
        return Icons.self_improvement;
      case ReadingCategory.other:
        return Icons.more_horiz;
    }
  }

  String _getCategoryDescription(ReadingCategory category) {
    switch (category) {
      case ReadingCategory.morning:
        return 'Morning readings (6 AM - 12 PM)';
      case ReadingCategory.afternoon:
        return 'Afternoon readings (12 PM - 6 PM)';
      case ReadingCategory.evening:
        return 'Evening readings (6 PM - 12 AM)';
      case ReadingCategory.beforeMedication:
        return 'Taken before medication';
      case ReadingCategory.afterMedication:
        return 'Taken after medication';
      case ReadingCategory.beforeExercise:
        return 'Taken before physical activity';
      case ReadingCategory.afterExercise:
        return 'Taken after physical activity';
      case ReadingCategory.other:
        return 'Other or unspecified timing';
    }
  }
}

// Quick category selector for common scenarios
class QuickCategorySelector extends StatelessWidget {
  final ReadingCategory selectedCategory;
  final ValueChanged<ReadingCategory> onCategoryChanged;

  const QuickCategorySelector({
    super.key,
    required this.selectedCategory,
    required this.onCategoryChanged,
  });

  @override
  Widget build(BuildContext context) {
    // Show only the most common categories
    final commonCategories = [
      ReadingCategory.morning,
      ReadingCategory.afternoon,
      ReadingCategory.evening,
      ReadingCategory.beforeMedication,
      ReadingCategory.afterMedication,
      ReadingCategory.other,
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: commonCategories
            .map((category) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _buildQuickCategoryChip(category),
            ))
            .toList(),
      ),
    );
  }

  Widget _buildQuickCategoryChip(ReadingCategory category) {
    final isSelected = category == selectedCategory;
    
    return GestureDetector(
      onTap: () => onCategoryChanged(category),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.greyLight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getCategoryIcon(category),
              size: 16,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
            const SizedBox(width: 4),
            Text(
              _getShortDisplayName(category),
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? Colors.white : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(ReadingCategory category) {
    switch (category) {
      case ReadingCategory.morning:
        return Icons.wb_sunny;
      case ReadingCategory.afternoon:
        return Icons.wb_sunny_outlined;
      case ReadingCategory.evening:
        return Icons.nights_stay;
      case ReadingCategory.beforeMedication:
        return Icons.medication;
      case ReadingCategory.afterMedication:
        return Icons.medication_liquid;
      case ReadingCategory.beforeExercise:
        return Icons.fitness_center;
      case ReadingCategory.afterExercise:
        return Icons.self_improvement;
      case ReadingCategory.other:
        return Icons.more_horiz;
    }
  }

  String _getShortDisplayName(ReadingCategory category) {
    switch (category) {
      case ReadingCategory.morning:
        return 'Morning';
      case ReadingCategory.afternoon:
        return 'Afternoon';
      case ReadingCategory.evening:
        return 'Evening';
      case ReadingCategory.beforeMedication:
        return 'Before Meds';
      case ReadingCategory.afterMedication:
        return 'After Meds';
      case ReadingCategory.beforeExercise:
        return 'Before Exercise';
      case ReadingCategory.afterExercise:
        return 'After Exercise';
      case ReadingCategory.other:
        return 'Other';
    }
  }
}
