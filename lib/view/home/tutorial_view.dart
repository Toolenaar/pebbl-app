import 'package:flutter/material.dart';
import 'package:pebbl/logic/colors.dart';
import 'package:pebbl/logic/texts.dart';
import 'package:pebbl/view/components/buttons/pebble_button.dart';

class TutorialView extends StatefulWidget {
  final Function onTourCompleted;
  const TutorialView({Key key, @required this.onTourCompleted}) : super(key: key);

  @override
  _TutorialViewState createState() => _TutorialViewState();
}

class _TutorialViewState extends State<TutorialView> {
  int _step = 0;

  @override
  Widget build(BuildContext context) {
    if (_step > 2) return const SizedBox();
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PebbleButton(
            title: _step == 2 ? 'Try Pebbl' : 'Next',
            backgroundColor: AppColors.componentBg,
            onTap: () {
              setState(() {
                _step += 1;
              });
              if (_step > 2) widget.onTourCompleted();
            },
          ),
          const SizedBox(height: 16),
          if (_step == 0)
            _TutorialContent(
              title: '1/3 How do you feel?',
              subtitle: 'Pick a category. We have all kinds of flavours.',
            ),
          if (_step == 1)
            _TutorialContent(
              indicaterAlignment: Alignment.center,
              title: '2/3 Set a timer',
              subtitle: 'The default is set to infinite. Are you up for the task?',
            ),
          if (_step == 2)
            _TutorialContent(
              indicaterAlignment: Alignment.centerRight,
              title: '3/3 Favorites',
              subtitle:
                  'Like what you hear? Save your sound and re-visit it later. Try shuffle mode for a unique soundscape experience.',
            ),
          // Align(
          //   alignment: Alignment.centerLeft,
          //   child: Padding(
          //     padding: const EdgeInsets.only(left: 16),
          //     child: CustomPaint(size: Size(24, 12), painter: DrawTriangleShape()),
          //   ),
          // )
        ],
      ),
    );
  }
}

class _TutorialContent extends StatelessWidget {
  final AlignmentGeometry indicaterAlignment;
  final String title;
  final String subtitle;
  const _TutorialContent(
      {Key key, this.indicaterAlignment = Alignment.centerLeft, @required this.title, @required this.subtitle})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bgColor = AppColors.getActiveColorTheme(context).backgroundColor;
    return Stack(
      overflow: Overflow.visible,
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(border: Border.all(color: Colors.white)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              BodyText2(
                title,
                fontSize: 16,
              ),
              const SizedBox(height: 4),
              BodyText2(
                subtitle,
                fontSize: 14,
                fontStyle: FontStyle.italic,
              )
            ],
          ),
        ),
        Positioned(
          bottom: -12,
          left: 0,
          right: 0,
          child: Align(
            alignment: indicaterAlignment,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: CustomPaint(size: Size(24, 12), painter: DrawTriangleShape(bgColor)),
            ),
          ),
        )
      ],
    );
  }
}

class DrawTriangleShape extends CustomPainter {
  Paint painter;
  final Color backgroundColor;

  DrawTriangleShape(this.backgroundColor) {
    painter = Paint()
      ..strokeWidth = 1
      ..color = Colors.white
      ..style = PaintingStyle.fill;
  }

  @override
  void paint(Canvas canvas, Size size) {
    var path = Path();

    // path.moveTo(size.width / 2, 0);
    // path.lineTo(0, size.height);
    // path.lineTo(size.height, size.width);
    // path.close();

    // path.moveTo(size.width / 2, size.height);
    // path.lineTo(0, 0);
    // path.moveTo(size.width / 2, size.height);
    // path.lineTo(size.width, 0);
    //path.close();
    canvas.drawLine(
        Offset(0, 0),
        Offset(size.width, 0),
        Paint()
          ..strokeWidth = 2
          ..color = backgroundColor
          ..style = PaintingStyle.fill);
    canvas.drawLine(Offset(0, 0), Offset(size.width / 2, size.height), painter);
    canvas.drawLine(Offset(size.width, 0), Offset(size.width / 2, size.height), painter);

    // canvas.drawPath(path, painter);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
