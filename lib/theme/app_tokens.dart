// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';

class AppSpace {
  AppSpace._();
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
  static const double xxxl = 64;
}

class AppRadius {
  AppRadius._();
  static const double xs = 6;
  static const double sm = 10;
  static const double md = 16;
  static const double lg = 24;
  static const double card = 14;
  static const double dialog = 20;
  static const double pill = 999;
}

class AppStroke {
  AppStroke._();
  static const double thin = 1.5;
  static const double base = 2.5;
  static const double modal = 3;
}

class AppBreakpoint {
  AppBreakpoint._();
  static const double tablet = 600;
}

class AppTapTarget {
  AppTapTarget._();
  static const double minimum = 48;
}

class AppLayout {
  AppLayout._();
  static const double authFormMaxWidth = 480;
  static const double collectionCardAspectRatio = 0.70;
  static const double collectionDetailImageWidthFactor = 0.55;
  static const int collectionPhoneColumns = 3;
  static const int collectionTabletColumns = 5;
  static const int packSummaryPhoneColumns = 3;
  static const int packSummaryTabletColumns = 5;
  static const int recipePhoneColumns = 2;
  static const int recipeTabletColumns = 3;
  static const double recipeTileHeight = 280;
  static const double recipeHeroHeight = 220;
}

class AppShadowOffset {
  AppShadowOffset._();
  static const double sm = 3;
  static const double base = 4;
  static const double raised = 5;
  static const double modal = 8;
}

List<BoxShadow> stickerShadow(Color outline, {double offset = 4}) {
  return [BoxShadow(color: outline, blurRadius: 0, offset: Offset(0, offset))];
}

class AppDuration {
  AppDuration._();
  static const Duration fast = Duration(milliseconds: 120);
  static const Duration base = Duration(milliseconds: 200);
  static const Duration splash = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 350);
  static const Duration celebration = Duration(milliseconds: 600);
  static const Duration snackbar = Duration(seconds: 3);
}

class AppThemeExtras extends ThemeExtension<AppThemeExtras> {
  const AppThemeExtras({required this.outline, required this.divider});

  final Color outline;
  final Color divider;

  @override
  AppThemeExtras copyWith({Color? outline, Color? divider}) {
    return AppThemeExtras(
      outline: outline ?? this.outline,
      divider: divider ?? this.divider,
    );
  }

  @override
  AppThemeExtras lerp(ThemeExtension<AppThemeExtras>? other, double t) {
    if (other is! AppThemeExtras) return this;
    return AppThemeExtras(
      outline: Color.lerp(outline, other.outline, t) ?? outline,
      divider: Color.lerp(divider, other.divider, t) ?? divider,
    );
  }
}
