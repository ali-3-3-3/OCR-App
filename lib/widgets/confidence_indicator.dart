import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class ConfidenceIndicator extends StatelessWidget {
  final double confidence;
  final bool showLabel;
  final double size;

  const ConfidenceIndicator({
    super.key,
    required this.confidence,
    this.showLabel = true,
    this.size = 24,
  });

  @override
  Widget build(BuildContext context) {
    final confidenceLevel = _getConfidenceLevel(confidence);
    final color = _getConfidenceColor(confidenceLevel);
    final icon = _getConfidenceIcon(confidenceLevel);
    final label = _getConfidenceLabel(confidenceLevel);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Icon(
            icon,
            color: color,
            size: size * 0.8,
          ),
        ),
        if (showLabel) ...[
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: size * 0.6,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
              Text(
                '${(confidence * 100).toInt()}%',
                style: TextStyle(
                  fontSize: size * 0.5,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  ConfidenceLevel _getConfidenceLevel(double confidence) {
    if (confidence >= 0.8) {
      return ConfidenceLevel.high;
    } else if (confidence >= 0.6) {
      return ConfidenceLevel.medium;
    } else {
      return ConfidenceLevel.low;
    }
  }

  Color _getConfidenceColor(ConfidenceLevel level) {
    switch (level) {
      case ConfidenceLevel.high:
        return AppColors.highConfidence;
      case ConfidenceLevel.medium:
        return AppColors.mediumConfidence;
      case ConfidenceLevel.low:
        return AppColors.lowConfidence;
    }
  }

  IconData _getConfidenceIcon(ConfidenceLevel level) {
    switch (level) {
      case ConfidenceLevel.high:
        return Icons.check_circle;
      case ConfidenceLevel.medium:
        return Icons.warning;
      case ConfidenceLevel.low:
        return Icons.error;
    }
  }

  String _getConfidenceLabel(ConfidenceLevel level) {
    switch (level) {
      case ConfidenceLevel.high:
        return 'High Confidence';
      case ConfidenceLevel.medium:
        return 'Medium Confidence';
      case ConfidenceLevel.low:
        return 'Low Confidence';
    }
  }
}

// Circular confidence indicator
class CircularConfidenceIndicator extends StatelessWidget {
  final double confidence;
  final double size;
  final bool showPercentage;

  const CircularConfidenceIndicator({
    super.key,
    required this.confidence,
    this.size = 60,
    this.showPercentage = true,
  });

  @override
  Widget build(BuildContext context) {
    final confidenceLevel = _getConfidenceLevel(confidence);
    final color = _getConfidenceColor(confidenceLevel);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          // Background circle
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(0.1),
              border: Border.all(
                color: color.withOpacity(0.3),
                width: 2,
              ),
            ),
          ),
          
          // Progress indicator
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: confidence,
              strokeWidth: 4,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          
          // Center content
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _getConfidenceIcon(confidenceLevel),
                  color: color,
                  size: size * 0.3,
                ),
                if (showPercentage) ...[
                  const SizedBox(height: 2),
                  Text(
                    '${(confidence * 100).toInt()}%',
                    style: TextStyle(
                      fontSize: size * 0.15,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  ConfidenceLevel _getConfidenceLevel(double confidence) {
    if (confidence >= 0.8) {
      return ConfidenceLevel.high;
    } else if (confidence >= 0.6) {
      return ConfidenceLevel.medium;
    } else {
      return ConfidenceLevel.low;
    }
  }

  Color _getConfidenceColor(ConfidenceLevel level) {
    switch (level) {
      case ConfidenceLevel.high:
        return AppColors.highConfidence;
      case ConfidenceLevel.medium:
        return AppColors.mediumConfidence;
      case ConfidenceLevel.low:
        return AppColors.lowConfidence;
    }
  }

  IconData _getConfidenceIcon(ConfidenceLevel level) {
    switch (level) {
      case ConfidenceLevel.high:
        return Icons.check_circle;
      case ConfidenceLevel.medium:
        return Icons.warning;
      case ConfidenceLevel.low:
        return Icons.error;
    }
  }
}

// Simple confidence bar
class ConfidenceBar extends StatelessWidget {
  final double confidence;
  final double width;
  final double height;
  final bool showLabel;

  const ConfidenceBar({
    super.key,
    required this.confidence,
    this.width = 100,
    this.height = 8,
    this.showLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    final confidenceLevel = _getConfidenceLevel(confidence);
    final color = _getConfidenceColor(confidenceLevel);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showLabel) ...[
          Text(
            'Confidence: ${(confidence * 100).toInt()}%',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
        ],
        Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: AppColors.greyLight,
            borderRadius: BorderRadius.circular(height / 2),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: confidence.clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(height / 2),
              ),
            ),
          ),
        ),
      ],
    );
  }

  ConfidenceLevel _getConfidenceLevel(double confidence) {
    if (confidence >= 0.8) {
      return ConfidenceLevel.high;
    } else if (confidence >= 0.6) {
      return ConfidenceLevel.medium;
    } else {
      return ConfidenceLevel.low;
    }
  }

  Color _getConfidenceColor(ConfidenceLevel level) {
    switch (level) {
      case ConfidenceLevel.high:
        return AppColors.highConfidence;
      case ConfidenceLevel.medium:
        return AppColors.mediumConfidence;
      case ConfidenceLevel.low:
        return AppColors.lowConfidence;
    }
  }
}

enum ConfidenceLevel {
  high,
  medium,
  low,
}
