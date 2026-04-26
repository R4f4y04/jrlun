import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_theme.dart';

/// Error fallback card with retry button, styled for dark theme.
class ErrorCard extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const ErrorCard({super.key, required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.negative.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.negative.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.cloud_off_rounded,
            color: AppTheme.negative.withValues(alpha: 0.7),
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: AppTheme.negative.withValues(alpha: 0.9),
                fontSize: 13,
              ),
            ),
          ),
          if (onRetry != null)
            IconButton(
              icon: Icon(
                Icons.refresh_rounded,
                color: AppTheme.negative.withValues(alpha: 0.7),
              ),
              onPressed: onRetry,
              tooltip: 'Retry',
            ),
        ],
      ),
    );
  }
}
