import 'package:flutter/material.dart';
import '../view_models/section_heading_view_model.dart';

class SectionHeading extends StatelessWidget {
  const SectionHeading({
    super.key,
    this.title,
    this.buttonTitle = 'View all',
    this.showActionButton = true,
    this.textColor,
    this.onPressed,
    this.sectionHeadingModel,
  });

  final String? title;
  final String buttonTitle;
  final bool showActionButton;
  final Color? textColor;
  final void Function()? onPressed;
  final SectionHeadingModel? sectionHeadingModel;

  @override
  Widget build(BuildContext context) {
    // دمج الأسماء المختلفة عشان أي فايل يشتغل أوتوماتيك
    final displayedTitle = sectionHeadingModel?.title ?? title ?? '';
    final displayedShowButton = sectionHeadingModel?.showActionButton ?? showActionButton;
    final displayedButtonTitle = sectionHeadingModel?.actionButtonTitle ?? sectionHeadingModel?.buttonTitle ?? buttonTitle;
    final displayedOnPressed = sectionHeadingModel?.actionButtonOnPressed ?? sectionHeadingModel?.onPressed ?? onPressed;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          displayedTitle,
          style: Theme.of(context).textTheme.headlineSmall!.apply(color: textColor),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        if (displayedShowButton)
          TextButton(
            onPressed: displayedOnPressed,
            child: Text(displayedButtonTitle),
          ),
      ],
    );
  }
}