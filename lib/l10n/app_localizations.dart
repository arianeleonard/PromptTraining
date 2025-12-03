import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class AppLocalizations {
  final Locale locale;
  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];

  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr'),
  ];

  bool get _isFr => locale.languageCode.toLowerCase().startsWith('fr');

  String get appTitle => _isFr ? 'Chat IA' : 'AI Chat';
  String get inputPlaceholder => _isFr ? 'Que voulez-vous savoir ?' : 'What would you like to know?';
  String get sendMessage => _isFr ? 'Envoyer le message' : 'Send message';
  String get sending => _isFr ? 'Envoi en cours…' : 'Sending...';
  String get stopGeneration => _isFr ? 'Arrêter la génération' : 'Stop generation';
  String get retry => _isFr ? 'Réessayer' : 'Retry';
  String get contextOptional => _isFr ? 'Contexte (optionnel)' : 'Context (optional)';
  String get hideContext => _isFr ? 'Masquer le contexte' : 'Hide context';
  String get contextPlaceholder => _isFr
      ? 'Ajoutez du contexte ou des notes pour guider le retour…'
      : 'Add context or notes to guide the feedback…';
  String get addAttachment => _isFr ? 'Ajouter une pièce jointe' : 'Add attachment';
  String get hideContextNotes => _isFr ? 'Masquer contexte/notes' : 'Hide context/notes';
  String get addContextNotes => _isFr ? 'Ajouter contexte/notes' : 'Add context/notes';
  String get openSidebar => _isFr ? 'Ouvrir la barre latérale' : 'Open sidebar';
  String get closeSidebar => _isFr ? 'Fermer la barre latérale' : 'Close sidebar';
  String get language => _isFr ? 'Langue' : 'Language';
  String get english => _isFr ? 'Anglais' : 'English';
  String get french => _isFr ? 'Français' : 'French';
  String get role => _isFr ? 'Rôle' : 'Role';
  String get roleStrategist => _isFr ? 'Stratège' : 'Strategist';
  String get roleDesigner => _isFr ? 'Designer' : 'Designer';
  String get roleDeveloper => _isFr ? 'Développeur' : 'Developer';
  String get roleMarketing => _isFr ? 'Marketing' : 'Marketing';
  String get roleProjectManager => _isFr ? 'Chef de projet' : 'Project Manager';
  String get roleProductOwner => _isFr ? 'Product Owner' : 'Product Owner';
  String get roleFinance => _isFr ? 'Finance' : 'Finance';
  String get assistantLabel => _isFr ? 'Assistant' : 'Assistant';
  String get thinking => _isFr ? 'Réflexion…' : 'Thinking...';
  String get generating => _isFr ? 'Génération…' : 'Generating...';
  String get promptQuality => _isFr ? 'Qualité du prompt' : 'Prompt Quality';

  String messages(int count) {
    if (_isFr) {
      // Simple pluralization
      return '$count ${count == 1 ? 'message' : 'messages'}';
    }
    return '$count ${count == 1 ? 'message' : 'messages'}';
  }

  String get switchToLight => _isFr ? 'Passer au thème clair' : 'Switch to light theme';
  String get switchToDark => _isFr ? 'Passer au thème sombre' : 'Switch to dark theme';
  String get switchToSystem => _isFr ? 'Passer au thème système' : 'Switch to system theme';

  // History
  String get chats => _isFr ? 'Discussions' : 'Chats';
  String get history => _isFr ? 'Historique' : 'History';
  String get noHistoryYet => _isFr ? 'Aucun historique pour le moment' : 'No history yet';
  String get promptReview => _isFr ? 'Revue du prompt' : 'Prompt Review';
  String get prompt => _isFr ? 'Prompt' : 'Prompt';
  String get aiFeedback => _isFr ? 'Retour de l’IA' : 'AI Feedback';
  String get useAsNewPrompt => _isFr ? 'Réutiliser comme nouveau prompt' : 'Use as new prompt';
  String get untitledPrompt => _isFr ? 'Prompt sans titre' : 'Untitled prompt';

  // Favorites
  String get favorites => _isFr ? 'Favoris' : 'Favorites';
  String get addToFavorites => _isFr ? 'Ajouter aux favoris' : 'Add to favorites';
  String get removeFromFavorites => _isFr ? 'Retirer des favoris' : 'Remove from favorites';
  String get startFromFavorite => _isFr ? 'Démarrer depuis un favori' : 'Start from favorite';
  String get noFavoritesYet => _isFr ? 'Aucun favori pour le moment' : 'No favorites yet';
  String get selectFavorite => _isFr ? 'Sélectionner un favori' : 'Select a favorite';

  // Sidebar & conversations
  String get newChat => _isFr ? 'Nouvelle discussion' : 'New Chat';
  String get noConversationsYet => _isFr ? 'Aucune discussion pour le moment' : 'No conversations yet';
  String get deleteConversation => _isFr ? 'Supprimer la discussion' : 'Delete conversation';

  // Conversation/empty state
  String get noMessagesStart => _isFr
      ? 'Aucun message pour le moment. Commencez une conversation !'
      : 'No messages yet. Start a conversation!';

  // Response actions
  String get regenerate => _isFr ? 'Régénérer' : 'Regenerate';
  String get goodResponse => _isFr ? 'Bonne réponse' : 'Good response';
  String get poorResponse => _isFr ? 'Mauvaise réponse' : 'Poor response';
  String get editPrompt => _isFr ? 'Modifier le prompt' : 'Edit prompt';
  String get copied => _isFr ? 'Copié !' : 'Copied!';
  String get copy => _isFr ? 'Copier' : 'Copy';
  String get share => _isFr ? 'Partager' : 'Share';

  // Thumbs-down dialog
  String get dislikeDialogTitle => _isFr
      ? 'Pourquoi avez‑vous désapprécié cette réponse ?'
      : 'Why did you dislike this response?';
  String get feedbackTooVague => _isFr ? 'Trop vague' : 'Too vague';
  String get feedbackIncorrect => _isFr ? 'Informations incorrectes' : 'Incorrect information';
  String get feedbackOther => _isFr ? 'Autre' : 'Other';
  String get feedbackNotesLabel => _isFr ? 'Notes supplémentaires (optionnel)' : 'Additional notes (optional)';
  String get feedbackNotesHint => _isFr
      ? 'Partagez des détails pour améliorer les réponses futures'
      : 'Share details to help improve future responses';
  String get cancel => _isFr ? 'Annuler' : 'Cancel';
  String get submit => _isFr ? 'Envoyer' : 'Submit';

  // Relative time (short)
  String get justNow => _isFr ? 'À l’instant' : 'Just now';
  String minutesAgoShort(int m) => _isFr ? 'il y a ${m} min' : '${m}m ago';
  String hoursAgoShort(int h) => _isFr ? 'il y a ${h} h' : '${h}h ago';
  String daysAgoShort(int d) => _isFr ? 'il y a ${d} j' : '${d}d ago';
  String weeksAgoShort(int w) => _isFr ? 'il y a ${w} sem' : '${w}w ago';

  // Provider / errors
  String get errorEvaluatingPrompt => _isFr
      ? 'Erreur lors de l’évaluation du prompt. Veuillez réessayer.'
      : 'Error evaluating prompt. Please try again.';
  String get errorBold => _isFr ? '**Erreur**' : '**Error**';
  String get checkApiKeyAndRetry => _isFr
      ? 'Veuillez vérifier la configuration de votre clé API et réessayer.'
      : 'Please check your API key configuration and try again.';
  String get responseStoppedByUser => _isFr
      ? '*[Réponse arrêtée par l’utilisateur]*'
      : '*[Response stopped by user]*';
  String get heuristicFallback => _isFr
      ? 'L’évaluation heuristique automatique n’a pas pu joindre le modèle. Pensez à ajouter du contexte, des contraintes et un format de sortie attendu.'
      : 'Automatic heuristic evaluation could not reach the model. Consider adding context, constraints, and expected output format.';
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'fr'].contains(locale.languageCode.toLowerCase());
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
