import 'package:flutter/material.dart';

class WeaponImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final double iconSize;

  const WeaponImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.iconSize = 48,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBorderRadius = borderRadius ?? BorderRadius.zero;
    
    return ClipRRect(
      borderRadius: effectiveBorderRadius,
      child: imageUrl.isNotEmpty
          ? Image.network(
              imageUrl,
              width: width,
              height: height,
              fit: fit,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return _buildPlaceholder(context, isLoading: true);
              },
              errorBuilder: (context, error, stackTrace) => _buildPlaceholder(context, isError: true),
            )
          : _buildPlaceholder(context),
    );
  }

  Widget _buildPlaceholder(BuildContext context, {bool isError = false, bool isLoading = false}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  const Color(0xFF2C2C2E),
                  const Color(0xFF1C1C1E),
                ]
              : [
                  const Color(0xFFF2F2F7),
                  const Color(0xFFE5E5EA),
                ],
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Large faint background icon
          Opacity(
            opacity: 0.03,
            child: Icon(
              Icons.shield_rounded,
              size: (height ?? 100) * 0.8,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          // Main icon
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isError 
                  ? Icons.broken_image_outlined 
                  : (isLoading ? Icons.image_outlined : Icons.inventory_2_outlined),
                size: iconSize,
                color: isDark ? Colors.white24 : Colors.black12,
              ),
              if (isLoading) ...[
                const SizedBox(height: 8),
                SizedBox(
                  width: iconSize * 0.5,
                  child: LinearProgressIndicator(
                    backgroundColor: isDark ? Colors.white10 : Colors.black12,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isDark ? Colors.white24 : Colors.black12,
                    ),
                    minHeight: 2,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
