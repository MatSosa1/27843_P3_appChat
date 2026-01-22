import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onProfileTap;

  const ChatAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.onProfileTap,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      scrolledUnderElevation: 1,
      backgroundColor: AppColors.surface,
      title: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          if (subtitle != null)
            Text(
              subtitle!,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
                color: AppColors.textTertiary,
              ),
            ),
        ],
      ),
      centerTitle: true,
      actions: [
        if (onProfileTap != null)
          IconButton(
            onPressed: onProfileTap,
            icon: const Icon(
              Icons.person_outline_rounded,
              color: AppColors.textSecondary,
            ),
          ),
      ],
    );
  }
}
