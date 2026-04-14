import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../application/bloc/auth_cubit.dart';
import '../application/bloc/auth_state.dart';
import 'login_page.dart';
import 'setup_pin_page.dart';

class AuthGate extends StatelessWidget {
  final Widget child;

  const AuthGate({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state is AuthInitial) {
          context.read<AuthCubit>().checkStatus();
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (state is AuthNotSetup) {
          return const SetupPinPage();
        }

        if (state is AuthAuthenticated) {
          return child;
        }

        return const LoginPage();
      },
    );
  }
}
