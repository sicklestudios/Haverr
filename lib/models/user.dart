import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String phoneNumber;
  final String email;
  final String uid;
  final String photoUrl;
  final String username;
  final String bio;
  final String dob;
  final bool isVerified;
  final bool showStatus;
  final String fullName;
  final String passion;
  final List followers;
  final List following;
  final List saved;
  final String token;
  final List blockList;
  final List likings;
  final bool isOnline;

  const UserModel({
    required this.phoneNumber,
    required this.isOnline,
    required this.username,
    required this.uid,
    required this.photoUrl,
    required this.email,
    required this.bio,
    required this.isVerified,
    required this.showStatus,
    required this.followers,
    required this.following,
    required this.saved,
    required this.dob,
    required this.fullName,
    required this.passion,
    required this.token,
    required this.blockList,
    required this.likings,
  });

  static UserModel fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    return UserModel(
      phoneNumber: snap['phoneNumber'],
      isOnline: snap['isOnline'],
      username: snapshot["username"],
      uid: snapshot["uid"],
      email: snapshot["email"],
      photoUrl: snapshot["photoUrl"],
      bio: snapshot["bio"],
      isVerified: snapshot["isVerified"],
      showStatus: snapshot["showStatus"],
      followers: snapshot["followers"],
      following: snapshot["following"],
      dob: snapshot["dob"],
      fullName: snapshot["fullName"],
      passion: snapshot["passion"],
      saved: snapshot["saved"],
      blockList: snap['blockList'],
      likings: snap['likings'],
      token: snapshot["token"],
    );
  }

  Map<String, dynamic> toJson() => {
        'phoneNumber': phoneNumber,
        'isOnline': isOnline,
        "username": username,
        "uid": uid,
        "email": email,
        "photoUrl": photoUrl,
        "bio": bio,
        "isVerified": isVerified,
        "showStatus": showStatus,
        "followers": followers,
        "following": following,
        "dob": dob,
        "fullName": fullName,
        "passion": passion,
        "saved": saved,
        'blockList': blockList,
        'likings': likings,
        "token": token,
      };
}
