import 'package:flutter/material.dart';
import 'bean/Position.dart';
import 'exposure_sliver_child_builder_delegate.dart';

/// 固定宽高比的sliver grideview
class ExposureSliverGridView<ExposureFixedCrossGridView, T>
    extends StatelessWidget {
  GridViewSliverBuilder listViewBuilder;

  // item高度集合
  Map<int, Position> itemHeightMap = Map();
  // 数据
  List<T> data;

  ExposureSliverChildBuilderDelegate _builderDelegate;

  double itemHeight;

  NotificationListenerCallback<ScrollNotification> _onNotification;

  NotificationListenerCallback<ScrollNotification> get onNotification =>
      _onNotification;

  ExposureSliverGridView(this.listViewBuilder, this.data,this.itemHeightMap) {
    itemHeight = listViewBuilder.getItemHeight();
    _builderDelegate = ExposureSliverChildBuilderDelegate((context, index) {
      if (index == 0) {
        itemHeightMap[0] = Position(0, itemHeight);
      } else if (index % listViewBuilder.getCellCount() == 0) {
        itemHeightMap[index] = Position(itemHeightMap[index - 1].end,
            itemHeightMap[index - 1].end + itemHeight);
      } else {
        itemHeightMap[index] = itemHeightMap[index - (index % 2)];
      }
      return listViewBuilder.onCreateItem(context, index, data[index]);
    }, itemCount: data?.length ?? 0);

    _onNotification = (notification) {
      if (notification is ScrollEndNotification) {
        int firstPosition = getFirstPosition(notification?.metrics?.extentBefore);
        int lastPosition = getLastPosition(notification?.metrics?.extentBefore,
            notification?.metrics?.extentInside);
        listViewBuilder?.onScrollStop(firstPosition, lastPosition);
      }
      return false;
    };
  }

  @override
  Widget build(BuildContext context) {
    return SliverGrid(
        delegate: _builderDelegate,
        gridDelegate: listViewBuilder.createSliverGridDelegate());
  }

  /// 获取首个可见item
  int getFirstPosition(double before) {
    if (before == 0) {
      return 0;
    }
    if (itemHeightMap == null || itemHeightMap.isEmpty) {
      return 0;
    }
    int start = _builderDelegate?.firstIndex ?? 0;
    int end = _builderDelegate?.lastIndex ?? 0;
    int firstPosition = start;

    // 有缓存的数据 在 往后面遍历 如果开始缓存的start比before还要小 直接返回start
    if ((itemHeightMap?.length ?? 0) <= start) {
      return start;
    }
    if ((itemHeightMap[start]?.end ?? 0) < before) {
      for (int i = start + 1; i <= end; i++) {
        if (i >= (itemHeightMap?.length ?? 0)) {
          break;
        }
        if (before > (itemHeightMap[i]?.start ?? 0) && before <= (itemHeightMap[i]?.end ?? 0)) {
          firstPosition = i;
          break;
        }
      }
    } else if ((itemHeightMap[start]?.start ?? 0) == before) {
      if (start == 0) {
        return 0;
      }
      return start - 1;
    }
    return firstPosition;
  }

  /// 获取最后一项可见item
  int getLastPosition(double extentBefore, double extentInside) {
    if (itemHeightMap == null || itemHeightMap.isEmpty) {
      return 0;
    }
    double lastHeight = extentBefore + extentInside;
    int start = _builderDelegate?.firstIndex ?? 0;
    int end = _builderDelegate?.lastIndex ?? 0;
    int lastPosition = end;
    if (itemHeightMap.length <= start) {
      return start;
    }
    if ((itemHeightMap?.length ?? 0) <= end ) {
      return end;
    }
    if ((itemHeightMap[end]?.start ?? 0) > lastHeight) {
      if (end - 1 == 0) {
        return 0;
      }
      // 往前找
      for (int i = end - 1; i >= start; i--) {
        if (i <= (itemHeightMap?.length ?? 0)) {
          break;
        }
        if (lastHeight >= (itemHeightMap[i]?.start ?? 0) &&
            lastHeight < (itemHeightMap[i]?.end ?? 0)) {
          lastPosition = i;
          break;
        }
      }
    }
    return lastPosition;
  }
}

/// 构造item
abstract class GridViewSliverBuilder<T> {
  SliverGridDelegate createSliverGridDelegate();

  /// 构造item
  Widget onCreateItem(BuildContext context, int index, T data);

  /// 滚动停止
  void onScrollStop(int startPosition, int endPosition);

  /// 每行几个cell
  int getCellCount();

  /// item高度
  double getItemHeight();
}
