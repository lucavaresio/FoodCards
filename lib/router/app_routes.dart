class AppRoutes {
  AppRoutes._();

  static const splash = '/splash';
  static const home = '/home';
  static const collection = '/collection';
  static const deck = '/deck';
  static const deckEditSegment = 'edit/:deckId';
  static const deckEditPattern = '$deck/$deckEditSegment';
  static const game = '/game';
  static const shop = '/shop';
  static const packOpening = '/shop/open';
  static const match = '/game/match';
  static const settings = '/settings';
  static const login = '/login';
  static const register = '/register';
  static const forgotPassword = '/forgot-password';
  static const gallery = '/dev/gallery';

  static const tabs = [home, collection, deck, game, shop];

  static String editDeck(String deckId) => '$deck/edit/$deckId';

  static String tabAt(int index) => tabs[index];
}
