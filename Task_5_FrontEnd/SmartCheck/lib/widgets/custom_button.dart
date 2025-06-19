import 'package:flutter/material.dart';
import 'package:smartcheck/utils/app_theme.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isPrimary;
  final bool isLoading;
  final double width;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isPrimary = true,
    this.isLoading = false,
    this.width = double.infinity,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: isPrimary
          ? ElevatedButton(
              onPressed: isLoading ? null : onPressed,
              style: AppTheme.primaryButtonStyle,
              child: isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(text),
            )
          : OutlinedButton(
              onPressed: isLoading ? null : onPressed,
              style: AppTheme.secondaryButtonStyle,
              child: isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: AppTheme.primaryColor,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(text),
            ),
    );
  }
}
