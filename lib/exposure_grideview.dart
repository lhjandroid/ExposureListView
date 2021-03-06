import 'package:flutter/material.dart';
import 'bean/Position.dart';
import 'exposure_sliver_child_builder_delegate.dart';

/// 固定宽高比的grideview
class ExposureFixedCrossGridView<T> extends StatefulWidget {
  // item构造
  GridViewBuilder listViewBuilder;

  // 数据
  List<T> datas;

  ExposureFixedCrossGridView(this.listViewBuilder, this.datas);

  @override
  State<StatefulWidget> createState() {
    return ExposureGridViewState(listViewBuilder, this.datas);
  }
}

class ExposureGridViewState<ExposureFixedCrossGridView, T>
    extends State {
  GridViewBuilder listViewBuilder;

  // item高度集合
  Map<int, Position> itemHeightMap;
  List<T> datas;

  ExposureSliverChildBuilderDelegate _builderDelegate;

  double itemHeight;

  ExposureGridViewState(this.listViewBuilder, this.datas) {
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
      return listViewBuilder.onCreateItem(context, index, datas[index]);
    }, itemCount: datas?.length ?? 0);
  }

  @override
  void initState() {
    super.initState();
    itemHeightMap = Map();
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener(
      child: GridView.custom(
          gridDelegate: listViewBuilder.createSliverGridDelegate(),
          childrenDelegate: _builderDelegate),
      onNotification: (notification) {
        if (notification is ScrollEndNotification && listViewBuilder != null) {
          int firstPosition =
              getFirstPosition(notification.metrics.extentBefore);
          int lastPosition = getLastPosition(notification.metrics.extentBefore,
              notification.metrics.extentInside);
          listViewBuilder.onScrollStop(firstPosition, lastPosition);
        }
        return true;
      },
    );
  }

  /// 获取首个可见item
  int getFirstPosition(double before) {
    if (before == 0) {
      return 0;
    }
    int start = _builderDelegate.firstIndex;
    int end = _builderDelegate.lastIndex;
    int firstPosition = start;

    // 有缓存的数据 在 往后面遍历 如果开始缓存的start比before还要小 直接返回start
    if (itemHeightMap[start].end < before) {
      for (int i = start + 1; i <= end; i++) {
        if (before > itemHeightMap[i].start && before <= itemHeightMap[i].end) {
          firstPosition = i;
          break;
        }
      }
    } else if (itemHeightMap[start].start == before) {
      if (start == 0) {
        return 0;
      }
      return start - 1;
    }
    return firstPosition;
  }

  /// 获取最后一项可见item
  int getLastPosition(double extentBefore, double extentInside) {
    double lastHeight = extentBefore + extentInside;
    int start = _builderDelegate.firstIndex;
    int end = _builderDelegate.lastIndex;
    int lastPosition = end;
    if (itemHeightMap[end].start > lastHeight) {
      if (end - 1 == 0) {
        return 0;
      }
      // 往前找
      for (int i = end - 1; i >= start; i--) {
        if (lastHeight >= itemHeightMap[i].start &&
            lastHeight < itemHeightMap[i].end) {
          lastPosition = i;
          break;
        }
      }
    }
    return lastPosition;
  }
}

/// 构造item
abstract class GridViewBuilder<T> {
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
