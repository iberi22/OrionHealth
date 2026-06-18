import 'package:get_it/get_it.dart';

/// Resets GetIt instance to allow clean registration in test setUp.
void resetGetIt() {
  GetIt.instance.reset();
}
