import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../router/app_routes.dart';
import '../../shared/widgets/sticker_button.dart';
import '../../shared/widgets/sticker_cards.dart';
import '../../shared/widgets/sticker_text_field.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text.dart';
import '../../theme/app_tokens.dart';
import '../../data/repositories/auth_repository.dart';
import 'auth_controller.dart';
import 'auth_error_messages.dart';
import 'auth_validators.dart';
import 'widgets/auth_error_banner.dart';
import 'widgets/auth_header.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _emailFocus = FocusNode();
  bool _isSent = false;
  String? _serverError;

  @override
  void dispose() {
    _emailController.dispose();
    _emailFocus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (ref.read(authControllerProvider).isLoading) return;
    if (!_formKey.currentState!.validate()) {
      _emailFocus.requestFocus();
      return;
    }

    setState(() {
      _isSent = false;
      _serverError = null;
    });
    try {
      await ref
          .read(authControllerProvider.notifier)
          .sendPasswordReset(_emailController.text);
      if (!mounted) return;
      setState(() => _isSent = true);
    } catch (error) {
      if (!mounted) return;
      if (error is AuthFailure &&
          error.code == AuthFailureCode.wrongCredentials) {
        setState(() => _isSent = true);
        return;
      }
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
                    const AuthHeader(
                      title: 'Recupera la password',
                      subtitle: 'Ti invieremo le istruzioni per reimpostarla.',
                    ),
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
                            if (_isSent) ...[
                              _ResetConfirmation(),
                              const SizedBox(height: AppSpace.md),
                            ],
                            StickerTextField(
                              controller: _emailController,
                              focusNode: _emailFocus,
                              labelText: 'Email',
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.done,
                              autofillHints: const [AutofillHints.email],
                              autocorrect: false,
                              enableSuggestions: false,
                              prefixIcon: const Icon(Icons.email_outlined),
                              validator: validateEmail,
                              onFieldSubmitted: (_) => _submit(),
                            ),
                            const SizedBox(height: AppSpace.lg),
                            StickerButton(
                              label: 'INVIA LINK',
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
                              child: const Text('Torna ad Accedi'),
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

class _ResetConfirmation extends StatelessWidget {
  const _ResetConfirmation();

  @override
  Widget build(BuildContext context) => Semantics(
    liveRegion: true,
    label: passwordResetConfirmation,
    child: Container(
      padding: const EdgeInsets.all(AppSpace.sm),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.12),
        border: Border.all(color: AppColors.info, width: AppStroke.base),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: AppColors.info),
          const SizedBox(width: AppSpace.xs),
          Expanded(
            child: Text(
              passwordResetConfirmation,
              style: AppText.body.copyWith(color: AppColors.info),
            ),
          ),
        ],
      ),
    ),
  );
}
