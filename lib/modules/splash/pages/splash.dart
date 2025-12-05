import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:servelq_agent/services/session_manager.dart';

import '../bloc/splash_bloc.dart';

class Splash extends StatelessWidget {
  const Splash({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<SplashBloc, SplashState>(
        listener: (_, state) {
          switch (state) {
            case SplashInitial():
            case NavigateToHomeActionState():
              if (SessionManager.getUsername().isEmpty) {
                context.go('/login');
              } else {
                context.go('/agent');
              }
          }
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              alignment: Alignment.center,
              child: Image.asset("assets/images/logo.png", height: 150),
            ),
          ],
        ),
      ),
    );
  }
}
