import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:pebbl/logic/audio/audio_controller.dart';
import 'package:pebbl/logic/colors.dart';
import 'package:pebbl/logic/texts.dart';
import 'package:pebbl/view/home/audio/audio_player_view.dart';
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
        print(processingState);
        print(mediaItem);
        final colorTheme = AppColors.getActiveColorTheme(context);
        if (processingState == AudioProcessingState.none) {
          return Container(
            child: Center(child: Image.asset('assets/img/img_center_piece.png')),
          );
        }
        return Container(
          padding: const EdgeInsets.fromLTRB(24, 16, 16, 0),
          child: AudioPlayerView(
            audioSet: audioController.setForMediaItem(mediaItem),
          ),
        );
      },
    );
  }
}
