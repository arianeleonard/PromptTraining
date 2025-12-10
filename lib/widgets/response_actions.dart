import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../l10n/app_localizations.dart';
import '../theme.dart';

/// Internal feedback options for thumbs-down flow
enum _FeedbackOption { vague, incorrect, other }

/// Result captured from the feedback dialog
class _FeedbackResult {
  final _FeedbackOption? option;
  final String? otherText;

  const _FeedbackResult({this.option, this.otherText});
}

/// Interactive action buttons for AI assistant messages
class ResponseActions extends StatefulWidget {
  final String messageContent;
  final ValueChanged<bool>? onThumbsUp; // selected state
  final void Function(bool selected, String? choiceKey, String? notes)? onThumbsDown;
  final VoidCallback? onCopy;
  final VoidCallback? onShare;
  final VoidCallback? onUseAsNewPrompt;

  const ResponseActions({
    super.key,
    required this.messageContent,
    this.onThumbsUp,
    this.onThumbsDown,
    this.onCopy,
    this.onShare,
    this.onUseAsNewPrompt,
  });

  @override
  State<ResponseActions> createState() => _ResponseActionsState();
}

class _ResponseActionsState extends State<ResponseActions> {
  bool _copied = false;
  bool _thumbsUpPressed = false;
  Color? _thumbsDownIconColor;
  bool _thumbsDownPressed = false;

  _FeedbackOption? _selectedOption;
  late final TextEditingController _otherController;

  @override
  void initState() {
    super.initState();
    _otherController = TextEditingController();
  }

  @override
  void dispose() {
    _otherController.dispose();
    super.dispose();
  }

  void _handleCopy() async {
    await Clipboard.setData(ClipboardData(text: widget.messageContent));
    setState(() {
      _copied = true;
    });
    widget.onCopy?.call();

    // Reset the copied state after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _copied = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ActionButton(
          icon: Icons.refresh_rounded,
          tooltip: AppLocalizations.of(context).regenerate,
          onPressed: () {
            // TODO: Implement regenerate functionality
          },
        ),
        const SizedBox(width: 4),
        _ActionButton(
          icon: Icons.thumb_up_outlined,
          tooltip: AppLocalizations.of(context).goodResponse,
          onPressed: () {
            setState(() {
              // Toggle thumbs up
              final willSelect = !_thumbsUpPressed;
              _thumbsUpPressed = !_thumbsUpPressed;

              // Make thumbs up/down mutually exclusive
              if (willSelect) {
                _thumbsDownPressed = false;
                _thumbsDownIconColor = null;
              }
            });
            widget.onThumbsUp?.call(_thumbsUpPressed);
          },
          iconColor: _thumbsUpPressed
              ? (Theme.of(context).extension<ScoreColors>()?.high ?? Theme.of(context).colorScheme.primary)
              : null,
        ),
        const SizedBox(width: 4),
        _ActionButton(
          icon: Icons.thumb_down_outlined,
          tooltip: AppLocalizations.of(context).poorResponse,
          onPressed: () async {
            // Toggle-like behavior: if already pressed (red), unselect and skip popup
            if (_thumbsDownPressed) {
              setState(() {
                _thumbsDownPressed = false;
                _thumbsDownIconColor = null;
              });
              // notify deselection
              widget.onThumbsDown?.call(false, null, null);
              return; // do not show popup on un-toggle
            }

            // Mark as pressed and show the feedback dialog
            setState(() {
              // Make thumbs up/down mutually exclusive
              _thumbsUpPressed = false;
              _thumbsDownPressed = true;
              _thumbsDownIconColor = Theme.of(context).extension<ScoreColors>()?.low ?? Theme.of(context).colorScheme.error;
            });

            final result = await showDialog<_FeedbackResult>(
              context: context,
              builder: (context) {
                // Use a local variable for selection inside the dialog so it can rebuild independently.
                _FeedbackOption? localSelection = _selectedOption;
                // Preserve any existing notes between openings; user asked for an always-visible field.

                return StatefulBuilder(
                  builder: (context, setState) {
                    final canSubmit = localSelection != null;
                    return AlertDialog(
                      title: Text(AppLocalizations.of(context).dislikeDialogTitle),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          RadioListTile<_FeedbackOption>(
                            title: Text(AppLocalizations.of(context).feedbackTooVague),
                            value: _FeedbackOption.vague,
                            groupValue: localSelection,
                            onChanged: (value) {
                              setState(() => localSelection = value);
                            },
                          ),
                          RadioListTile<_FeedbackOption>(
                            title: Text(AppLocalizations.of(context).feedbackIncorrect),
                            value: _FeedbackOption.incorrect,
                            groupValue: localSelection,
                            onChanged: (value) {
                              setState(() => localSelection = value);
                            },
                          ),
                          RadioListTile<_FeedbackOption>(
                            title: Text(AppLocalizations.of(context).feedbackOther),
                            value: _FeedbackOption.other,
                            groupValue: localSelection,
                            onChanged: (value) {
                              setState(() => localSelection = value);
                            },
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _otherController,
                            decoration: InputDecoration(
                              labelText: AppLocalizations.of(context).feedbackNotesLabel,
                              hintText: AppLocalizations.of(context).feedbackNotesHint,
                            ),
                            maxLines: 3,
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(null),
                          child: Text(AppLocalizations.of(context).cancel),
                        ),
                        ElevatedButton(
                          onPressed: canSubmit
                              ? () {
                                  Navigator.of(context).pop(
                                    _FeedbackResult(
                                      option: localSelection,
                                      otherText: _otherController.text.trim().isEmpty
                                          ? null
                                          : _otherController.text.trim(),
                                    ),
                                  );
                                }
                              : null,
                          child: Text(AppLocalizations.of(context).submit),
                        ),
                      ],
                    );
                  },
                );
              },
            );

            if (result != null) {
              // Persist last selection for subsequent openings
              setState(() {
                _selectedOption = result.option;
              });
              // Notify with selection details
              widget.onThumbsDown?.call(
                true,
                switch (result.option) {
                  _FeedbackOption.vague => 'vague',
                  _FeedbackOption.incorrect => 'incorrect',
                  _FeedbackOption.other => 'other',
                  null => null,
                },
                result.otherText,
              );
            }
          },
          iconColor: _thumbsDownIconColor,
        ),
        const SizedBox(width: 4),
        if (widget.onUseAsNewPrompt != null) ...[
          _ActionButton(
            icon: Icons.edit_outlined,
            tooltip: AppLocalizations.of(context).editPrompt,
            onPressed: widget.onUseAsNewPrompt,
          ),
          const SizedBox(width: 4),
        ],
        _ActionButton(
          icon: _copied ? Icons.check_rounded : Icons.content_copy_rounded,
          tooltip: _copied ? AppLocalizations.of(context).copied : AppLocalizations.of(context).copy,
          onPressed: _handleCopy,
        ),
        const SizedBox(width: 4),
        _ActionButton(
          icon: Icons.share_outlined,
          tooltip: AppLocalizations.of(context).share,
          onPressed: widget.onShare,
        ),
      ],
    );
  }
}

class _ActionButton extends StatefulWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final Color? iconColor;

  const _ActionButton({
    required this.icon,
    required this.tooltip,
    this.onPressed,
    this.iconColor,
  });

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Tooltip(
        message: widget.tooltip,
        child: InkWell(
          borderRadius: BorderRadius.circular(6),
          onTap: widget.onPressed,
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: _isHovered
                  ? Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.08)
                  : null,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              widget.icon,
              size: 16,
              color: widget.iconColor ??
                  Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ),
      ),
    );
  }
}
