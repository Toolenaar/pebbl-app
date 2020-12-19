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
  Widget _mainView() {
    final colorTheme = AppColors.of(context).activeColorTheme();
    if (_step == 2) {
      return Positioned(
        top: 16,
        right: 0,
        child: Image.asset(
          'assets/img/ic_favo_outline.png',
          color: colorTheme.accentColor,
        ),
      );
    }

    if (_step == 3) {
      return Positioned.fill(
        child: Container(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 2,
                child: Container(
                  height: MediaQuery.of(context).size.height,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(topRight: Radius.circular(64), bottomRight: Radius.circular(64)),
                      color: Colors.white24),
                  child: Center(
                    child: BodyText2(
                      'Previous',
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                width: 8,
              ),
              Expanded(
                flex: 3,
                child: Container(
                  height: MediaQuery.of(context).size.height,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(24), color: Colors.white24),
                  child: Center(
                    child: BodyText2(
                      'Play/Pause',
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                width: 8,
              ),
              Expanded(
                flex: 2,
                child: Container(
                  height: MediaQuery.of(context).size.height,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(64), bottomLeft: Radius.circular(64)),
                      color: Colors.white24),
                  child: Center(
                    child: BodyText2(
                      'Next',
                      fontSize: 14,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      );
    }
    return SizedBox();
  }

  @override
  Widget build(BuildContext context) {
    if (_step > 3) return const SizedBox();
    return Stack(
      children: [
        _mainView(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Spacer(),
              ThemedPebbleButton(
                title: _step == 3 ? 'Try Pomfi' : 'Next',
                categoryTheme: AppColors.of(context).activeColorTheme(),
                onTap: () {
                  setState(() {
                    _step += 1;
                  });
                  if (_step > 3) widget.onTourCompleted();
                },
              ),
              const SizedBox(height: 16),
              if (_step == 0)
                _TutorialContent(
                  title: '1/4 Pick a playlist that fits your mood',
                  subtitle: 'Need help studying? Can’t fall asleep? We got your back!',
                ),
              if (_step == 1)
                _TutorialContent(
                  indicaterAlignment: Alignment.center,
                  title: '2/4 Set a (pomodoro) timer',
                  subtitle: 'Study for a bit, rest for a while. Use your time wisely.',
                ),
              if (_step == 2)
                _TutorialContent(
                  indicaterAlignment: Alignment.centerRight,
                  title: '3/4 Favorites',
                  subtitle:
                      'Press the heart icon on the top right to save your favorite tunes. Use shuffle mode to mix it up!',
                ),
              if (_step == 3)
                _TutorialContent(
                  indicaterAlignment: null,
                  title: '4/4 Play/Pause + Next/Previous',
                  subtitle:
                      'A tap on either sides of the screen will play the next or previous tune. A tap in the middle of the screen will pause the music.',
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
        ),
      ],
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
    final bgColor = AppColors.of(context).activeColorTheme().backgroundColor;
    return Stack(
      overflow: Overflow.visible,
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
              border: Border.all(color: AppColors.of(context).activeColorTheme().accentColor), color: bgColor),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              BodyText2(
                title,
                fontSize: 16,
                color: AppColors.of(context).activeColorTheme().accentColor,
              ),
              const SizedBox(height: 4),
              BodyText2(
                subtitle,
                fontSize: 14,
                fontStyle: FontStyle.italic,
                color: AppColors.of(context).activeColorTheme().accentColor,
              )
            ],
          ),
        ),
        if (indicaterAlignment != null)
          Positioned(
            bottom: -12,
            left: 0,
            right: 0,
            child: Align(
              alignment: indicaterAlignment,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: CustomPaint(
                    size: Size(24, 12),
                    painter: DrawTriangleShape(bgColor, AppColors.of(context).activeColorTheme().accentColor)),
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
  final Color color;

  DrawTriangleShape(this.backgroundColor, this.color) {
    painter = Paint()
      ..strokeWidth = 1
      ..color = color
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
