class SectionHeadingModel {
  final String title;
  final String buttonTitle;
  final String? actionButtonTitle; // حل مشكلة الاسم ده
  final bool showActionButton;
  final void Function()? onPressed;
  final void Function()? actionButtonOnPressed; // حل مشكلة الاسم ده

  const SectionHeadingModel({
    required this.title,
    this.buttonTitle = 'View all',
    this.actionButtonTitle,
    this.showActionButton = true,
    this.onPressed,
    this.actionButtonOnPressed,
  });
}