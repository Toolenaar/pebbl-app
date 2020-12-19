import 'package:flutter/material.dart';
import 'package:pebbl/logic/colors.dart';
import 'package:pebbl/logic/navigation_helper.dart';
import 'package:pebbl/logic/texts.dart';
import 'package:pebbl/presenter/user_presenter.dart';
import 'package:pebbl/view/components/animation_view.dart';
import 'package:pebbl/view/components/buttons/pebble_button.dart';
import 'package:pebbl/view/components/modals/dialog_helper.dart';
import 'package:pebbl/view/home_screen.dart';
import 'package:pebbl/view/registration/registration_screen.dart';
import 'package:provider/provider.dart';

class AnonymousScreen extends StatelessWidget {
  const AnonymousScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = AppColors.of(context).activeColorTheme();
    return Scaffold(
      backgroundColor: theme.backgroundColor,
      appBar: AppBar(
          iconTheme: IconThemeData(color: theme.accentColor),
          title: H1Text('Anonymous', fontSize: 20, color: theme.accentColor),
          brightness: Brightness.dark,
          elevation: 0,
          backgroundColor: theme.backgroundColor),
      body: Stack(
        children: [
          Positioned.fill(
            child: AnimationView(color: theme.accentColor, animationFile: 'assets/animations/rain.json'),
          ),
          Container(
            color: Colors.transparent,
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Spacer(),
                  BodyText1(
                    'Heads up',
                    color: theme.accentColor,
                    fontSize: 20,
                  ),
                  const SizedBox(height: 4),
                  BodyText2(
                    'If you continue without creating an account your preferences will not be saved',
                    color: theme.accentColor,
                    fontSize: 20,
                  ),
                  const SizedBox(height: 32),
                  ThemedPebbleButton(
                      title: 'Create Account',
                      categoryTheme: theme,
                      onTap: () => NavigationHelper.navigate(context, RegistrationScreen(), 'RegistrationScreen')),
                  const SizedBox(height: 8),
                  ThemedPebbleButton(
                      title: 'Continue anyway', categoryTheme: theme, onTap: () => _signupAnonymously(context))
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _signupAnonymously(BuildContext context) async {
    var id = await context.read<UserPresenter>().signUpAnonymously();
    if (id == null) {
      DialogHelper.showErrorDialog(
          context: context,
          title: 'Oops something went wrong',
          error: 'Something went wrong trying to log you in anonymously. Please try again');
    } else {
      NavigationHelper.navigateAndRemove(context, HomePage(), 'HomePage');
    }
  }
}
