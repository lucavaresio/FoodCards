import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../constants/auth_constants.dart';
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

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmationController = TextEditingController();
  final _nameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmationFocus = FocusNode();
  bool _obscurePassword = true;
  bool _obscureConfirmation = true;
  String? _serverError;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmationController.dispose();
    _nameFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _confirmationFocus.dispose();
    super.dispose();
  }

  void _focusFirstInvalidField() {
    if (validateDisplayName(_nameController.text) != null) {
      _nameFocus.requestFocus();
    } else if (validateEmail(_emailController.text) != null) {
      _emailFocus.requestFocus();
    } else if (validatePassword(_passwordController.text) != null) {
      _passwordFocus.requestFocus();
    } else {
      _confirmationFocus.requestFocus();
    }
  }

  Future<void> _submit() async {
    if (ref.read(authControllerProvider).isLoading) return;
    if (!_formKey.currentState!.validate()) {
      _focusFirstInvalidField();
      return;
    }

    setState(() => _serverError = null);
    try {
      await ref
          .read(authControllerProvider.notifier)
          .register(
            _emailController.text,
            _passwordController.text,
            _nameController.text,
          );
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
                    const AuthHeader(title: 'Crea il tuo account'),
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
                              controller: _nameController,
                              focusNode: _nameFocus,
                              labelText: 'Nome utente',
                              textCapitalization: TextCapitalization.words,
                              textInputAction: TextInputAction.next,
                              autofillHints: const [AutofillHints.nickname],
                              prefixIcon: const Icon(Icons.person_outline),
                              maxLength: AuthConstants.maxDisplayNameLength,
                              validator: validateDisplayName,
                              onFieldSubmitted: (_) =>
                                  _emailFocus.requestFocus(),
                            ),
                            const SizedBox(height: AppSpace.md),
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
                              textInputAction: TextInputAction.next,
                              autofillHints: const [AutofillHints.newPassword],
                              obscureText: _obscurePassword,
                              autocorrect: false,
                              enableSuggestions: false,
                              prefixIcon: const Icon(Icons.lock_outline),
                              maxLength: AuthConstants.maxPasswordLength,
                              validator: validatePassword,
                              onFieldSubmitted: (_) =>
                                  _confirmationFocus.requestFocus(),
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
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                top: AppSpace.xs,
                                bottom: AppSpace.sm,
                              ),
                              child: Text(
                                'Usa da ${AuthConstants.minPasswordLength} a '
                                '${AuthConstants.maxPasswordLength} caratteri.',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ),
                            StickerTextField(
                              controller: _confirmationController,
                              focusNode: _confirmationFocus,
                              labelText: 'Conferma password',
                              textInputAction: TextInputAction.done,
                              autofillHints: const [AutofillHints.newPassword],
                              obscureText: _obscureConfirmation,
                              autocorrect: false,
                              enableSuggestions: false,
                              prefixIcon: const Icon(Icons.lock_outline),
                              validator: (value) =>
                                  validatePasswordConfirmation(
                                    value,
                                    _passwordController.text,
                                  ),
                              onFieldSubmitted: (_) => _submit(),
                              suffixIcon: IconButton(
                                tooltip: _obscureConfirmation
                                    ? 'Mostra conferma password'
                                    : 'Nascondi conferma password',
                                constraints: const BoxConstraints(
                                  minWidth: AppTapTarget.minimum,
                                  minHeight: AppTapTarget.minimum,
                                ),
                                onPressed: () => setState(
                                  () => _obscureConfirmation =
                                      !_obscureConfirmation,
                                ),
                                icon: Icon(
                                  _obscureConfirmation
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSpace.lg),
                            StickerButton(
                              label: 'CREA ACCOUNT',
                              isLoading: isLoading,
                              onPressed: isLoading ? null : _submit,
                            ),
                            const SizedBox(height: AppSpace.xs),
                            TextButton(
                              style: TextButton.styleFrom(
                                minimumSize: const Size.fromHeight(
                                  AppTapTarget.minimum,
                                ),
                              ),
                              onPressed: () => context.go(AppRoutes.login),
                              child: const Text('Hai già un account? Accedi'),
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
