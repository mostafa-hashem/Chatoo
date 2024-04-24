abstract class SuggestionStates{}

class SuggestionInit extends SuggestionStates {}

class SendSuggestionLoading extends SuggestionStates {}

class SendSuggestionSuccess extends SuggestionStates {}

class SendSuggestionError extends SuggestionStates {
  final String message;

  SendSuggestionError(this.message);
}