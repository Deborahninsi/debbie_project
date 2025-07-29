import 'package:flutter/material.dart';
import 'enhanced_refresh_indicator.dart';

class PullToRefreshList extends StatelessWidget {
  final List<Widget> children;
  final Future<void> Function() onRefresh;
  final String? refreshMessage;
  final EdgeInsetsGeometry? padding;
  final ScrollPhysics? physics;
  final bool shrinkWrap;
  final Widget? emptyState;
  final bool isEmpty;

  const PullToRefreshList({
    super.key,
    required this.children,
    required this.onRefresh,
    this.refreshMessage,
    this.padding,
    this.physics,
    this.shrinkWrap = false,
    this.emptyState,
    this.isEmpty = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isEmpty && emptyState != null) {
      return EnhancedRefreshIndicator(
        onRefresh: onRefresh,
        refreshMessage: refreshMessage,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.7,
            child: emptyState!,
          ),
        ),
      );
    }

    return EnhancedRefreshIndicator(
      onRefresh: onRefresh,
      refreshMessage: refreshMessage,
      child: ListView(
        physics: physics ?? const AlwaysScrollableScrollPhysics(),
        padding: padding,
        shrinkWrap: shrinkWrap,
        children: children,
      ),
    );
  }
}

class PullToRefreshScrollView extends StatelessWidget {
  final Widget child;
  final Future<void> Function() onRefresh;
  final String? refreshMessage;
  final EdgeInsetsGeometry? padding;
  final ScrollPhysics? physics;

  const PullToRefreshScrollView({
    super.key,
    required this.child,
    required this.onRefresh,
    this.refreshMessage,
    this.padding,
    this.physics,
  });

  @override
  Widget build(BuildContext context) {
    return EnhancedRefreshIndicator(
      onRefresh: onRefresh,
      refreshMessage: refreshMessage,
      child: SingleChildScrollView(
        physics: physics ?? const AlwaysScrollableScrollPhysics(),
        padding: padding,
        child: child,
      ),
    );
  }
}
