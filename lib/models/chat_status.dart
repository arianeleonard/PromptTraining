/// **ChatStatus** - Tracks the current state of chat interactions
///
/// Used by `ChatProvider` and UI widgets to coordinate loading states,
/// disable inputs during processing, and show appropriate indicators.
///
/// ## States:
/// - `idle`: Ready for new messages
/// - `submitting`: Processing user input (brief state)
/// - `streaming`: Receiving AI response in real-time
/// - `error`: Failed interaction (temporary state)
///
/// ## Usage in Widgets:
/// ```dart
/// // Disable send button during processing:
/// final isProcessing = chatProvider.status != ChatStatus.idle;
///
/// // Show loading indicator:
/// if (chatProvider.status == ChatStatus.streaming) {
///   return LoadingIndicator();
/// }
///
/// // Show error state:
/// if (chatProvider.status == ChatStatus.error) {
///   return ErrorWidget();
/// }
/// ```
enum ChatStatus { idle, submitting, streaming, error }