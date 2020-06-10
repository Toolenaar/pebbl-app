import 'package:flutter/material.dart';
import 'package:pebbl/logic/colors.dart';
import 'package:pebbl/logic/navigation_helper.dart';
import 'package:pebbl/view/components/buttons/pebble_button.dart';
import 'package:pebbl/view/registration/login_screen.dart';
import 'package:pebbl/view/registration/registration_screen.dart';

class LoginStartScreen extends StatelessWidget {
  const LoginStartScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        brightness: Brightness.dark,
        elevation: 0,
        backgroundColor: AppColors.background,
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
                      color: AppColors.text,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Welcome to pebbl',
                      style: Theme.of(context).textTheme.headline6.copyWith(color: AppColors.text),
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
              PebbleTextButton(
                title: 'Use anonymously',
                onTap: () {},
              )
            ],
          ),
        ),
      ),
    );
  }
}