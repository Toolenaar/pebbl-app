import 'package:flutter/material.dart';
import 'package:pebbl/logic/audio/audio_controller.dart';
import 'package:pebbl/logic/colors.dart';
import 'package:pebbl/logic/texts.dart';
import 'package:pebbl/model/audio_set.dart';
import 'package:pebbl/presenter/user_presenter.dart';
import 'package:pebbl/view/home/audio/player_art.dart';
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
    final colorTheme = AppColors.getActiveColorTheme(context);
    if (widget.audioSet == null) return Container();

    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          TrackInfo(
            audioSet: widget.audioSet,
          ),
          Expanded(
            child: Center(
              child: Row(
                children: <Widget>[
                  IconButton(
                    color: colorTheme.accentColor,
                    icon: Icon(Icons.skip_previous),
                    iconSize: 32,
                    onPressed: () {
                      audioController.skipPrevious();
                    },
                  ),
                  Expanded(child: Center(child: PlayerArt())),
                  IconButton(
                    color: colorTheme.accentColor,
                    icon: Icon(Icons.skip_next),
                    iconSize: 32,
                    onPressed: () {
                      audioController.skipNext();
                    },
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
                color: audioSet.category.colorTheme.accentColor,
              ),
              BodyText1(
                audioSet.artist.name,
                color: audioSet.category.colorTheme.accentColor,
              ),
            ],
          ),
        ),
        ToggleFavoriteButton(
          audioSet: audioSet,
          color: audioSet.category.colorTheme.accentColor,
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
  Stream _favoriteStream;
  bool _isFavorite;
  UserPresenter userPresenter;

  @override
  void initState() {
    userPresenter = context.read<UserPresenter>();
    _favoriteStream = userPresenter.isFavoriteStream(widget.audioSet);
    super.initState();
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
      stream: _favoriteStream,
      initialData: 'start',
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.data == 'start') return SizedBox();
        _isFavorite = snapshot.data.data != null;
        final icon = _isFavorite ? 'assets/img/ic_favo_filled.png' : 'assets/img/ic_favo_outline.png';
        return GestureDetector(
          onTap: _onPressed,
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
