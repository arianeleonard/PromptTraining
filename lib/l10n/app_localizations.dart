import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

/// Hand-written localizations class so the app does **not** depend on
/// generated files. This mirrors the previous API surface that the
/// widgets already use.
class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr'),
  ];

  bool get _isFr => locale.languageCode == 'fr';

  // --- App-wide strings ---
  String get appTitle => _isFr ? 'BetterPrompts' : 'BetterPrompts';
  String get newChat => _isFr ? 'Nouvelle discussion' : 'New Chat';
  String get openSidebar => _isFr ? 'Ouvrir la barre latérale' : 'Open sidebar';
  String get closeSidebar => _isFr ? 'Fermer la barre latérale' : 'Close sidebar';
  String get role => _isFr ? 'Rôle' : 'Role';
  String get language => _isFr ? 'Langue' : 'Language';
  String get english => _isFr ? 'Anglais' : 'English';
  String get french => _isFr ? 'Français' : 'French';

  // Roles
  String get roleDesigner => _isFr ? 'Designer' : 'Designer';
  String get roleDeveloper => _isFr ? 'Développeur' : 'Developer';
  String get roleMarketing => _isFr ? 'Marketing' : 'Marketing';
  String get roleProjectManager => _isFr ? 'Chef de projet' : 'Project Manager';
  String get roleProductOwner => _isFr ? 'Product Owner' : 'Product Owner';
  String get roleFinance => _isFr ? 'Finance' : 'Finance';
  String get roleStrategist => _isFr ? 'Stratège' : 'Strategist';

  // Theme toggles
  String get switchToLight => _isFr ? 'Passer au thème clair' : 'Switch to light mode';
  String get switchToDark => _isFr ? 'Passer au thème sombre' : 'Switch to dark mode';
  String get switchToSystem =>
      _isFr ? 'Utiliser le thème du système' : 'Use system theme';

  // Message / assistant labels
  String get assistantLabel => _isFr ? 'Assistant' : 'Assistant';
  String get thinking => _isFr ? 'Réflexion en cours…' : 'Thinking…';
  String get generating => _isFr ? 'Génération en cours…' : 'Generating…';
  String get promptQuality =>
      _isFr ? 'Qualité du prompt' : 'Prompt quality';

  // Response actions
  String get regenerate => _isFr ? 'Régénérer' : 'Regenerate';
  String get goodResponse => _isFr ? 'Bonne réponse' : 'Good response';
  String get poorResponse => _isFr ? 'Mauvaise réponse' : 'Poor response';
  String get dislikeDialogTitle =>
      _isFr ? 'Pourquoi cette réponse ne vous a-t-elle pas plu ?' : 'Why didn’t you like this response?';
  String get feedbackTooVague =>
      _isFr ? 'Trop vague ou générique' : 'Too vague or generic';
  String get feedbackIncorrect =>
      _isFr ? 'Incorrect ou trompeur' : 'Incorrect or misleading';
  String get feedbackOther => _isFr ? 'Autre' : 'Other';
  String get feedbackNotesLabel =>
      _isFr ? 'Notes supplémentaires' : 'Additional notes';
  String get feedbackNotesHint => _isFr
      ? 'Partagez des détails pour nous aider à nous améliorer.'
      : 'Share details to help us improve.';
  String get cancel => _isFr ? 'Annuler' : 'Cancel';
  String get submit => _isFr ? 'Envoyer' : 'Submit';
  String get editPrompt =>
      _isFr ? 'Modifier le prompt' : 'Edit prompt';
  String get copied =>
      _isFr ? 'Copié dans le presse-papiers' : 'Copied to clipboard';
  String get copy => _isFr ? 'Copier' : 'Copy';
  String get share => _isFr ? 'Partager' : 'Share';

  // Prompt tiles / history / favorites
  String get untitledPrompt =>
      _isFr ? 'Prompt sans titre' : 'Untitled prompt';
  String get removeFromFavorites =>
      _isFr ? 'Retirer des favoris' : 'Remove from favorites';
  String get addToFavorites =>
      _isFr ? 'Ajouter aux favoris' : 'Add to favorites';
  String get useAsNewPrompt =>
      _isFr ? 'Utiliser comme nouveau prompt' : 'Use as new prompt';

  // Input
  String get inputPlaceholder => _isFr
      ? 'Posez une question, décrivez une tâche ou collez un prompt…'
      : 'Ask a question, describe a task, or paste a prompt…';
  String get sendMessage => _isFr ? 'Envoyer le message' : 'Send message';
  String get sending => _isFr ? 'Envoi…' : 'Sending…';
  String get stopGeneration =>
      _isFr ? 'Arrêter la génération' : 'Stop generation';
  String get retry => _isFr ? 'Réessayer' : 'Retry';

  // Context / attachments
  String get contextOptional =>
      _isFr ? 'Contexte (facultatif)' : 'Context (optional)';
  String get hideContext =>
      _isFr ? 'Masquer le contexte' : 'Hide context';
  String get contextPlaceholder => _isFr
      ? 'Ajoutez des notes de contexte, des contraintes ou des exemples…'
      : 'Add context notes, constraints, or examples…';
  String get addAttachment =>
      _isFr ? 'Ajouter une pièce jointe' : 'Add attachment';
  String get hideContextNotes =>
      _isFr ? 'Masquer les notes de contexte' : 'Hide context notes';
  String get addContextNotes =>
      _isFr ? 'Ajouter des notes de contexte' : 'Add context notes';

  // Sidebar
  String get chats => _isFr ? 'Discussions' : 'Chats';
  String get history => _isFr ? 'Historique' : 'History';
  String get favorites => _isFr ? 'Favoris' : 'Favorites';
  String get noConversationsYet => _isFr
      ? 'Aucune discussion pour le moment. Créez-en une nouvelle pour commencer.'
      : 'No conversations yet. Start a new one to begin.';
  String get justNow => _isFr ? 'À l’instant' : 'Just now';
  String minutesAgoShort(int minutes) =>
      _isFr ? 'Il y a ${minutes} min' : '${minutes}m ago';
  String hoursAgoShort(int hours) =>
      _isFr ? 'Il y a ${hours} h' : '${hours}h ago';
  String daysAgoShort(int days) =>
      _isFr ? 'Il y a ${days} j' : '${days}d ago';
  String weeksAgoShort(int weeks) =>
      _isFr ? 'Il y a ${weeks} sem' : '${weeks}w ago';

  // Code block
  String get noHistoryYet =>
      _isFr ? 'Aucun historique encore.' : 'No history yet.';
  String get noFavoritesYet =>
      _isFr ? 'Aucun favori encore.' : 'No favorites yet.';

  String get noMessagesStart => _isFr
      ? 'Aucun message pour le moment. Écrivez quelque chose pour commencer la conversation.'
      : 'No messages yet. Start typing to begin the conversation.';

  String get deleteConversation =>
      _isFr ? 'Supprimer la conversation' : 'Delete conversation';

  // Prompt details
  String get promptReview =>
      _isFr ? 'Analyse du prompt' : 'Prompt review';
  String get prompt => _isFr ? 'Prompt' : 'Prompt';
  String get aiFeedback =>
      _isFr ? 'Retour de l’IA' : 'AI feedback';

  // Strings used directly in ChatProvider and other non-widget classes
  String get errorEvaluatingPrompt =>
      _isFr ? 'Erreur lors de l’évaluation de la requête' : 'Error while evaluating prompt';
  String get heuristicFallback =>
      _isFr ? 'Résultat heuristique de secours' : 'Heuristic fallback result';
  String get responseStoppedByUser =>
      _isFr ? 'Réponse interrompue par l’utilisateur' : 'Response stopped by user';
  String get errorBold => _isFr ? 'Erreur' : 'Error';
  String get checkApiKeyAndRetry => _isFr
      ? 'Vérifiez votre clé API et réessayez.'
      : 'Check your API key and try again.';
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      AppLocalizations.supportedLocales.any((l) => l.languageCode == locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) => false;
}

class AppLocalizationsConfig {
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];

  static const List<Locale> supportedLocales = AppLocalizations.supportedLocales;
}

