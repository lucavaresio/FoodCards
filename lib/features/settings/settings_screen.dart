import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../constants/auth_constants.dart';
import '../../data/session_providers.dart';
import '../../features/auth/auth_controller.dart';
import '../../features/auth/auth_error_messages.dart';
import '../../router/app_routes.dart';
import '../../shared/widgets/sticker_button.dart';
import '../../shared/widgets/sticker_cards.dart';
import '../../shared/widgets/sticker_text_field.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_tokens.dart';
import '../../theme/theme_mode_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? _loadedUid;
  String? _error;
  bool _isSavingProfile = false;
  bool _isSavingTheme = false;
  bool _isSigningOut = false;
  bool _isDeletingAccount = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(sessionProvider).value;
    if (user != null && _loadedUid != user.uid) {
      _loadedUid = user.uid;
      _nameController.text = user.displayName;
    }

    final themeMode = ref.watch(themeModeProvider);
    final canPop = GoRouter.of(context).canPop();
    return PopScope<Object?>(
      canPop: canPop,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) context.go(AppRoutes.home);
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Impostazioni')),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppLayout.authFormMaxWidth,
              ),
              child: ListView(
                padding: const EdgeInsets.all(AppSpace.md),
                children: [
                  Text(
                    'Profilo',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: AppSpace.sm),
                  StickerCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (user == null)
                          const Text('Nessuna sessione attiva')
                        else ...[
                          Text(
                            user.email,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          const SizedBox(height: AppSpace.md),
                          Form(
                            key: _formKey,
                            child: StickerTextField(
                              labelText: 'Nome giocatore',
                              controller: _nameController,
                              textCapitalization: TextCapitalization.words,
                              maxLength: AuthConstants.maxDisplayNameLength,
                              validator: (value) {
                                final name = value?.trim() ?? '';
                                if (name.length <
                                    AuthConstants.minDisplayNameLength) {
                                  return 'Inserisci almeno ${AuthConstants.minDisplayNameLength} caratteri';
                                }
                                if (name.length >
                                    AuthConstants.maxDisplayNameLength) {
                                  return 'Massimo ${AuthConstants.maxDisplayNameLength} caratteri';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(height: AppSpace.md),
                          StickerButton(
                            label: 'Salva profilo',
                            icon: Icons.save_outlined,
                            isLoading: _isSavingProfile,
                            onPressed: _isSavingProfile
                                ? null
                                : _saveDisplayName,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpace.lg),
                  Text(
                    'Aspetto',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: AppSpace.sm),
                  StickerCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Tema',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: AppSpace.sm),
                        Semantics(
                          label: 'Seleziona il tema dell’app',
                          child: SegmentedButton<ThemeMode>(
                            segments: const [
                              ButtonSegment(
                                value: ThemeMode.system,
                                label: Text('Sistema'),
                                icon: Icon(Icons.settings_brightness_outlined),
                              ),
                              ButtonSegment(
                                value: ThemeMode.light,
                                label: Text('Chiaro'),
                                icon: Icon(Icons.light_mode_outlined),
                              ),
                              ButtonSegment(
                                value: ThemeMode.dark,
                                label: Text('Scuro'),
                                icon: Icon(Icons.dark_mode_outlined),
                              ),
                            ],
                            selected: {themeMode},
                            onSelectionChanged: _isSavingTheme
                                ? null
                                : (selection) => _saveTheme(selection.single),
                          ),
                        ),
                        if (_isSavingTheme) ...[
                          const SizedBox(height: AppSpace.sm),
                          const Center(child: CircularProgressIndicator()),
                        ],
                      ],
                    ),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: AppSpace.md),
                    _SettingsError(message: _error!),
                  ],
                  if (user != null) ...[
                    const SizedBox(height: AppSpace.lg),
                    TextButton.icon(
                      onPressed: _isSigningOut ? null : _signOut,
                      icon: const Icon(Icons.logout),
                      label: Text(
                        _isSigningOut ? 'Uscita in corso' : 'Esci dal profilo',
                      ),
                    ),
                    const SizedBox(height: AppSpace.lg),
                    Text(
                      'Privacy e dati',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: AppSpace.sm),
                    StickerCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'Account, email e nome profilo sono gestiti dal '
                            'servizio di autenticazione configurato. '
                            'Collezione, mazzi e statistiche sono salvati '
                            'localmente sul dispositivo. Le ricette sono '
                            'richieste a TheMealDB.',
                          ),
                          const SizedBox(height: AppSpace.md),
                          TextButton.icon(
                            onPressed: _isDeletingAccount
                                ? null
                                : _deleteAccount,
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.error,
                            ),
                            icon: const Icon(Icons.delete_forever_outlined),
                            label: Text(
                              _isDeletingAccount
                                  ? 'Eliminazione in corso'
                                  : 'Elimina account e dati locali',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _saveDisplayName() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isSavingProfile = true;
      _error = null;
    });
    try {
      await ref
          .read(authControllerProvider.notifier)
          .updateDisplayName(_nameController.text.trim());
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = authErrorMessage(error));
    } finally {
      if (mounted) setState(() => _isSavingProfile = false);
    }
  }

  Future<void> _saveTheme(ThemeMode mode) async {
    setState(() {
      _isSavingTheme = true;
      _error = null;
    });
    try {
      await ref.read(themeModeProvider.notifier).setMode(mode);
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = 'Tema non salvato: $error');
    } finally {
      if (mounted) setState(() => _isSavingTheme = false);
    }
  }

  Future<void> _signOut() async {
    setState(() {
      _isSigningOut = true;
      _error = null;
    });
    try {
      await ref.read(authControllerProvider.notifier).signOut();
      if (!mounted) return;
      context.go(AppRoutes.login);
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = authErrorMessage(error));
    } finally {
      if (mounted) setState(() => _isSigningOut = false);
    }
  }

  Future<void> _deleteAccount() async {
    final password = await showDialog<String>(
      context: context,
      builder: (context) => const _DeleteAccountDialog(),
    );
    if (!mounted || password == null) return;

    setState(() {
      _isDeletingAccount = true;
      _error = null;
    });
    try {
      await ref.read(authControllerProvider.notifier).deleteAccount(password);
      if (!mounted) return;
      context.go(AppRoutes.login);
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = authErrorMessage(error));
    } finally {
      if (mounted) setState(() => _isDeletingAccount = false);
    }
  }
}

class _DeleteAccountDialog extends StatefulWidget {
  const _DeleteAccountDialog();

  @override
  State<_DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends State<_DeleteAccountDialog> {
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    icon: const Icon(Icons.delete_forever_outlined, color: AppColors.error),
    title: const Text('Eliminare l’account?'),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'L’operazione è irreversibile. Conferma la password per eliminare '
          'l’account e i dati locali associati.',
        ),
        const SizedBox(height: AppSpace.md),
        TextField(
          controller: _passwordController,
          obscureText: true,
          autofillHints: const [AutofillHints.password],
          textInputAction: TextInputAction.done,
          decoration: const InputDecoration(labelText: 'Password'),
          onChanged: (_) => setState(() {}),
          onSubmitted: (value) {
            if (value.isNotEmpty) Navigator.of(context).pop(value);
          },
        ),
      ],
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: const Text('Annulla'),
      ),
      TextButton.icon(
        onPressed: _passwordController.text.isEmpty
            ? null
            : () => Navigator.of(context).pop(_passwordController.text),
        style: TextButton.styleFrom(foregroundColor: AppColors.error),
        icon: const Icon(Icons.delete_forever_outlined),
        label: const Text('Elimina account'),
      ),
    ],
  );
}

class _SettingsError extends StatelessWidget {
  const _SettingsError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) => Semantics(
    liveRegion: true,
    child: Row(
      children: [
        const Icon(Icons.error_outline, color: AppColors.error),
        const SizedBox(width: AppSpace.xs),
        Expanded(child: Text(message)),
      ],
    ),
  );
}
