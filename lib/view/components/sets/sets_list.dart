import 'package:flutter/material.dart';
import 'package:pebbl/logic/colors.dart';
import 'package:pebbl/logic/texts.dart';
import 'package:pebbl/model/audio_set.dart';
import 'package:pebbl/presenter/sets_presenter.dart';
import 'package:provider/provider.dart';

class SetsList extends StatelessWidget {
  final Function(AudioSet) onSetSelected;
  const SetsList({Key key, @required this.onSetSelected}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //todo stream from firebase
    var items = context.select<SetsPresenter, List<GroupedByCategory>>((value) => value.setCategories);
    final colorTheme = AppColors.getActiveColorTheme(context);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        border: Border.all(
          color: colorTheme.accentColor,
        ),
      ),
      child: ListView.builder(
          itemBuilder: (context, index) {
            return SetsListCategoryListItem(
              onSetSelected: onSetSelected,
              category: items[index],
            );
          },
          itemCount: items.length),
    );
  }
}

class SetsListCategoryListItem extends StatelessWidget {
  final GroupedByCategory category;
  final Function(AudioSet) onSetSelected;
  const SetsListCategoryListItem({Key key, this.category, @required this.onSetSelected}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorTheme = AppColors.getActiveColorTheme(context);
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: H1Text(
              category.category.name,
              color: colorTheme.accentColor,
              fontSize: 28,
            ),
          ),
          ...category.sets.map(
            (audioSet) => SetsListSetItem(
              onTap: () => onSetSelected(audioSet),
              audioSet: audioSet,
            ),
          ),
          const SizedBox(height: 48)
        ],
      ),
    );
  }
}

class SetsListSetItem extends StatelessWidget {
  final AudioSet audioSet;
  final Function onTap;
  const SetsListSetItem({Key key, @required this.audioSet, @required this.onTap}) : super(key: key);

  Widget _checkIfCurrentlyDownloading(BuildContext context) {
    var items = context.select<SetsPresenter, Map<String, double>>((value) => value.currentDownloadProgress);
    final downloadingSet = items[audioSet.id];
    if (downloadingSet != null) {
      final progress = items[audioSet.id] / 100;
      return DownloadProgress(progress: progress);
    }
    return null;
  }

  Widget _setNameSuffix(Color color, BuildContext context) {
    Widget downloading = _checkIfCurrentlyDownloading(context);
    if (downloading != null) return downloading;

    switch (audioSet.status) {
      case AudioSetStatus.notDownloaded:
        return BodyText2(
          '- not downloaded',
          fontSize: 14,
          color: color,
        );
        break;
      case AudioSetStatus.downloaded:
        return DownloadProgress();
      default:
        return SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeSet = context.select<SetsPresenter, AudioSet>((value) => value.activeSet);
    final isActive = activeSet == audioSet;
    final colorTheme = AppColors.getActiveColorTheme(context);
    final color =
        audioSet.status == AudioSetStatus.downloaded ? colorTheme.accentColor : colorTheme.accentColor40;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: Colors.transparent,
        padding: const EdgeInsets.fromLTRB(16, 0, 24, 24),
        child: Row(
          children: <Widget>[
            SizedBox(
              height: 16,
              width: 16,
              child: isActive
                  ? Image.asset(
                      'assets/img/ic_active_indicator.png',
                      color: colorTheme.accentColor,
                    )
                  : SizedBox(),
            ),
            const SizedBox(width: 8),
            BodyText2(
              '${audioSet.name}',
              fontSize: 14,
              color: color,
            ),
            const SizedBox(width: 4),
            _setNameSuffix(color, context)
          ],
        ),
      ),
    );
  }
}

class DownloadProgress extends StatelessWidget {
  final double progress;

  const DownloadProgress({Key key, this.progress = 1}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorTheme = AppColors.getActiveColorTheme(context);

    return Stack(
      children: <Widget>[
        Container(
          height: 16,
          width: 16,
          decoration: BoxDecoration(
            color: colorTheme.accentColor40,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        Positioned.fill(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: 16,
                height: 16 * progress,
                color: colorTheme.accentColor,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
