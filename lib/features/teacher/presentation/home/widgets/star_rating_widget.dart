import 'package:flutter/material.dart';

class StarRatingWidget extends StatelessWidget {
  final int rating; // 1 to 4 (0 = not rated)
  final ValueChanged<int> onRatingChanged;
  final double starSize;
  final bool showLabel;

  const StarRatingWidget({
    super.key,
    required this.rating,
    required this.onRatingChanged,
    this.starSize = 30.0,
    this.showLabel = true,
  });

  static const List<String> _ratingLabels = [
    'Not Rated',
    'Emerging (1)',
    'Developing (2)',
    'Proficient (3)',
    'Exemplary (4)',
  ];

  static const List<Color> _ratingColors = [
    Colors.grey,
    Color(0xFFE57373), // soft red
    Color(0xFFFFB74D), // orange
    Color(0xFF4FC3F7), // sky blue
    Color(0xFF81C784), // green
  ];

  @override
  Widget build(BuildContext context) {
    final validRating = (rating >= 0 && rating <= 4) ? rating : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(4, (index) {
            final starNumber = index + 1;
            final isFilled = starNumber <= validRating;

            return InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                if (validRating == starNumber) {
                  // If tapped again, can reset to 0
                  onRatingChanged(0);
                } else {
                  onRatingChanged(starNumber);
                }
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
                child: AnimatedScale(
                  scale: isFilled ? 1.08 : 1.0,
                  duration: const Duration(milliseconds: 150),
                  child: Icon(
                    isFilled ? Icons.star_rounded : Icons.star_outline_rounded,
                    color: isFilled ? const Color(0xFFFFB300) : Colors.grey.shade400,
                    size: starSize,
                  ),
                ),
              ),
            );
          }),
        ),
        if (showLabel && validRating > 0) ...[
          const SizedBox(height: 2),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(
              _ratingLabels[validRating],
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: _ratingColors[validRating],
              ),
            ),
          ),
        ],
      ],
    );
  }
}
