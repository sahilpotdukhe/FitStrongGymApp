import 'package:fitstrong_gym/src/custom_import.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;
  bool _sendingReset = false;
  final _loginKey = GlobalKey<FormState>();
  final FirebaseAuth auth = FirebaseAuth.instance;
  final AuthMethods authMethods = AuthMethods();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_loginKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final user = await authMethods.logInByEmail(
      emailController.text.trim(),
      passwordController.text,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (user != null) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => SplashScreen()),
        (route) => false,
      );
    } else {
      // One clear failure message. Previously this showed a dialog *and* a
      // snackbar saying the same thing.
      showErrorDialog(
        context: context,
        title: 'Could not sign in',
        desc: authMethods.lastErrorMessage ??
            'Login failed. Please check your details and try again.',
      );
    }
  }

  Future<void> _sendResetEmail() async {
    final email = emailController.text.trim();
    if (email.isEmpty) {
      showErrorDialog(
        context: context,
        title: 'Email needed',
        desc: 'Type the email address for your account first, then tap '
            '"Forgot password?" again.',
      );
      return;
    }

    setState(() => _sendingReset = true);
    String? failure;
    try {
      await auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      failure = AuthMethods.describeAuthError(e);
    } catch (_) {
      failure = 'Could not send the reset email. Check your connection and '
          'try again.';
    }

    if (!mounted) return;
    setState(() => _sendingReset = false);

    if (failure != null) {
      showErrorDialog(
        context: context,
        title: 'Reset email not sent',
        desc: failure,
      );
      return;
    }

    showShadcnAlertDialog(
      context,
      icon: const ShadcnIconBadge(Icons.mark_email_read_outlined),
      title: 'Check your inbox',
      description:
          'We sent a password reset link to $email.\n\nNo email after a minute? '
          'Check the spam folder, or make sure the address is right.',
      cancelLabel: null,
      confirmLabel: 'Got it',
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.shadcn;

    return AuthScaffold(
      title: 'Welcome back',
      subtitle: 'Sign in to manage your members, plans and payments.',
      child: Form(
        key: _loginKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ShadcnInput(
              controller: emailController,
              label: 'Email',
              placeholder: 'you@gym.com',
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.email],
              leading: const Icon(Icons.alternate_email_rounded, size: 18),
              validator: ShadcnValidators.combine([
                ShadcnValidators.required('Enter your email address'),
                ShadcnValidators.email('That does not look like a valid email'),
              ]),
            ),
            const ShadcnGap(ShadcnSpacing.lg),
            ShadcnPasswordInput(
              controller: passwordController,
              label: 'Password',
              placeholder: 'Your password',
              textInputAction: TextInputAction.done,
              leading: const Icon(Icons.lock_outline_rounded, size: 18),
              onSubmitted: (_) => _signIn(),
              // Sign-in only checks that something was typed. The strength
              // rules belong on sign-up; enforcing them here would lock out
              // anyone whose existing password predates them.
              validator: ShadcnValidators.required('Enter your password'),
            ),
            const ShadcnGap(ShadcnSpacing.sm),
            Align(
              alignment: Alignment.centerRight,
              child: ShadcnButton(
                variant: ShadcnButtonVariant.link,
                size: ShadcnButtonSize.sm,
                loading: _sendingReset,
                onPressed: _sendResetEmail,
                child: const Text('Forgot password?'),
              ),
            ),
            const ShadcnGap(ShadcnSpacing.lg),
            ShadcnButton(
              fullWidth: true,
              size: ShadcnButtonSize.lg,
              loading: _isLoading,
              onPressed: _signIn,
              child: const Text('Sign in'),
            ),
          ],
        ),
      ),
      footer: Column(
        children: [
          const ShadcnSeparator(label: 'OR'),
          const ShadcnGap(ShadcnSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ShadcnText(
                "Don't have an account?",
                variant: ShadcnTextVariant.muted,
              ),
              ShadcnButton(
                variant: ShadcnButtonVariant.link,
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SignUpScreen()),
                ),
                child: Text(
                  'Sign up',
                  style: TextStyle(color: t.primary),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
