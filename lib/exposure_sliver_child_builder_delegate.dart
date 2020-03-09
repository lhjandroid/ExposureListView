import 'package:flutter/material.dart';

/// 能够记录开始和结束的Delegate
class ExposureSliverChildBuilderDelegate extends SliverChildBuilderDelegate{
  // 开始的位置 可能包含缓存
  int _firstIndex;
  // 结束的位置 可能包含缓存
  int _lastIndex;

  ExposureSliverChildBuilderDelegate(
      Widget Function(BuildContext, int) builder, {
        int itemCount,
        bool addAutomaticKeepAlives = true,
        bool addRepaintBoundaries = true,
        ChildIndexGetter findChildIndexCallback
      }) : super(builder,
      childCount: itemCount,
      addAutomaticKeepAlives: addAutomaticKeepAlives,
      addRepaintBoundaries: addRepaintBoundaries,
      findChildIndexCallback: findChildIndexCallback,
    );

  int get firstIndex => _firstIndex;

  int get lastIndex => _lastIndex;

  @override
  void didFinishLayout(int firstIndex, int lastIndex) {
    super.didFinishLayout(firstIndex, lastIndex);
    _firstIndex = firstIndex;
    _lastIndex = lastIndex;
  }

}