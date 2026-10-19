import 'package:flutter/widgets.dart';

/// Navigation helpers shared by the screens that finish a job and send the
/// gym owner back to the home screen.
///
/// Several screens used to do this with `Navigator.popAndPushNamed('/home')`,
/// which pops the current page and then builds a *brand new* copy of the app
/// shell on top of the one already sitting underneath. The user saw the old
/// home for a frame, then a freshly built one animate in over it -- the
/// blink -- and the dashboard re-ran all of its Firestore queries, reset to
/// the Home tab and lost its scroll position. It also left the discarded
/// shells on the stack, so the device back button walked through stale
/// copies of home.
void goHome(BuildContext context) {
  final navigator = Navigator.of(context);
  if (navigator.canPop()) {
    // The live home shell is still at the bottom of the stack: unwind to it
    // rather than building another one.
    navigator.popUntil((route) => route.isFirst);
  } else {
    // Nothing to pop, so the shell was replaced away earlier in this flow
    // (adding a member from the "Add" tab does this on its way to the
    // invoice). Build one, since there is no longer a home to go back to.
    navigator.pushNamedAndRemoveUntil('/home', (route) => false);
  }
}
