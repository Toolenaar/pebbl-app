import 'package:flutter/material.dart';
import 'package:pebbl/logic/audio/audio_controller.dart';
import 'package:pebbl/logic/audio/audio_manager.dart';
import 'package:pebbl/logic/colors.dart';
import 'package:pebbl/logic/texts.dart';
import 'package:pebbl/model/audio_set.dart';
import 'package:pebbl/model/category.dart';
import 'package:pebbl/presenter/sets_presenter.dart';
import 'package:pebbl/view/components/buttons/pebble_button.dart';
import 'package:pebbl/view/components/sets/sets_list.dart';
import 'package:pebbl/view/home/audio/audio_player_view.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';

// class TracksList extends StatefulWidget {
//   final GroupedByCategory categoryGroup;
//   final Function onBackPressed;
//   final Function close;
//   const TracksList(
//       {Key key, @required this.categoryGroup, @required this.onBackPressed, @required this.close})
//       : super(key: key);

//   @override
//   _TracksListState createState() => _TracksListState();
// }

// class _TracksListState extends State<TracksList> {
//   ValueStream<AudioSet> _trackChangedStream;
//   @override
//   void initState() {
//     _trackChangedStream = context.read<AudioManager>().activeTrackStream;
//     super.initState();
//   }

//   Widget _buildList(CategoryColorTheme colorTheme) {
//     return Container(
//       decoration: BoxDecoration(
//         color: colorTheme.backgroundColor,
//         border: Border.all(
//           color: colorTheme.accentColor,
//         ),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: <Widget>[
//           Padding(
//             padding: const EdgeInsets.only(left: 0, top: 16, bottom: 16),
//             child: Row(
//               mainAxisSize: MainAxisSize.min,
//               mainAxisAlignment: MainAxisAlignment.start,
//               children: <Widget>[
//                 IconButton(
//                   icon: Icon(
//                     Icons.arrow_back,
//                     color: colorTheme.accentColor,
//                   ),
//                   onPressed: widget.onBackPressed,
//                 ),
//                 H1Text(
//                   widget.categoryGroup.category.name,
//                   color: colorTheme.accentColor,
//                 ),
//               ],
//             ),
//           ),
//           Expanded(
//             child: ListView.builder(
//                 itemBuilder: (context, index) {
//                   return TrackListItem(
//                     audioSet: widget.categoryGroup.sets[index],
//                     onTap: () {
//                       context
//                           .read<AudioManager>()
//                           .startPlayingAtIndex(widget.categoryGroup.sets, index, startPlaying: true);
//                     },
//                   );
//                 },
//                 itemCount: widget.categoryGroup.sets.length),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final colorTheme = widget.categoryGroup.category.colorTheme;
//     //update when track changes
//     return StreamBuilder(
//       stream: _trackChangedStream,
//       initialData: null,
//       builder: (BuildContext context, AsyncSnapshot snapshot) {
//         return Container(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: <Widget>[
//               Expanded(
//                 child: _buildList(colorTheme),
//               ),
//               const SizedBox(
//                 height: 16,
//               ),
//               ThemedPebbleButton(
//                 categoryTheme: colorTheme,
//                 title: 'Shuffle ${widget.categoryGroup.category.name}',
//                 onTap: () {
//                   context
//                       .read<AudioManager>()
//                       .shuffleStartPlaylist(widget.categoryGroup.sets, startPlaying: true);
//                   this.widget.close();
//                 },
//               )
//             ],
//           ),
//         );
//       },
//     );
//   }
// }

class TrackListItem extends StatelessWidget {
  final AudioSet audioSet;
  final Function onTap;
  final bool isInFavoriteList;
  const TrackListItem({Key key, @required this.audioSet, @required this.onTap, this.isInFavoriteList = false})
      : super(key: key);

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
    final activeSet = context.select<AudioController, AudioSet>((value) => value.activeTrack());
    final isActive = activeSet != null && activeSet.id == audioSet.id;
    final colorTheme = AppColors.getActiveColorTheme(context);
    final color = colorTheme.accentColor;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: isActive ? colorTheme.selectionColor : Colors.transparent,
        padding: const EdgeInsets.all(16),
        child: Row(
          children: <Widget>[
            // SizedBox(
            //   height: 16,
            //   width: 16,
            //   child: isActive
            //       ? Image.asset(
            //           'assets/img/ic_active_indicator.png',
            //           color: colorTheme.accentColor,
            //         )
            //       : SizedBox(),
            // ),
            // const SizedBox(width: 16),
            Expanded(
              child: BodyText2(
                '${audioSet.artist.name} - ${audioSet.name}',
                fontSize: 14,
                color: color,
              ),
            ),
            const SizedBox(width: 4),
            _setNameSuffix(color, context),
            if (isInFavoriteList)
              ToggleFavoriteButton(audioSet: audioSet, color: color, iconSize: 12)
          ],
        ),
      ),
    );
  }
}
