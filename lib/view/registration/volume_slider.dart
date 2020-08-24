// import 'package:flutter/material.dart';
// import 'package:pebbl/logic/colors.dart';
// import 'package:pebbl/model/stem.dart';
// import 'dart:math';

// class VolumeSlider extends StatelessWidget {
//   final Stem stem;
//   final bool showLabel;
//   final Function(double) volumeChanged;
//   const VolumeSlider({Key key, @required this.stem, @required this.volumeChanged, this.showLabel = true})
//       : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final colorTheme = AppColors.getActiveColorTheme(context);
//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       crossAxisAlignment: CrossAxisAlignment.stretch,
//       children: <Widget>[
//         if (showLabel)
//           Text(
//             stem.name,
//             style: Theme.of(context).textTheme.bodyText2.copyWith(color: Colors.white),
//           ),
//         SliderTheme(
//           data: SliderTheme.of(context).copyWith(
//             activeTrackColor: colorTheme.accentColor,
//             inactiveTrackColor: colorTheme.accentColor40,
//             trackShape: RectangularSliderTrackShape(),
//             trackHeight: 1.0,
//             thumbColor: colorTheme.accentColor40,
//             thumbShape: CustomThumbShape(),
//             overlayColor: Colors.transparent,
//             //overlayShape: RoundSliderOverlayShape(overlayRadius: 28.0),
//           ),
//           child: Container(
//             //  color: Colors.red,
//             child: Slider(
//                 min: 0,
//                 max: 100,
//                 value: stem.volume * 100,
//                 onChanged: (value) {
//                   double volume = value / 100;
//                   volumeChanged(volume);
//                 }),
//           ),
//         ),
//       ],
//     );
//   }
// }

// class CustomThumbShape extends SliderComponentShape {
//   final double thumbRadius;

//   const CustomThumbShape({
//     this.thumbRadius = 12,
//   });

//   @override
//   Size getPreferredSize(bool isEnabled, bool isDiscrete) {
//     return Size.fromRadius(thumbRadius);
//   }

//   @override
//   void paint(
//     PaintingContext context,
//     Offset center, {
//     Animation<double> activationAnimation,
//     Animation<double> enableAnimation,
//     bool isDiscrete,
//     TextPainter labelPainter,
//     RenderBox parentBox,
//     SliderThemeData sliderTheme,
//     TextDirection textDirection,
//     double value,
//   }) {
//     final Canvas canvas = context.canvas;

//     final fillPaint = Paint()
//       ..color = sliderTheme.thumbColor
//       ..style = PaintingStyle.fill;

//     final borderPaint = Paint()
//       ..color = Colors.white
//       ..strokeWidth = 1
//       ..style = PaintingStyle.stroke;

//     canvas.drawCircle(center, thumbRadius, fillPaint);
//     canvas.drawCircle(center, thumbRadius, borderPaint);
//   }
// }

// class RotatedVolumeSlider extends StatelessWidget {
//   final Stem stem;
//   final double degrees;
//   final Function(double) volumeChanged;
//   const RotatedVolumeSlider({Key key, @required this.stem, @required this.volumeChanged, this.degrees = 0})
//       : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final radians = degrees * pi / 180;
//     print(radians);
//     return LayoutBuilder(
//       builder: (ctx, constraints) {
//         return Transform.rotate(
//           angle: radians,
//           origin: Offset(0, 0),
//           child: VolumeSlider(
//             stem: stem,
//             showLabel: false,
//             volumeChanged: volumeChanged,
//           ),
//         );
//       },
//     );
//   }
// }
