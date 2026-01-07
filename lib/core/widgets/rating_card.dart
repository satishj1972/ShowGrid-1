// lib/core/widgets/rating_card.dart
// Tinder-style rating card for entries

import 'package:flutter/material.dart';
import '../theme/sg_colors.dart';

class RatingCard extends StatefulWidget {
  final String entryId;
  final String mediaUrl;
  final String? thumbnailUrl;
  final String userName;
  final String gridType;
  final String mediaType;
  final double? aiScore;
  final Function(double rating) onRate;
  final VoidCallback onSkip;

  const RatingCard({
    super.key,
    required this.entryId,
    required this.mediaUrl,
    this.thumbnailUrl,
    required this.userName,
    required this.gridType,
    required this.mediaType,
    this.aiScore,
    required this.onRate,
    required this.onSkip,
  });

  @override
  State<RatingCard> createState() => _RatingCardState();
}

class _RatingCardState extends State<RatingCard> {
  double _selectedRating = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: SGColors.htmlGlass,
        border: Border.all(color: SGColors.borderSubtle),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Media preview
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Image/Video thumbnail
                  Image.network(
                    widget.thumbnailUrl ?? widget.mediaUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: _getGridColor(widget.gridType).withOpacity(0.3),
                      child: Icon(
                        widget.mediaType == 'audio' ? Icons.headphones : Icons.image,
                        size: 60,
                        color: _getGridColor(widget.gridType),
                      ),
                    ),
                  ),

                  // Gradient overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                        stops: const [0.6, 1.0],
                      ),
                    ),
                  ),

                  // Grid type badge
                  Positioned(
                    top: 16,
                    left: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: _getGridColor(widget.gridType),
                      ),
                      child: Text(
                        widget.gridType.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),

                  // AI Score badge
                  if (widget.aiScore != null)
                    Positioned(
                      top: 16,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.black54,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.auto_awesome, size: 14, color: SGColors.htmlGold),
                            const SizedBox(width: 4),
                            Text(
                              widget.aiScore!.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Video/Audio icon
                  if (widget.mediaType == 'video')
                    const Center(
                      child: Icon(Icons.play_circle_fill, size: 60, color: Colors.white70),
                    ),

                  // User info
                  Positioned(
                    bottom: 16,
                    left: 16,
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: _getGridColor(widget.gridType),
                          child: Text(
                            widget.userName[0].toUpperCase(),
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          widget.userName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Rating section
          Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Text(
                  'How would you rate this?',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                ),
                const SizedBox(height: 16),

                // Rating slider
                Row(
                  children: [
                    const Text('1', style: TextStyle(color: SGColors.htmlMuted)),
                    Expanded(
                      child: SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: _getRatingColor(_selectedRating),
                          inactiveTrackColor: SGColors.borderSubtle,
                          thumbColor: _getRatingColor(_selectedRating),
                          overlayColor: _getRatingColor(_selectedRating).withOpacity(0.2),
                          trackHeight: 6,
                        ),
                        child: Slider(
                          value: _selectedRating,
                          min: 0,
                          max: 10,
                          divisions: 20,
                          onChanged: (value) => setState(() => _selectedRating = value),
                        ),
                      ),
                    ),
                    const Text('10', style: TextStyle(color: SGColors.htmlMuted)),
                  ],
                ),

                // Selected rating display
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: _getRatingColor(_selectedRating).withOpacity(0.2),
                  ),
                  child: Text(
                    _selectedRating == 0 ? 'Slide to rate' : _selectedRating.toStringAsFixed(1),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: _selectedRating == 0 ? SGColors.htmlMuted : _getRatingColor(_selectedRating),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Action buttons
                Row(
                  children: [
                    // Skip button
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: widget.onSkip,
                        icon: const Icon(Icons.skip_next),
                        label: const Text('Skip'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: SGColors.htmlMuted,
                          side: const BorderSide(color: SGColors.borderSubtle),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Submit button
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        onPressed: _selectedRating > 0 ? () => widget.onRate(_selectedRating) : null,
                        icon: const Icon(Icons.star),
                        label: const Text('Submit Rating'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: SGColors.htmlViolet,
                          disabledBackgroundColor: SGColors.htmlViolet.withOpacity(0.3),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getGridColor(String gridType) {
    switch (gridType) {
      case 'fortune': return SGColors.htmlGold;
      case 'fanverse': return SGColors.htmlPink;
      case 'gridvoice': return SGColors.htmlGreen;
      default: return SGColors.htmlViolet;
    }
  }

  Color _getRatingColor(double rating) {
    if (rating >= 8) return SGColors.htmlGreen;
    if (rating >= 6) return SGColors.htmlCyan;
    if (rating >= 4) return SGColors.htmlGold;
    return Colors.redAccent;
  }
}
