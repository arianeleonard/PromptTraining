import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

class ChatAppBar extends StatelessWidget {
  final VoidCallback? onToggleSidebar;
  final bool isMobile;

  const ChatAppBar({
    super.key,
    this.onToggleSidebar,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context)
                .colorScheme
                .outline
                .withValues(alpha: 0.15),
          ),
        ),
      ),
      child: Row(
        children: [
           if (isMobile && onToggleSidebar != null)
            IconButton(
              onPressed: onToggleSidebar,
              icon: Icon(
                Icons.menu_rounded,
                size: 18,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              tooltip: AppLocalizations.of(context).openSidebar,
              style: IconButton.styleFrom(
                splashFactory: NoSplash.splashFactory,
                backgroundColor: Colors.transparent,
                foregroundColor: Theme.of(context).colorScheme.onSurface,
                padding: const EdgeInsets.all(6),
                minimumSize: const Size(30, 30),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            )
          else
            const SizedBox(width: 8),
          const Spacer(),
        ],
      ),
    );
  }
}
