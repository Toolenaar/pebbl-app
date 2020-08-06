import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:pebbl/logic/audio/audio_controller.dart';
import 'package:pebbl/view/home/audio/audio_player_view.dart';
import 'package:provider/provider.dart';

class AudioTest extends StatefulWidget {
  const AudioTest({Key key}) : super(key: key);

  @override
  _AudioTestState createState() => _AudioTestState();
}

class _AudioTestState extends State<AudioTest> {
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
        if (processingState == AudioProcessingState.none) {
          return Container();
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
