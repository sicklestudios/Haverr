import 'package:cloud_firestore/cloud_firestore.dart';

class CommentModel {
  final bool showStatus;

  final String text;
  final String uid;
  final likes;
  final String commentId;
  final DateTime datePublished;

  const CommentModel({
    this.showStatus = true,
    required this.uid,
    required this.likes,
    required this.text,
    required this.datePublished,
    required this.commentId,
  });

  static CommentModel fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    return CommentModel(
        uid: snapshot["uid"],
        showStatus: snapshot['showStatus'],
        likes: snapshot["likes"],
        commentId: snapshot["commentId"],
        datePublished: snapshot["datePublished"],
        text: snapshot["text"]);
  }

  Map<String, dynamic> toJson() => {
        "uid": uid,
        'showStatus': showStatus,
        "likes": likes,
        "commentId": commentId,
        "datePublished": datePublished,
        'text': text,
      };
}
