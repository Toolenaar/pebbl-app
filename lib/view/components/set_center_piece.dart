import 'dart:math';
import 'package:pebbl/presenter/sets_presenter.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:pebbl/model/audio_set.dart';
import 'package:pebbl/model/stem.dart';
import 'package:pebbl/view/volume_slider.dart';

class SetCenterpiece extends StatefulWidget {
  const SetCenterpiece({Key key}) : super(key: key);

  @override
  _SetCenterpieceState createState() => _SetCenterpieceState();
}

class _SetCenterpieceState extends State<SetCenterpiece> {
  Offset offsetForIndex(Offset center, double angle) {
    final radians = angle * pi / 180;

    final x = center.dx + 124 * cos(radians);
    final y = center.dy + 124 * sin(radians);
    return Offset(x, y);
  }

  Offset center(BoxConstraints constraints) {
    return Offset((constraints.maxWidth / 2), ((constraints.maxHeight) / 2));
  }

  void _changeVolume(Stem stem, double volume) async {
    context.read<SetsPresenter>().changeStemVolume(stem.filePath, volume);
    stem.volume = volume;
    setState(() {});
  }

  Widget _calculateVolumeSliderPosition(BoxConstraints constraints, int index, Stem stem) {
    final sliderWidth = constraints.maxWidth / 2 - 42;
    final degrees = (index * 45).toDouble();
    final centerOffset = center(constraints);
    final indexOffset = offsetForIndex(centerOffset, degrees);

    return Positioned(
      left: indexOffset.dx - 71,
      top: indexOffset.dy - 28,
      child: Opacity(
        opacity: 0.3,
        child: SizedBox(
          width: sliderWidth,
          child: RotatedVolumeSlider(
            degrees: degrees,
            stem: stem,
            volumeChanged: (volume) => _changeVolume(stem, volume),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeSet = context.select<SetsPresenter, AudioSet>((value) => value.activeSet);
    final isPlaying = context.select<SetsPresenter, bool>((value) => value.isPlaying);
    return LayoutBuilder(builder: (context, constraints) {
      var sliders = [];
      if (isPlaying) {
        final stems = activeSet.downloadedSet.downloadedStems.take(8).toList();
        sliders = activeSet.downloadedSet.downloadedStems
            .map((stem) => _calculateVolumeSliderPosition(constraints, stems.indexOf(stem), stem))
            .toList();
      }

      //final centerOffset = center(constraints);
      return Transform.rotate(
        angle: -90 * pi / 180, //rotate so that index 1 is facing upwards
        child: Stack(
          overflow: Overflow.visible,
          children: <Widget>[
            ...sliders,
            // Positioned(
            //     left: centerOffset.dx - 64,
            //     top: centerOffset.dy - 64,
            //     child: Container(
            //       decoration: BoxDecoration(
            //           color: Colors.blue.withOpacity(0.4), borderRadius: BorderRadius.circular(128)),
            //       width: 128,
            //       height: 128,
            //       child: Center(
            //         child: Container(
            //           height: 6,
            //           width: 6,
            //           decoration: BoxDecoration(color: Colors.yellow, borderRadius: BorderRadius.circular(6)),
            //         ),
            //       ),
            //     )),
            Center(child: Image.asset('assets/img/img_center_piece.png')),
          ],
        ),
      );
    });
  }
}
