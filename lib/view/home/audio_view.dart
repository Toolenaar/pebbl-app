import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:pebbl/logic/audio/audio_controller.dart';
import 'package:pebbl/logic/colors.dart';
import 'package:pebbl/logic/navigation_helper.dart';
import 'package:pebbl/logic/texts.dart';
import 'package:pebbl/model/category.dart';
import 'package:pebbl/view/components/buttons/pebble_button.dart';

import 'package:pebbl/view/home/audio/audio_player_view.dart';
import 'package:pebbl/view/sets_list_page.dart';
import 'package:provider/provider.dart';

class AudioView extends StatefulWidget {
  const AudioView({Key key}) : super(key: key);

  @override
  _AudioViewState createState() => _AudioViewState();
}

class _AudioViewState extends State<AudioView> {
  AudioController audioController;

  @override
  void initState() {
    audioController = context.read<AudioController>();
    super.initState();
  }

  Widget _buildEmptyView(CategoryColorTheme colorTheme) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: ThemedPebbleButton(
              title: 'Select a playlist',
              categoryTheme: colorTheme,
              onTap: () {
                NavigationHelper.navigateAsModal(context, SetsListPage(), 'SetsListPage');
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _buildLoadignView(CategoryColorTheme colorTheme) {
    return Center(
      child: BodyText1(
        'Loading playlist',
        color: colorTheme.accentColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ScreenState>(
      stream: audioController.screenStateStream,
      builder: (BuildContext context, AsyncSnapshot<ScreenState> snapshot) {
        final screenState = snapshot.data;
        final queue = screenState?.queue;
        final mediaItem = screenState?.mediaItem;
        final state = screenState?.playbackState;
        final processingState = state?.processingState ?? AudioProcessingState.none;
        final playlist = screenState?.playlist;
        print(processingState);
        print(mediaItem);

        final colorTheme = AppColors.of(context).activeColorTheme();
        if ((playlist != null && playlist.length != 0) && processingState == AudioProcessingState.none) {
          return _buildLoadignView(colorTheme);
        } else {
          if (processingState == AudioProcessingState.none) {
            return _buildEmptyView(colorTheme);
          }
        }
        return Container(
          child: AudioPlayerView(
            audioSet: audioController.setForMediaItem(mediaItem),
          ),
        );
      },
    );
  }
}
