import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:piliotto/ottohub/api/models/video.dart' show ZerexaVideo;
import 'package:piliotto/common/constants.dart';
import 'package:piliotto/common/widgets/network_img_layer.dart';
import 'package:piliotto/utils/utils.dart';

class HistoryItem extends StatelessWidget {
  final ZerexaVideo videoItem;

  const HistoryItem({
    super.key,
    required this.videoItem,
  });

  @override
  Widget build(BuildContext context) {
    final String heroTag = Utils.makeHeroTag(videoItem.id);

    return InkWell(
      onTap: () {
        Get.toNamed('/video?vid=${videoItem.id}', arguments: {
          'heroTag': heroTag,
          'pic': videoItem.coverUrl,
        });
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
            StyleString.safeSpace, 5, StyleString.safeSpace, 5),
        child: LayoutBuilder(
          builder: (context, boxConstraints) {
            double width =
                (boxConstraints.maxWidth - StyleString.cardSpace * 6) / 2;
            return SizedBox(
              height: width / StyleString.aspectRatio,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AspectRatio(
                    aspectRatio: StyleString.aspectRatio,
                    child: LayoutBuilder(
                      builder: (context, boxConstraints) {
                        double maxWidth = boxConstraints.maxWidth;
                        double maxHeight = boxConstraints.maxHeight;
                        return Stack(
                          children: [
                            Hero(
                              tag: heroTag,
                              child: NetworkImgLayer(
                                src: videoItem.coverUrl,
                                width: maxWidth,
                                height: maxHeight,
                              ),
                            ),
                            // 新API无duration字段
                          ],
                        );
                      },
                    ),
                  ),
                  _VideoContent(videoItem: videoItem),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _VideoContent extends StatelessWidget {
  final ZerexaVideo videoItem;

  const _VideoContent({
    required this.videoItem,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 2, 6, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              videoItem.title,
              textAlign: TextAlign.start,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                letterSpacing: 0.3,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            if ((videoItem.authorUsername ?? '').isNotEmpty)
              Row(
                children: [
                  Text(
                    videoItem.authorUsername ?? '',
                    style: TextStyle(
                      fontSize:
                          Theme.of(context).textTheme.labelMedium!.fontSize,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                ],
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  videoItem.createdAt ?? '',
                  style: TextStyle(
                      fontSize:
                          Theme.of(context).textTheme.labelMedium!.fontSize,
                      color: Theme.of(context).colorScheme.outline),
                ),
                SizedBox(
                  width: 24,
                  height: 24,
                  child: PopupMenuButton<String>(
                    padding: EdgeInsets.zero,
                    tooltip: '功能菜单',
                    icon: Icon(
                      Icons.more_vert_outlined,
                      color: Theme.of(context).colorScheme.outline,
                      size: 14,
                    ),
                    position: PopupMenuPosition.under,
                    onSelected: (String type) {},
                    itemBuilder: (BuildContext context) =>
                        <PopupMenuEntry<String>>[
                      PopupMenuItem<String>(
                        onTap: () {
                          SmartDialog.showToast('Ottohub API 不支持删除历史记录');
                        },
                        value: 'delete',
                        height: 35,
                        child: const Row(
                          children: [
                            Icon(Icons.close_outlined, size: 16),
                            SizedBox(width: 6),
                            Text('删除记录', style: TextStyle(fontSize: 13))
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
