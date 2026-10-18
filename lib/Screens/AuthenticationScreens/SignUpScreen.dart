import 'dart:async';

import 'package:fitstrong_gym/src/custom_import.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool _isLoading = false;
  bool isVerified = false;

  /// True once the account exists and we are polling for the user to click
  /// the link in their inbox. The form is swapped for a "waiting" panel so
  /// nobody edits fields that have already been submitted.
  bool _awaitingVerification = false;

  Timer? timer;
  final _signupKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();

  final AuthMethods authMethods = AuthMethods();

  static const String _defaultProfilePic =
      'https://firebasestorage.googleapis.com/v0/b/echat-888ef.appspot.com/o/user.jpg?alt=media&token=6f598b3e-9c10-49ee-8a68-49468b32bddf';
  static const String _defaultSignature =
      'https://firebasestorage.googleapis.com/v0/b/fitstrong-gym.appspot.com/o/qrgeneral.png?alt=media&token=ffa3b5fe-ade2-4d7e-b675-bfdf2b281f5a';

  @override
  void dispose() {
    timer?.cancel();
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    mobileController.dispose();
    super.dispose();
  }

  Future checkEmailVerified(User user) async {
    await FirebaseAuth.instance.currentUser!.reload();
    if (!mounted) return;
    setState(() {
      isVerified = FirebaseAuth.instance.currentUser!.emailVerified;
    });

    if (!isVerified) return;
    timer?.cancel();

    authMethods.setUserProfile(
      name: nameController.text,
      email: emailController.text,
      profilePic: _defaultProfilePic,
      authType: 'emailAuth',
      mobilenumber: mobileController.text,
      signatureImageUrl: _defaultSignature,
      address: '',
      merchantName: '',
      upiId: '',
    );

    showSuccessDialog(
      context: context,
      title: 'Email verified',
      desc: 'Your account is ready. Taking you to your dashboard now.',
    );
    await Future.delayed(const Duration(seconds: 6));
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => CustomBottomNavigationBar()),
      (route) => false,
    );
  }

  Future<void> _createAccount() async {
    if (!_signupKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final user = await authMethods.createAccountByEmail(
      emailController.text.trim(),
      passwordController.text,
      context,
    );

    if (!mounted) return;

    if (user == null) {
      setState(() => _isLoading = false);
      showErrorDialog(
        context: context,
        title: 'Could not create account',
        desc:
            authMethods.lastErrorMessage ?? 'Sign up failed. Please try again.',
      );
      return;
    }

    if (isVerified) {
      setState(() => _isLoading = false);
      return;
    }

    await user.sendEmailVerification();
    timer = Timer.periodic(
      const Duration(seconds: 3),
      (_) => checkEmailVerified(user),
    );

    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _awaitingVerification = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = context.shadcn;

    if (_awaitingVerification) {
      return AuthScaffold(
        title: 'Verify your email',
        subtitle: 'One last step before your gym is set up.',
        child: _VerificationPanel(email: emailController.text.trim()),
        footer: ShadcnButton(
          variant: ShadcnButtonVariant.ghost,
          fullWidth: true,
          onPressed: () {
            timer?.cancel();
            Navigator.pop(context);
          },
          child: const Text('Back to sign in'),
        ),
      );
    }

    return AuthScaffold(
      title: 'Create your account',
      subtitle: 'Set up your gym in a couple of minutes.',
      child: Form(
        key: _signupKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ShadcnInput(
              controller: nameController,
              label: 'Full name',
              placeholder: 'Sahil Potdukhe',
              keyboardType: TextInputType.name,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              leading: const Icon(Icons.person_outline_rounded, size: 18),
              validator: ShadcnValidators.combine([
                ShadcnValidators.required('Enter your name'),
                ShadcnValidators.pattern(
                  RegExp(r'^[a-zA-Z ]+$'),
                  'Use letters and spaces only',
                ),
              ]),
            ),
            const ShadcnGap(ShadcnSpacing.lg),
            ShadcnInput(
              controller: emailController,
              label: 'Email',
              placeholder: 'you@gym.com',
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.email],
              helperText: 'We send a verification link here.',
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
              placeholder: 'At least 8 characters',
              textInputAction: TextInputAction.next,
              leading: const Icon(Icons.lock_outline_rounded, size: 18),
              // Spelled out up front rather than only as an error after the
              // fact, so the rule is a guide instead of a surprise.
              helperText:
                  '8+ characters with an uppercase, a lowercase, a number and a symbol.',
              validator: ShadcnValidators.combine([
                ShadcnValidators.required('Set a password'),
                ShadcnValidators.pattern(
                  RegExp(
                      r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$'),
                  'Needs 8+ characters with an uppercase, lowercase, number and symbol',
                ),
              ]),
            ),
            const ShadcnGap(ShadcnSpacing.lg),
            ShadcnInput(
              controller: mobileController,
              label: 'Phone number',
              placeholder: '10-digit mobile number',
              keyboardType: TextInputType.phone,
              maxLength: 10,
              textInputAction: TextInputAction.done,
              leading: const Icon(Icons.phone_outlined, size: 18),
              validator: ShadcnValidators.combine([
                ShadcnValidators.required('Enter your phone number'),
                ShadcnValidators.pattern(
                  RegExp(r'^[0-9]{10}$'),
                  'Enter a 10 digit phone number',
                ),
              ]),
            ),
            const ShadcnGap(ShadcnSpacing.xl),
            ShadcnButton(
              fullWidth: true,
              size: ShadcnButtonSize.lg,
              loading: _isLoading,
              onPressed: _createAccount,
              child: const Text('Create account'),
            ),
          ],
        ),
      ),
      footer: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ShadcnText(
            'Already have an account?',
            variant: ShadcnTextVariant.muted,
          ),
          ShadcnButton(
            variant: ShadcnButtonVariant.link,
            onPressed: () => Navigator.pop(context),
            child: Text('Sign in', style: TextStyle(color: t.primary)),
          ),
        ],
      ),
    );
  }
}

/// Shown while the app polls Firebase every few seconds waiting for the
/// verification link to be clicked. Replaces a 13-second auto-closing dialog,
/// which hid the instructions right when people went to look for them.
class _VerificationPanel extends StatelessWidget {
  const _VerificationPanel({required this.email});

  final String email;

  @override
  Widget build(BuildContext context) {
    final t = context.shadcn;
    return ShadcnCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const ShadcnIconBadge(Icons.mark_email_unread_outlined),
              const ShadcnGap(ShadcnSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShadcnText(
                      'Link sent',
                      variant: ShadcnTextVariant.h4,
                    ),
                    ShadcnText(email, variant: ShadcnTextVariant.muted),
                  ],
                ),
              ),
            ],
          ),
          const ShadcnGap(ShadcnSpacing.lg),
          const ShadcnSeparator(),
          const ShadcnGap(ShadcnSpacing.lg),
          ShadcnText(
            'Open the email and tap the link. This page moves on by itself as '
            'soon as you do — no need to come back and refresh.',
            variant: ShadcnTextVariant.muted,
          ),
          const ShadcnGap(ShadcnSpacing.lg),
          Row(
            children: [
              SizedBox(
                height: 16,
                width: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: t.primary,
                ),
              ),
              const ShadcnGap(ShadcnSpacing.sm),
              ShadcnText(
                'Waiting for verification…',
                variant: ShadcnTextVariant.small,
              ),
            ],
          ),
          const ShadcnGap(ShadcnSpacing.md),
          ShadcnText(
            "Nothing in your inbox? Check the spam folder.",
            variant: ShadcnTextVariant.small,
          ),
        ],
      ),
    );
  }
}
