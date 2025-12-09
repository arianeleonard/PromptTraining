import 'package:betterprompts/root_tab_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../theme.dart';
import '../providers/chat_provider.dart';
import '../widgets/favorite_prompt_list.dart';
import '../widgets/prompt_history_list.dart';
import '../widgets/gradient_page_shell.dart';

/// History page showing saved prompts with favorites, search, and quick actions.
class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final TextEditingController _searchController = TextEditingController();
  bool _showFavoritesOnly = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final l10n = AppLocalizations.of(context);

    return GradientPageShell(
      header: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              l10n.history,
              style: textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.onPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Consumer<ChatProvider>(
              builder: (context, chatProvider, _) {
                final count = chatProvider.promptHistory.length;
                final isFr =
                    Localizations.localeOf(context).languageCode == 'fr';
                final label =
                    isFr
                        ? '$count prompts sauvegardés'
                        : '$count saved prompts';
                return Text(
                  label,
                  style: textTheme.bodyMedium?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onPrimary.withValues(alpha: 0.85),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            // Full-width tabs at the top of the content area.
            _HistoryTabs(),
            Expanded(
              child: _HistoryTabViews(
                onToggleFavorites: () {
                  setState(() {
                    _showFavoritesOnly = !_showFavoritesOnly;
                  });
                },
                showFavoritesOnly: _showFavoritesOnly,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FavoritesToggle extends StatelessWidget {
  final bool isActive;
  final VoidCallback onTap;

  const _FavoritesToggle({required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final l10n = AppLocalizations.of(context);

    final bgColor = isActive
        ? (Theme.of(context).brightness == Brightness.dark
            ? DarkColors.chart1
            : LightColors.chart1)
        : colorScheme.surface;
    final fgColor = isActive
        ? colorScheme.onPrimary
        : colorScheme.onSurfaceVariant;

    return Align(
      alignment: Alignment.centerLeft,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                isActive ? Icons.star : Icons.star_border,
                size: 18,
                color: fgColor,
              ),
              const SizedBox(width: 8),
              Text(
                l10n.favorites,
                style: textTheme.labelMedium?.copyWith(
                  color: fgColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HistoryTabs extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final l10n = AppLocalizations.of(context);

    return SizedBox(
      height: 40,
      child: TabBar(
        isScrollable: false,
        // remove bottom divider
        dividerColor: Colors.transparent,
        dividerHeight: 0,
        // full‑width pill indicator per tab
        indicator: BoxDecoration(
          color: colorScheme.primary.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(20),
        ),
        indicatorSize: TabBarIndicatorSize.tab, // <- makes it match the tab width
        labelColor: colorScheme.onSurfaceVariant,
        unselectedLabelColor:
            colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
        labelStyle: textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        tabs: [
          Tab(text: l10n.history),
          Tab(text: l10n.chats),
        ],
      ),
    );
  }
}

class _HistoryTabViews extends StatelessWidget {
  const _HistoryTabViews({
    required this.onToggleFavorites,
    required this.showFavoritesOnly,
  });

  final VoidCallback onToggleFavorites;
  final bool showFavoritesOnly;

  @override
  Widget build(BuildContext context) {
    return TabBarView(
      children: [
        // Prompt history (with favorites toggle controlled above)
        _PromptHistoryTab(
          onToggleFavorites: onToggleFavorites,
          showFavoritesOnly: showFavoritesOnly,
        ),
        // Chat history (list of conversations)
        _ChatHistoryTab(),
      ],
    );
  }
}

class _PromptHistoryTab extends StatelessWidget {
  const _PromptHistoryTab({
    required this.onToggleFavorites,
    required this.showFavoritesOnly,
  });

  final VoidCallback onToggleFavorites;
  final bool showFavoritesOnly;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _FavoritesToggle(
            isActive: showFavoritesOnly,
            onTap: onToggleFavorites,
          ),
          const SizedBox(height: 12),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child:
                  showFavoritesOnly
                      ? const FavoritePromptList()
                      : const PromptHistoryList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatHistoryTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, _) {
        final conversations = chatProvider.conversations;
        if (conversations.isEmpty) {
          return Center(
            child: Text(
              AppLocalizations.of(context).noHistoryYet,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          );
        }
        return ListView.separated(
          itemCount: conversations.length,
          separatorBuilder: (context, index) {
            return Divider(
              height: 1,
              indent: 16,
              endIndent: 16,
              color: Theme.of(
                context,
              ).colorScheme.outlineVariant.withValues(alpha: 0.3),
            );
          },
          itemBuilder: (context, index) {
            final conversation = conversations[index];
            final title =
                conversation.title.trim().isEmpty
                    ? AppLocalizations.of(context).newChat
                    : conversation.title.trim();

            final colorScheme = Theme.of(context).colorScheme;

            return InkWell(
              onTap: () {
                // Select the tapped conversation and switch to the Chats tab.
                final chatProvider = Provider.of<ChatProvider>(
                  context,
                  listen: false,
                );
                chatProvider.selectConversation(conversation.id);

                // Navigate back to the main root scaffold. This will show
                // the Chats tab by default (index 1 in RootTabScaffold).
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const RootTabScaffold()),
                  (route) => false,
                );
              },
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 4,
                ),
                title: Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
                trailing: Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 18,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            );
          },
        );
      },
    );
  }
}

