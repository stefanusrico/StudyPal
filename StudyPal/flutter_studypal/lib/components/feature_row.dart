import 'package:flutter/material.dart';
import 'package:flutter_studypal/utils/global_colors.dart';
import 'package:flutter_studypal/utils/global_text.dart';
import 'package:flutter_svg/flutter_svg.dart';

class FeatureRowWidget extends StatelessWidget {
  const FeatureRowWidget({
    super.key,
    required this.iconPath,
    required this.title,
    required this.description,
    this.iconWidth = 37,
    this.iconHeight = 37,
  });

  final String iconPath;
  final String title;
  final String description;
  final double iconWidth;
  final double iconHeight;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: iconWidth,
          height: iconHeight,
          child: SvgPicture.asset(
            iconPath,
            width: iconWidth,
            height: iconHeight,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GlobalText.blackPrimaryPoppinsTextStyle.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: GlobalText.blackPrimaryPoppinsTextStyle.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
