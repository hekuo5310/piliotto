import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:piliotto/utils/feed_back.dart';
import 'package:piliotto/utils/image_save.dart';

import 'package:piliotto/ottohub/api/models/video.dart' show ZerexaVideo;
import 'package:piliotto/repositories/i_user_repository.dart';
import '../../utils/utils.dart';
import '../constants.dart';
import 'badge.dart';
import 'network_img_layer.dart';
import 'stat/view.dart';

class VideoCardV extends StatelessWidget {
  final ZerexaVideo videoItem;
  final int crossAxisCount;
  final Function? blockUserCb;

  const VideoCardV({
    super.key,
    required this.videoItem,
    required this.crossAxisCount,
    this.blockUserCb,
  });

  void onPushDetail(String heroTag) {
    Get.toNamed('/video?vid=${videoItem.id}', arguments: {
      'pic': videoItem.coverUrl,
      'heroTag': heroTag,
    });
  }

  @override
  Widget build(BuildContext context) {
    final String heroTag = Utils.makeHeroTag(videoItem.id);

    return InkWell(
      onTap: () => onPushDetail(heroTag),
      borderRadius: BorderRadius.circular(16),
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: StyleString.aspectRatio,
            child: LayoutBuilder(builder: (context, boxConstraints) {
              final double maxWidth = boxConstraints.maxWidth;
              final double maxHeight = boxConstraints.maxHeight;
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
            }),
          ),
          VideoContent(
            videoItem: videoItem,
            crossAxisCount: crossAxisCount,
            blockUserCb: blockUserCb,
          )
        ],
      ),
    );
  }
}

class VideoContent extends StatelessWidget {
  final ZerexaVideo videoItem;
  final int crossAxisCount;
  final Function? blockUserCb;

  const VideoContent({
    super.key,
    required this.videoItem,
    required this.crossAxisCount,
    this.blockUserCb,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: crossAxisCount == 1
          ? const EdgeInsets.fromLTRB(9, 9, 9, 4)
          : const EdgeInsets.fromLTRB(5, 8, 5, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            videoItem.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (crossAxisCount > 1) ...[
            const SizedBox(height: 2),
            VideoStat(videoItem: videoItem, crossAxisCount: crossAxisCount),
          ],
          if (crossAxisCount == 1) const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                flex: crossAxisCount == 1 ? 0 : 1,
                child: Text(
                  videoItem.authorUsername ?? '',
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: Theme.of(context).textTheme.labelMedium!.fontSize,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
              ),
              if (crossAxisCount == 1) ...[
                const SizedBox(width: 10),
                VideoStat(
                  videoItem: videoItem,
                  crossAxisCount: crossAxisCount,
                ),
                const Spacer(),
              ],
              SizedBox(
                width: 24,
                height: 24,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    feedBack();
                    showModalBottomSheet(
                      context: context,
                      useRootNavigator: true,
                      isScrollControlled: true,
                      builder: (context) {
                        return MorePanel(
                          videoItem: videoItem,
                          blockUserCb: blockUserCb,
                        );
                      },
                    );
                  },
                  icon: Icon(
                    Icons.more_vert_outlined,
                    color: Theme.of(context).colorScheme.outline,
                    size: 14,
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}

class VideoStat extends StatelessWidget {
  final ZerexaVideo videoItem;
  final int crossAxisCount;

  const VideoStat({
    super.key,
    required this.videoItem,
    required this.crossAxisCount,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        StatView(view: videoItem.views),
        const SizedBox(width: 8),
        crossAxisCount > 1 ? const Spacer() : const SizedBox(width: 8),
        RichText(
          maxLines: 1,
          text: TextSpan(
            style: TextStyle(
              fontSize: Theme.of(context).textTheme.labelSmall!.fontSize,
              color: Theme.of(context).colorScheme.outline,
            ),
            text: videoItem.createdAt ?? '',
          ),
        ),
        const SizedBox(width: 4),
      ],
    );
  }
}

class MorePanel extends StatelessWidget {
  final ZerexaVideo videoItem;
  final Function? blockUserCb;

  const MorePanel({
    super.key,
    required this.videoItem,
    this.blockUserCb,
  });

  void blockUser() async {
    SmartDialog.showToast('新API暂不支持拉黑功能');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: () => Get.back(),
            child: Container(
              height: 35,
              padding: const EdgeInsets.only(bottom: 2),
              child: Center(
                child: Container(
                  width: 32,
                  height: 3,
                  decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.outline,
                      borderRadius: const BorderRadius.all(Radius.circular(3))),
                ),
              ),
            ),
          ),
          ListTile(
            onTap: blockUser,
            minLeadingWidth: 0,
            leading: const Icon(Icons.block, size: 19),
            title: Text('拉黑up主 「${videoItem.authorUsername ?? ''}」',
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          ListTile(
            onTap: () =>
                imageSaveDialog(context, videoItem, SmartDialog.dismiss),
            minLeadingWidth: 0,
            leading: const Icon(Icons.photo_outlined, size: 19),
            title:
                Text('查看视频封面', style: Theme.of(context).textTheme.titleSmall),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
