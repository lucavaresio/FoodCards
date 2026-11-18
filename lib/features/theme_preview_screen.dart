// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import '../theme/app_tokens.dart';

class ThemePreviewScreen extends StatelessWidget {
  const ThemePreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final extras = Theme.of(context).extension<AppThemeExtras>()!;

    return Scaffold(
      appBar: AppBar(title: const Text('FoodCards — Theme Preview')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpace.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _SectionTitle('Scala tipografica'),
              _TypeRow('display', AppText.display),
              _TypeRow('h1', AppText.h1),
              _TypeRow('h2', AppText.h2),
              _TypeRow('h3', AppText.h3),
              _TypeRow('title', AppText.title),
              _TypeRow('bodyL', AppText.bodyL),
              _TypeRow('body', AppText.body),
              _TypeRow('label', AppText.label),
              _TypeRow('cardName', AppText.cardName),
              _TypeRow('stat', AppText.stat),
              _TypeRow('caption', AppText.caption),
              _TypeRow('button', AppText.button),
              const SizedBox(height: AppSpace.lg),
              const _SectionTitle('Marca'),
              _Swatches([
                ('tomato', AppColors.tomato),
                ('tomatoAction', AppColors.tomatoAction),
                ('tomatoDark', AppColors.tomatoDark),
                ('cheese', AppColors.cheese),
                ('crust', AppColors.crust),
                ('espresso', AppColors.espresso),
                ('cream', AppColors.cream),
                ('mare', AppColors.mare),
              ]),
              const SizedBox(height: AppSpace.lg),
              const _SectionTitle('Superfici'),
              _Swatches([
                ('paper', AppColors.paper),
                ('creamDeep', AppColors.creamDeep),
                ('creamLine', AppColors.creamLine),
                ('muted', AppColors.muted),
                ('dBg', AppColors.dBg),
                ('dSurface', AppColors.dSurface),
                ('dSurface2', AppColors.dSurface2),
                ('dLine', AppColors.dLine),
                ('dText2', AppColors.dText2),
              ]),
              const SizedBox(height: AppSpace.lg),
              const _SectionTitle('Semantica'),
              _Swatches([
                ('success', AppColors.success),
                ('warning', AppColors.warning),
                ('error', AppColors.error),
                ('info', AppColors.info),
              ]),
              const SizedBox(height: AppSpace.lg),
              const _SectionTitle('Rarità'),
              _Swatches([
                ('common', AppColors.common),
                ('uncommon', AppColors.uncommon),
                ('rare', AppColors.rare),
                ('epic', AppColors.epic),
                ('legendary', AppColors.legendary),
              ]),
              const SizedBox(height: AppSpace.lg),
              const _SectionTitle('Elementi'),
              _Swatches([
                ('terra', AppColors.terra),
                ('fuoco', AppColors.fuoco),
                ('aria', AppColors.aria),
                ('acqua', AppColors.acqua),
                ('dolce', AppColors.dolce),
                ('erba', AppColors.erba),
              ]),
              const SizedBox(height: AppSpace.lg),
              const _SectionTitle('Statistiche'),
              _Swatches([
                ('vita', AppColors.vita),
                ('forza', AppColors.forza),
                ('difesa', AppColors.difesa),
                ('velocita', AppColors.velocita),
              ]),
              const SizedBox(height: AppSpace.lg),
              const _SectionTitle('Componenti'),
              ElevatedButton(onPressed: () {}, child: const Text('Gioca ora')),
              const SizedBox(height: AppSpace.md),
              const TextField(
                decoration: InputDecoration(labelText: 'Nome carta'),
              ),
              const SizedBox(height: AppSpace.lg),
              Container(
                padding: const EdgeInsets.all(AppSpace.md),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(AppRadius.card),
                  border: Border.all(
                    color: extras.outline,
                    width: AppStroke.base,
                  ),
                  boxShadow: stickerShadow(
                    extras.outline,
                    offset: AppShadowOffset.raised,
                  ),
                ),
                child: Text(
                  'Pizza Stellare',
                  style: AppText.cardName.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
              const SizedBox(height: AppSpace.xxl),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpace.sm),
      child: Text(label, style: Theme.of(context).textTheme.headlineMedium),
    );
  }
}

class _TypeRow extends StatelessWidget {
  const _TypeRow(this.label, this.style);
  final String label;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpace.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelMedium),
          Text(
            'Poppins $label',
            style: style.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _Swatches extends StatelessWidget {
  const _Swatches(this.swatches);
  final List<(String, Color)> swatches;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpace.sm,
      runSpacing: AppSpace.sm,
      children: swatches.map((item) {
        return SizedBox(
          width: AppSpace.xxxl * 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: AppSpace.xxxl,
                decoration: BoxDecoration(
                  color: item.$2,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline,
                    width: AppStroke.thin,
                  ),
                ),
              ),
              const SizedBox(height: AppSpace.xs),
              Text(item.$1, style: Theme.of(context).textTheme.labelMedium),
            ],
          ),
        );
      }).toList(),
    );
  }
}
