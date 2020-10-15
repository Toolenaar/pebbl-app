import 'package:flutter/material.dart';
import 'package:pebbl/logic/audio/audio_controller.dart';
import 'package:pebbl/logic/colors.dart';
import 'package:pebbl/logic/texts.dart';
import 'package:pebbl/model/audio_set.dart';
import 'package:pebbl/presenter/user_presenter.dart';
import 'package:provider/provider.dart';

class AudioPlayerView extends StatefulWidget {
  final AudioSet audioSet;
  const AudioPlayerView({Key key, @required this.audioSet}) : super(key: key);

  @override
  _AudioPlayerState createState() => _AudioPlayerState();
}

class _AudioPlayerState extends State<AudioPlayerView> {
  AudioController audioController;
  @override
  void initState() {
    audioController = context.read<AudioController>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.audioSet == null) return Container();
    final colorTheme = AppColors.of(context).activeColorTheme();
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 16, 0),
            child: TrackInfo(
              audioSet: widget.audioSet,
            ),
          ),
          Expanded(
            child: Center(
              child: Row(
                children: <Widget>[
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      splashColor: colorTheme.accentColor.withOpacity(0.2),
                      highlightColor: colorTheme.accentColor.withOpacity(0.2),
                      onTap: () {
                        audioController.skipPrevious();
                      },
                      child: Container(
                        color: Colors.transparent, //Colors.blue.withOpacity(0.4),
                        width: MediaQuery.of(context).size.width / 4,
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        audioController.togglePlay();
                      },
                      child: Container(
                        color: Colors.transparent, //Colors.yellow.withOpacity(0.4),
                        child: Center(
                          child: PlayerControls(
                            controller: audioController,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      splashColor: colorTheme.accentColor.withOpacity(0.2),
                      highlightColor: colorTheme.accentColor.withOpacity(0.2),
                      onTap: () {
                        audioController.skipNext();
                      },
                      child: Container(
                        color: Colors.transparent, //Colors.blue.withOpacity(0.4),
                        width: MediaQuery.of(context).size.width / 4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TrackInfo extends StatelessWidget {
  final AudioSet audioSet;
  const TrackInfo({Key key, @required this.audioSet}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorTheme = AppColors.of(context).activeColorTheme();
    return Row(
      children: <Widget>[
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              H1Text(
                audioSet.name,
                fontSize: 20,
                color: colorTheme.accentColor,
              ),
              BodyText1(
                audioSet.artist.name,
                color: colorTheme.accentColor,
              ),
            ],
          ),
        ),
        ToggleFavoriteButton(
          audioSet: audioSet,
          color: colorTheme.accentColor,
        )
      ],
    );
  }
}

class ToggleFavoriteButton extends StatefulWidget {
  final Color color;
  final AudioSet audioSet;
  final double iconSize;
  const ToggleFavoriteButton({Key key, this.color = Colors.white, @required this.audioSet, this.iconSize = 24})
      : super(key: key);

  @override
  _ToggleFavoriteButtonState createState() => _ToggleFavoriteButtonState();
}

class _ToggleFavoriteButtonState extends State<ToggleFavoriteButton> {
  bool _isFavorite;
  UserPresenter userPresenter;

  @override
  void initState() {
    userPresenter = context.read<UserPresenter>();

    _get();
    super.initState();
  }

  void _get() async {
    var result = await context.read<UserPresenter>().favorites();
    print(result);
  }

  void _onPressed() {
    if (_isFavorite) {
      userPresenter.removeFavorite(widget.audioSet);
    } else {
      userPresenter.addFavorite(widget.audioSet);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: userPresenter.favoritesStream,
      builder: (BuildContext context, AsyncSnapshot<List<AudioSet>> snapshot) {
        _isFavorite = snapshot.data != null && snapshot.data.where((e) => e.id == widget.audioSet.id).isNotEmpty;
        final icon = _isFavorite ? 'assets/img/ic_favo_filled.png' : 'assets/img/ic_favo_outline.png';
        return GestureDetector(
          onTap: () {
            _onPressed();
          },
          child: Container(
            padding: const EdgeInsets.all(8),
            color: Colors.transparent,
            child: ImageIcon(
              AssetImage(icon),
              color: widget.color,
              size: widget.iconSize,
            ),
          ),
        );
      },
    );
  }
}

class PlayerControls extends StatelessWidget {
  final AudioController controller;
  const PlayerControls({Key key, this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorTheme = AppColors.of(context).activeColorTheme();
    final icon = controller.isPlaying ? 'assets/img/ic_pause.png' : 'assets/img/ic_play.png';
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(icon),
          const SizedBox(height: 8),
          BodyText2(
            controller.isPlaying ? '' : 'MUSIC PAUSED',
            fontSize: 16,
            color: colorTheme.accentColor,
            fontWeight: FontWeight.bold,
          )
        ],
      ),
    );
  }
}
