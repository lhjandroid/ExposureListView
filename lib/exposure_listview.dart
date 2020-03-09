import 'package:flutter/material.dart';

import 'bean/Position.dart';
import 'bean/StaticsData.dart';
import 'exposure_sliver_child_builder_delegate.dart';

class ExposureListView<T extends StaticsData> extends StatefulWidget {
  // item构造
  ListViewBuilder listViewBuilder;

  // 数据
  List<T> datas;

  ExposureListView(this.listViewBuilder, this.datas);

  @override
  State<StatefulWidget> createState() {
    return ExposureListViewState(listViewBuilder, this.datas);
  }
}

/// 状态
class ExposureListViewState<ExposureListView, T extends StaticsData>
    extends State {

  // view构造
  ListViewBuilder listViewBuilder;
  // item高度集合
  Map<int, Position> itemHeightMap;
  List<T> datas;

  ExposureSliverChildBuilderDelegate _builderDelegate;

  ExposureListViewState(this.listViewBuilder, this.datas) {
    _builderDelegate = ExposureSliverChildBuilderDelegate((context, index) {
      if (index == 0) {
        itemHeightMap[0] = Position(0, datas[0].itemHeight);
      } else if (!itemHeightMap.containsKey(index)) {
        itemHeightMap[index] = Position(itemHeightMap[index - 1].end,
            itemHeightMap[index - 1].end + datas[index].itemHeight);
      }
      return listViewBuilder.onCreateItem(context, index,datas[index]);
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
      child: ListView.custom(
        childrenDelegate: _builderDelegate,
      ),
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
    int firstPosition = 0;

    // 有缓存的数据 在 往后面遍历
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
    } else {
      // 缓存的第一项就为起始位置
      return start;
    }
    return firstPosition;
  }

  /// 获取最后一项可见item
  int getLastPosition(double extentBefore, double extentInside) {
    double lastHeight = extentBefore + extentInside;
    int start = _builderDelegate.firstIndex;
    int end = _builderDelegate.lastIndex;
    int lastPosition = 0;
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
    } else {
      return end;
    }
    return lastPosition;
  }
}

/// 构造item
abstract class ListViewBuilder <T extends StaticsData> {

  /// 构造item布局
  Widget onCreateItem(BuildContext context, int index,T data);

  /// 滚动停止
  void onScrollStop(int startPosition, int endPosition);
}
