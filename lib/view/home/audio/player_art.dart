import 'package:flutter/material.dart';
import 'package:pebbl/logic/audio/audio_controller.dart';

import 'package:pebbl/logic/colors.dart';

import 'package:provider/provider.dart';

class PlayerArt extends StatefulWidget {
  const PlayerArt({
    Key key,
  }) : super(key: key);

  @override
  _PlayerArtState createState() => _PlayerArtState();
}

class _PlayerArtState extends State<PlayerArt> {
  AudioController audioController;
  @override
  void initState() {
    audioController = context.read<AudioController>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final colorTheme = AppColors.of(context).activeColorTheme();

    return StreamBuilder<ScreenState>(
      stream: audioController.screenStateStream,
      builder: (BuildContext context, AsyncSnapshot<ScreenState> snapshot) {
        if (snapshot.data == null) return SizedBox();
        final screenState = snapshot.data;

        final state = screenState?.playbackState;
        final isPlaying = state?.playing ?? false;

        return Container(
          height: 128,
          width: 128,
          child: Stack(
            children: <Widget>[
              // Image.network(
              //   audioSet.image,
              //   color: colorTheme.accentColor,
              // ),
              Center(
                child: PlayPauseButton(
                    color: colorTheme.accentColor,
                    isPlaying: isPlaying,
                    onPressed: () {
                      if (isPlaying) {
                        audioController.pause();
                      } else {
                        audioController.play();
                      }
                    }),
              )
            ],
          ),
        );
        // return Row(
        //   mainAxisSize: MainAxisSize.min,
        //   children: <Widget>[
        //     // RaisedButton(
        //     //   child: Text('Previous'),
        //     //   onPressed: () {
        //     //     audioManager.previous();
        //     //   },
        //     // ),

        //     RaisedButton(
        //         child: Text(isPlaying ? 'Pause Audio' : 'Play Audio'), onPressed: () => _togglePlayPause(isPlaying)),
        //     // RaisedButton(
        //     //   child: Text('Next'),
        //     //   onPressed: () {
        //     //     audioManager.next();
        //     //   },
        //     // ),
        //   ],
        // );
      },
    );
  }
}

class PlayPauseButton extends StatelessWidget {
  final bool isPlaying;
  final Function onPressed;
  final Color color;
  const PlayPauseButton({Key key, @required this.isPlaying, @required this.onPressed, this.color = Colors.white})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final icon = isPlaying ? Icons.pause : Icons.play_arrow;
    return IconButton(
      iconSize: 48,
      onPressed: onPressed,
      color: color,
      icon: Icon(icon),
    );
  }
}
