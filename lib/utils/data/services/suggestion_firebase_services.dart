import 'package:chat_app/utils/constants.dart';
import 'package:chat_app/utils/data/models/suggestion.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SuggestionFirebaseServices {
  final _suggestionsCollection =
      FirebaseFirestore.instance.collection(FirebasePath.suggestions);

  Future<void> sendSuggestion(Suggestion suggestion) async {
    final docReference = await _suggestionsCollection.add(suggestion.toJson());
    final suggestionId = docReference.id;
    await _suggestionsCollection.doc(suggestionId).update({
      "suggestionId": suggestionId,
    });
  }
}
