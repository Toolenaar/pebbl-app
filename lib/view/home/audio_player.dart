import 'package:flutter/material.dart';
import 'package:pebbl/logic/texts.dart';
import 'package:pebbl/model/audio_set.dart';
import 'package:pebbl/presenter/sets_presenter.dart';
import 'package:pebbl/presenter/soundscape_manager.dart';
import 'package:pebbl/view/components/set_center_piece.dart';
import 'package:provider/provider.dart';

class AudioPlayer extends StatefulWidget {
  const AudioPlayer({Key key}) : super(key: key);

  @override
  _AudioPlayerState createState() => _AudioPlayerState();
}

class _AudioPlayerState extends State<AudioPlayer> {
  SoundscapeManager _manager;

  @override
  void initState() {
    _manager = context.read<SetsPresenter>().soundscapeManager;
    _manager.setStateListener(_onStateChanged);

    super.initState();
  }

  void _onStateChanged(String state) {
    if (mounted) {
      if (state == 'completed') {
        // _manager.playNext();
        print('completed');
      }
    }
  }

  void _play() async {
    context.read<SetsPresenter>().playActiveSet();
  }

  void _pause() async {
    context.read<SetsPresenter>().stopActiveSet();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AudioSet>(
      stream: _manager.activeSetStream,
      initialData: null,
      builder: (BuildContext context, AsyncSnapshot<AudioSet> snapshot) {
        if (snapshot.data == null) return SizedBox();
        final isPlaying = context.select<SetsPresenter, bool>((value) => value.isPlaying);
        final audioSet = snapshot.data;
        return Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TrackInfo(
                audioSet: audioSet,
              ),
              Expanded(
                child: SetCenterpiece(
                  audioSet: audioSet,
                ),
              ),
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    RaisedButton(
                      child: Text('Previous'),
                      onPressed: () {
                        _manager.playPrevious();
                      },
                    ),
                    RaisedButton(
                      child: Text(isPlaying ? 'Pause Audio' : 'Play Audio'),
                      onPressed: isPlaying ? _pause : _play,
                    ),
                    RaisedButton(
                      child: Text('Next'),
                      onPressed: () {
                        _manager.playNext();
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class TrackInfo extends StatelessWidget {
  final AudioSet audioSet;
  const TrackInfo({Key key, @required this.audioSet}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          H1Text(
            audioSet.artist.name,
            fontSize: 20,
            color: audioSet.category.colorTheme.accentColor,
          ),
          BodyText1(
            audioSet.name,
            color: audioSet.category.colorTheme.accentColor,
          ),
        ],
      ),
    );
  }
}
