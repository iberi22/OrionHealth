import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../application/bloc/auth_cubit.dart';

class SessionInteractionListener extends StatelessWidget {
  final Widget child;

  const SessionInteractionListener({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => _handleInteraction(context),
      onPointerMove: (_) => _handleInteraction(context),
      onPointerUp: (_) => _handleInteraction(context),
      child: child,
    );
  }

  void _handleInteraction(BuildContext context) {
    context.read<AuthCubit>().resetInactivityTimer();
  }
}
