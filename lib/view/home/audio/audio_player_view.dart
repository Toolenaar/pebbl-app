import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:pebbl/logic/audio/audio_controller.dart';
import 'package:pebbl/logic/colors.dart';
import 'package:pebbl/logic/texts.dart';
import 'package:pebbl/model/audio_set.dart';
import 'package:pebbl/model/category.dart';
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
  bool _controlsFeedbackVisible = false;
  String _helpText = 'PLAYING';
  @override
  void initState() {
    audioController = context.read<AudioController>();
    super.initState();
  }

  Widget _playerControls(CategoryColorTheme colorTheme) {
    return AnimatedOpacity(
      opacity: _controlsFeedbackVisible ? 1.0 : 0.0,
      duration: Duration(milliseconds: _controlsFeedbackVisible ? 500 : 1000),
      curve: Curves.easeInOut,
      onEnd: () {
        setState(() {
          _controlsFeedbackVisible = false;
        });
      },
      child: Container(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            BodyText2(
              _helpText,
              fontSize: 24,
              color: colorTheme.accentColor,
              fontWeight: FontWeight.bold,
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.audioSet == null) return Container();
    final colorTheme = AppColors.of(context).activeColorTheme();
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
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
                        if (!audioController.isPlaying) {
                          audioController.play();
                        }
                        _helpText = 'PREVIOUS';
                        _controlsFeedbackVisible = true;
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
                        _helpText = audioController.isPlaying ? 'PAUSED' : 'PLAYING';
                        _controlsFeedbackVisible = true;
                        // setState(() {});
                      },
                      child: Container(
                        color: Colors.transparent, //Colors.yellow.withOpacity(0.4),
                        child: Center(child: _playerControls(colorTheme)),
                      ),
                    ),
                  ),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      splashColor: colorTheme.accentColor.withOpacity(0.2),
                      highlightColor: colorTheme.accentColor.withOpacity(0.2),
                      onTap: () {
                        _helpText = 'NEXT';
                        _controlsFeedbackVisible = true;
                        audioController.skipNext();
                        if (!audioController.isPlaying) {
                          audioController.play();
                        }
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

class TrackInfo extends StatefulWidget {
  const TrackInfo({Key key}) : super(key: key);

  @override
  _TrackInfoState createState() => _TrackInfoState();
}

class _TrackInfoState extends State<TrackInfo> {
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
        final screenState = snapshot.data;

        final mediaItem = screenState?.mediaItem;
        final state = screenState?.playbackState;
        final processingState = state?.processingState ?? AudioProcessingState.none;
        print(processingState);
        print(mediaItem);
        final audioSet = audioController.setForMediaItem(mediaItem);
        if (audioSet == null) return SizedBox();
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
      },
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
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
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
