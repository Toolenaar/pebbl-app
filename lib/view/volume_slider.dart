import 'package:flutter/material.dart';
import 'package:pebbl/logic/colors.dart';
import 'package:pebbl/model/stem.dart';

class VolumeSlider extends StatelessWidget {
  final Stem stem;
  final Function(double) volumeChanged;
  const VolumeSlider({Key key, @required this.stem, @required this.volumeChanged}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(stem.name,style: Theme.of(context).textTheme.bodyText2.copyWith(color:Colors.white),),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: Colors.white,
            inactiveTrackColor:Colors.white.withOpacity(0.3),
            trackShape: RectangularSliderTrackShape(),
            trackHeight: 1.0,
            thumbColor: AppColors.background,
            thumbShape: CustomThumbShape(),
            overlayColor: Colors.transparent,
            overlayShape: RoundSliderOverlayShape(overlayRadius: 28.0),
          ),
          child: Slider(
              min: 0,
              max: 100,
              value: stem.volume * 100,
              onChanged: (value) {
                double volume = value / 100;
                volumeChanged(volume);
              }),
        ),
      ],
    );
  }
}

class CustomThumbShape extends SliderComponentShape {
  final double thumbRadius;

  const CustomThumbShape({
    this.thumbRadius = 12,
  });

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size.fromRadius(thumbRadius);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    Animation<double> activationAnimation,
    Animation<double> enableAnimation,
    bool isDiscrete,
    TextPainter labelPainter,
    RenderBox parentBox,
    SliderThemeData sliderTheme,
    TextDirection textDirection,
    double value,
  }) {
    final Canvas canvas = context.canvas;

  

    final fillPaint = Paint()
      ..color = sliderTheme.thumbColor
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(center, thumbRadius, fillPaint);
    canvas.drawCircle(center, thumbRadius, borderPaint);
  }
}
