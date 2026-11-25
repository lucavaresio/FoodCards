import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/meal.dart';
import '../../data/remote/meal_db_client.dart';
import '../../shared/widgets/sticker_button.dart';
import '../../shared/widgets/sticker_cards.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_tokens.dart';
import 'recipe_providers.dart';

class RecipeScreen extends ConsumerStatefulWidget {
  const RecipeScreen({super.key});

  @override
  ConsumerState<RecipeScreen> createState() => _RecipeScreenState();
}

class _RecipeScreenState extends ConsumerState<RecipeScreen> {
  String? _selectedCategory;
  String? _selectedMealId;
  bool _showRandomMeal = false;

  @override
  Widget build(BuildContext context) {
    final hasSelection =
        _selectedCategory != null || _selectedMealId != null || _showRandomMeal;
    final title = _selectedMealId != null || _showRandomMeal
        ? 'Ricetta'
        : _selectedCategory ?? 'Ricettario';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: hasSelection
            ? IconButton(
                tooltip: 'Indietro',
                icon: const Icon(Icons.arrow_back),
                onPressed: _goBack,
              )
            : null,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpace.md),
          child: _content(),
        ),
      ),
    );
  }

  Widget _content() {
    final mealId = _selectedMealId;
    if (mealId != null) {
      return ref
          .watch(mealDetailsProvider(mealId))
          .when(
            data: (meal) => meal == null
                ? _EmptyState(
                    title: 'Ricetta non trovata',
                    message: 'La ricetta selezionata non è più disponibile.',
                  )
                : _mealDetail(meal),
            loading: _loading,
            error: (error, stackTrace) => _error(
              error,
              onRetry: () => ref.invalidate(mealDetailsProvider(mealId)),
            ),
          );
    }

    if (_showRandomMeal) {
      return ref
          .watch(randomMealProvider)
          .when(
            data: (meal) => meal == null
                ? _EmptyState(
                    title: 'Nessuna ricetta trovata',
                    message: 'Riprova tra poco.',
                    action: StickerButton(
                      label: 'Riprova',
                      icon: Icons.refresh,
                      onPressed: () => ref.invalidate(randomMealProvider),
                    ),
                  )
                : _mealDetail(meal, isRandom: true),
            loading: _loading,
            error: (error, stackTrace) => _error(
              error,
              onRetry: () => ref.invalidate(randomMealProvider),
            ),
          );
    }

    final category = _selectedCategory;
    if (category != null) {
      return ref
          .watch(categoryMealsProvider(category))
          .when(
            data: (meals) => meals.isEmpty
                ? _EmptyState(
                    title: 'Nessuna ricetta in questa categoria',
                    message: 'Scegli un’altra categoria.',
                  )
                : _mealGrid(meals),
            loading: _loading,
            error: (error, stackTrace) => _error(
              error,
              onRetry: () => ref.invalidate(categoryMealsProvider(category)),
            ),
          );
    }

    return ref
        .watch(mealCategoriesProvider)
        .when(
          data: _categoryList,
          loading: _loading,
          error: (error, stackTrace) => _error(
            error,
            onRetry: () => ref.invalidate(mealCategoriesProvider),
          ),
        );
  }

  Widget _categoryList(List<MealCategory> categories) {
    if (categories.isEmpty) {
      return _EmptyState(
        title: 'Categorie non disponibili',
        message: 'Riprova a caricare il ricettario.',
        action: StickerButton(
          label: 'Riprova',
          icon: Icons.refresh,
          onPressed: () => ref.invalidate(mealCategoriesProvider),
        ),
      );
    }

    return Column(
      children: [
        StickerCard(
          child: Text(
            'Scopri ricette internazionali cercando per categoria. '
            'Fonte: TheMealDB.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
        const SizedBox(height: AppSpace.sm),
        StickerButton(
          label: 'Scegli una ricetta casuale',
          icon: Icons.shuffle,
          onPressed: () {
            setState(() {
              _showRandomMeal = true;
              _selectedCategory = null;
            });
            ref.invalidate(randomMealProvider);
          },
        ),
        const SizedBox(height: AppSpace.md),
        Expanded(
          child: GridView.builder(
            itemCount: categories.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount:
                  MediaQuery.sizeOf(context).width >= AppBreakpoint.tablet
                  ? AppLayout.recipeTabletColumns
                  : AppLayout.recipePhoneColumns,
              crossAxisSpacing: AppSpace.sm,
              mainAxisSpacing: AppSpace.sm,
              mainAxisExtent: AppLayout.recipeTileHeight,
            ),
            itemBuilder: (context, index) {
              final category = categories[index];
              return _BrowseTile(
                label: category.name,
                imageUrl: category.imageUrl,
                onTap: () => setState(() => _selectedCategory = category.name),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _mealGrid(List<MealSummary> meals) => GridView.builder(
    itemCount: meals.length,
    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: MediaQuery.sizeOf(context).width >= AppBreakpoint.tablet
          ? AppLayout.recipeTabletColumns
          : AppLayout.recipePhoneColumns,
      crossAxisSpacing: AppSpace.sm,
      mainAxisSpacing: AppSpace.sm,
      mainAxisExtent: AppLayout.recipeTileHeight,
    ),
    itemBuilder: (context, index) {
      final meal = meals[index];
      return _BrowseTile(
        label: meal.name,
        imageUrl: meal.imageUrl,
        onTap: () => setState(() => _selectedMealId = meal.id),
      );
    },
  );

  Widget _mealDetail(MealDetail meal, {bool isRandom = false}) {
    return ListView(
      children: [
        if (meal.imageUrl.isNotEmpty)
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.card),
            child: _RemoteImage(
              url: meal.imageUrl,
              height: AppLayout.recipeHeroHeight,
              semanticLabel: meal.name,
            ),
          ),
        const SizedBox(height: AppSpace.md),
        Text(meal.name, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: AppSpace.xs),
        Text(
          [
            if (meal.category.isNotEmpty) meal.category,
            if (meal.area.isNotEmpty) meal.area,
          ].join(' · '),
        ),
        const SizedBox(height: AppSpace.lg),
        StickerCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ingredienti',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppSpace.xs),
              if (meal.ingredients.isEmpty)
                const Text('Ingredienti non disponibili.')
              else
                for (final ingredient in meal.ingredients)
                  Semantics(
                    label: ingredient.label,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: AppSpace.xxs),
                      child: Text('• ${ingredient.label}'),
                    ),
                  ),
            ],
          ),
        ),
        const SizedBox(height: AppSpace.md),
        StickerCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Preparazione',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppSpace.xs),
              Text(
                meal.instructions.isEmpty
                    ? 'Istruzioni non disponibili.'
                    : meal.instructions,
              ),
            ],
          ),
        ),
        if (isRandom) ...[
          const SizedBox(height: AppSpace.md),
          StickerButton(
            label: 'Un’altra ricetta casuale',
            icon: Icons.shuffle,
            onPressed: () => ref.invalidate(randomMealProvider),
          ),
        ],
      ],
    );
  }

  Widget _loading() => Center(
    child: Semantics(
      label: 'Caricamento delle ricette',
      child: CircularProgressIndicator(),
    ),
  );

  Widget _error(Object error, {required VoidCallback onRetry}) {
    final message = error is MealDbException
        ? error.message
        : 'Risposta non valida. Riprova.';
    return _EmptyState(
      icon: Icons.error_outline,
      title: 'Ricette non disponibili',
      message: message,
      isError: true,
      action: StickerButton(
        label: 'Riprova',
        icon: Icons.refresh,
        onPressed: onRetry,
      ),
    );
  }

  void _goBack() {
    setState(() {
      if (_selectedMealId != null) {
        _selectedMealId = null;
      } else if (_showRandomMeal) {
        _showRandomMeal = false;
      } else {
        _selectedCategory = null;
      }
    });
  }
}

class _BrowseTile extends StatelessWidget {
  const _BrowseTile({
    required this.label,
    required this.imageUrl,
    required this.onTap,
  });

  final String label;
  final String imageUrl;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: label,
    onTap: onTap,
    child: GestureDetector(
      onTap: onTap,
      child: StickerCard(
        child: Column(
          children: [
            Expanded(
              child: imageUrl.isEmpty
                  ? const Center(child: Icon(Icons.restaurant_menu))
                  : _RemoteImage(url: imageUrl, semanticLabel: label),
            ),
            const SizedBox(height: AppSpace.xs),
            Text(
              label,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ],
        ),
      ),
    ),
  );
}

class _RemoteImage extends StatelessWidget {
  const _RemoteImage({
    required this.url,
    required this.semanticLabel,
    this.height,
  });

  final String url;
  final String semanticLabel;
  final double? height;

  @override
  Widget build(BuildContext context) => Semantics(
    label: semanticLabel,
    image: true,
    child: Image.network(
      url,
      height: height,
      width: double.infinity,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return const Center(child: CircularProgressIndicator());
      },
      errorBuilder: (context, error, stackTrace) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.broken_image_outlined, color: AppColors.error),
            const SizedBox(height: AppSpace.xxs),
            Text(
              'Immagine non disponibile',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    ),
  );
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.title,
    required this.message,
    this.icon = Icons.restaurant_outlined,
    this.action,
    this.isError = false,
  });

  final String title;
  final String message;
  final IconData icon;
  final Widget? action;
  final bool isError;

  @override
  Widget build(BuildContext context) => Center(
    child: StickerCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: AppSpace.xxl,
            color: isError ? AppColors.error : null,
          ),
          const SizedBox(height: AppSpace.sm),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpace.xs),
          Text(message, textAlign: TextAlign.center),
          if (action != null) ...[const SizedBox(height: AppSpace.lg), action!],
        ],
      ),
    ),
  );
}
