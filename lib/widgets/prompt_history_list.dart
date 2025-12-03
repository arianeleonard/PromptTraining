import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../providers/chat_provider.dart';
import 'prompt_tile.dart';

class PromptHistoryList extends StatelessWidget {
  final VoidCallback? onClose;
  const PromptHistoryList({super.key, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, child) {
        final history = chatProvider.promptHistory;
        if (history.isEmpty) {
          return Center(
            child: Text(
              AppLocalizations.of(context)!.noHistoryYet,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
            ),
          );
        }

        return ListView.builder(
          itemCount: history.length,
          itemBuilder: (context, index) {
            final item = history[index];
            return PromptTile(entry: item, onClose: onClose);
          },
        );
      },
    );
  }
}
