import 'package:flutter/material.dart';
import 'package:pebbl/logic/colors.dart';
import 'package:pebbl/logic/navigation_helper.dart';
import 'package:pebbl/presenter/user_presenter.dart';
import 'package:pebbl/view/components/buttons/pebble_button.dart';
import 'package:pebbl/view/components/modals/dialog_helper.dart';
import 'package:pebbl/view/dashboard_screen.dart';
import 'package:pebbl/view/home_screen.dart';
import 'package:pebbl/view/registration/login_screen.dart';
import 'package:pebbl/view/registration/registration_screen.dart';
import 'package:provider/provider.dart';

class LoginStartScreen extends StatelessWidget {
  const LoginStartScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.of(context).activeColorTheme().backgroundColor,
      appBar: AppBar(
        brightness: Brightness.dark,
        elevation: 0,
        backgroundColor: AppColors.of(context).activeColorTheme().backgroundColor,
      ),
      body: Container(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
        child: SafeArea(
          child: Column(
            children: <Widget>[
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    const SizedBox(height: 24),
                    Image.asset(
                      'assets/img/img_center_piece.png',
                      color: AppColors.of(context).activeColorTheme().accentColor,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Welcome to pebbl',
                      style: Theme.of(context)
                          .textTheme
                          .headline6
                          .copyWith(color: AppColors.of(context).activeColorTheme().accentColor),
                    )
                  ],
                ),
              ),
              PebbleButton(
                title: 'Login',
                onTap: () => NavigationHelper.navigate(context, LoginScreen(), 'LoginScreen'),
              ),
              const SizedBox(height: 8),
              PebbleButton(
                title: 'Sign-up',
                onTap: () => NavigationHelper.navigate(context, RegistrationScreen(), 'RegistrationScreen'),
              ),
              PebbleTextButton(title: 'Use anonymously', onTap: () => _signupAnonymously(context))
            ],
          ),
        ),
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
