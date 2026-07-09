import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:unilink/utils/test_utils.dart';

class ProfileImage extends StatelessWidget {
  final String imageUrl;
  final double size;
  final String? placeholderText;
  final Color? backgroundColor;
  final Color? textColor;

  const ProfileImage({
    super.key,
    required this.imageUrl,
    this.size = 40,
    this.placeholderText,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (imageUrl.isEmpty) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: backgroundColor ?? colorScheme.primary.withValues(alpha: 0.1),
        ),
        child: Center(
          child: Text(
            placeholderText ?? '?',
            style: TextStyle(
              fontSize: size * 0.4,
              fontWeight: FontWeight.bold,
              color: textColor ?? colorScheme.primary,
            ),
          ),
        ),
      );
    }

    final bool isSvg = imageUrl.endsWith('.svg') || imageUrl.contains('dicebear');

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: backgroundColor ?? colorScheme.primary.withValues(alpha: 0.1),
      ),
      child: ClipOval(
        child: isSvg
            ? _buildSvg(colorScheme)
            : CachedNetworkImage(
                imageUrl: imageUrl,
                width: size,
                height: size,
                fit: BoxFit.cover,
                placeholder: (context, url) => const Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                errorWidget: (context, url, error) => Icon(
                  Icons.person,
                  size: size * 0.6,
                  color: colorScheme.primary,
                ),
              ),
      ),
    );
  }

  Widget _buildSvg(ColorScheme colorScheme) {
    // Skip real SVG rendering during automated widget tests to avoid Bad State crashes
    if (TestUtils.isWidgetTest()) {
      return Icon(Icons.face, size: size * 0.8, color: colorScheme.primary);
    }

    return SvgPicture.network(
      imageUrl,
      width: size,
      height: size,
      placeholderBuilder: (context) => const Center(
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
      errorBuilder: (context, error, stackTrace) => Icon(
        Icons.face,
        size: size * 0.6,
        color: colorScheme.primary,
      ),
    );
  }
}
