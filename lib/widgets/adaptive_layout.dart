import 'package:flutter/material.dart';

class AdaptiveBibleLayout extends StatelessWidget {
  final Widget masterPane; // Book / Chapter Selector
  final Widget detailPane; // Bible Reader

  const AdaptiveBibleLayout({
    super.key,
    required this.masterPane,
    required this.detailPane,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWideScreen = constraints.maxWidth >= 600;

        if (isWideScreen) {
          return Scaffold(
            body: Row(
              children: [
                SizedBox(
                  width: 320,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        right: BorderSide(
                          color: Theme.of(context).dividerColor.withValues(alpha: 0.12),
                          width: 1,
                        ),
                      ),
                    ),
                    child: masterPane,
                  ),
                ),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 150),
                    transitionBuilder: (child, animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: child,
                      );
                    },
                    child: detailPane,
                  ),
                ),
              ],
            ),
          );
        }

        return masterPane;
      },
    );
  }
}
