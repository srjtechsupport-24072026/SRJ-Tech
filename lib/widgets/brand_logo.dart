import 'package:flutter/material.dart';

import '../core/brand/brand_assets.dart';

enum BrandLogoStyle { mark, full }

/// SRJ Tech logo from brand assets.
class BrandLogo extends StatelessWidget {
  const BrandLogo({
    super.key,
    this.height = 40,
    this.style = BrandLogoStyle.full,
    this.heroTag,
  });

  final double height;
  final BrandLogoStyle style;
  final String? heroTag;

  @override
  Widget build(BuildContext context) {
    final image = Image.asset(
      BrandAssets.logo,
      height: height,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
      semanticLabel: 'SRJ Tech logo',
    );

    final child = style == BrandLogoStyle.mark
        ? ClipRRect(
            borderRadius: BorderRadius.circular(height * 0.18),
            child: SizedBox(
              width: height,
              height: height,
              child: Image.asset(
                BrandAssets.logo,
                fit: BoxFit.cover,
                alignment: Alignment.center,
                filterQuality: FilterQuality.high,
                semanticLabel: 'SRJ Tech logo',
              ),
            ),
          )
        : image;

    if (heroTag == null) return child;
    return Hero(tag: heroTag!, child: child);
  }
}
