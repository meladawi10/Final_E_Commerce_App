import 'package:flutter/material.dart';

import '../../../../core/utils/constants/colors.dart';
import '../../../../core/utils/constants/sizes.dart';

class TermsAndPrivacyAgreement extends StatefulWidget {
  const TermsAndPrivacyAgreement({
    super.key,
  });

  @override
  State<TermsAndPrivacyAgreement> createState() => _TermsAndPrivacyAgreementState();
}

class _TermsAndPrivacyAgreementState extends State<TermsAndPrivacyAgreement> {
  bool _isChecked = false; 

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: Checkbox(
            value: _isChecked,
            activeColor: TColors.primary,
            onChanged: (value) {
              setState(() {
                _isChecked = value ?? false; 
              });
            },
          ),
        ),
        const SizedBox(
          width: TSizes.spaceBtwInputFields - 8,
        ),
        Expanded(
          child: Text.rich(
            TextSpan(
              // الستايل الأساسي لكل الجملة بالأسود عشان تظهر دايماً
              style: const TextStyle(
                color: Colors.black,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
              children: [
                const TextSpan(text: 'I agree to '),
                const TextSpan(
                  text: 'Privacy Policy',
                  style: TextStyle(
                    color: TColors.primary, // اللينك بالأحمر
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                    decorationColor: TColors.primary,
                  ),
                ),
                const TextSpan(text: ' and '),
                const TextSpan(
                  text: 'Terms of Use',
                  style: TextStyle(
                    color: TColors.primary, // اللينك بالأحمر
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                    decorationColor: TColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}