import 'package:flutter/material.dart';

/// Shared page layout used across the app: gradient background, safe area,
/// page header, and rounded surface container for main content.
class GradientPageShell extends StatelessWidget {
  final Widget header;
  final Widget body;
  final GlobalKey<ScaffoldState>? scaffoldKey;

  const GradientPageShell({
    super.key,
    required this.header,
    required this.body,
    this.scaffoldKey,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              colorScheme.tertiary,
              colorScheme.primary,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 112,
                child: Align(
                  alignment: Alignment.center,
                  child: header,
                )
              ),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  child: body,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
