import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../router/app_routes.dart';
import '../../shared/widgets/sticker_button.dart';
import '../../shared/widgets/sticker_cards.dart';
import '../../shared/widgets/sticker_text_field.dart';
import '../../theme/app_tokens.dart';
import 'auth_controller.dart';
import 'auth_error_messages.dart';
import 'auth_validators.dart';
import 'widgets/auth_error_banner.dart';
import 'widgets/auth_header.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  bool _obscurePassword = true;
  String? _serverError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (ref.read(authControllerProvider).isLoading) return;
    if (!_formKey.currentState!.validate()) {
      if (validateEmail(_emailController.text) != null) {
        _emailFocus.requestFocus();
      } else {
        _passwordFocus.requestFocus();
      }
      return;
    }

    setState(() => _serverError = null);
    try {
      await ref
          .read(authControllerProvider.notifier)
          .signIn(_emailController.text, _passwordController.text);
    } catch (error) {
      if (!mounted) return;
      setState(() => _serverError = authErrorMessage(error));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authControllerProvider).isLoading;
    final horizontalPadding =
        MediaQuery.sizeOf(context).width >= AppBreakpoint.tablet
        ? AppSpace.lg
        : AppSpace.md;

    return Scaffold(
      body: SafeArea(
        child: AutofillGroup(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: AppSpace.lg,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: AppLayout.authFormMaxWidth,
                ),
                child: Column(
                  children: [
                    const AuthHeader(title: 'Accedi'),
                    const SizedBox(height: AppSpace.lg),
                    StickerCard(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (_serverError != null) ...[
                              AuthErrorBanner(message: _serverError!),
                              const SizedBox(height: AppSpace.md),
                            ],
                            StickerTextField(
                              controller: _emailController,
                              focusNode: _emailFocus,
                              labelText: 'Email',
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              autofillHints: const [AutofillHints.email],
                              autocorrect: false,
                              enableSuggestions: false,
                              prefixIcon: const Icon(Icons.email_outlined),
                              validator: validateEmail,
                              onFieldSubmitted: (_) =>
                                  _passwordFocus.requestFocus(),
                            ),
                            const SizedBox(height: AppSpace.md),
                            StickerTextField(
                              controller: _passwordController,
                              focusNode: _passwordFocus,
                              labelText: 'Password',
                              textInputAction: TextInputAction.done,
                              autofillHints: const [AutofillHints.password],
                              obscureText: _obscurePassword,
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                tooltip: _obscurePassword
                                    ? 'Mostra password'
                                    : 'Nascondi password',
                                constraints: const BoxConstraints(
                                  minWidth: AppTapTarget.minimum,
                                  minHeight: AppTapTarget.minimum,
                                ),
                                onPressed: () => setState(
                                  () => _obscurePassword = !_obscurePassword,
                                ),
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                ),
                              ),
                              validator: (value) =>
                                  value == null || value.isEmpty
                                  ? 'Inserisci la password'
                                  : null,
                              onFieldSubmitted: (_) => _submit(),
                            ),
                            const SizedBox(height: AppSpace.lg),
                            StickerButton(
                              label: 'ACCEDI',
                              isLoading: isLoading,
                              onPressed: isLoading ? null : _submit,
                            ),
                            const SizedBox(height: AppSpace.xs),
                            TextButton(
                              style: _secondaryButtonStyle(context),
                              onPressed: () =>
                                  context.go(AppRoutes.forgotPassword),
                              child: const Text('Password dimenticata?'),
                            ),
                            TextButton(
                              style: _secondaryButtonStyle(context),
                              onPressed: () => context.go(AppRoutes.register),
                              child: const Text(
                                'Non hai un account? Registrati',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

ButtonStyle _secondaryButtonStyle(BuildContext context) => TextButton.styleFrom(
  minimumSize: const Size.fromHeight(AppTapTarget.minimum),
  textStyle: Theme.of(context).textTheme.bodyMedium,
);
