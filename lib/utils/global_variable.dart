import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:haverr/screens/feed_screen.dart';
import 'package:haverr/screens/notification_screen.dart';
import 'package:haverr/screens/profile_screen.dart';
import 'package:haverr/screens/reel_screen.dart';
import 'package:haverr/screens/search_screen.dart';

const webScreenSize = 600;
final FirebaseFirestore globalFirebaseFirestore = FirebaseFirestore.instance;
final FirebaseAuth globalFirebaseAuth = FirebaseAuth.instance;
List<Widget> homeScreenItems = [
  const FeedScreen(),
  const SearchScreen(),
  const ReelsScreen(),
  const NotificationScreen(),
  ProfileScreen(
    uid: FirebaseAuth.instance.currentUser!.uid,
  ),
];

class MenuItem {
  final String text;
  final IconData icon;
  const MenuItem({
    required this.text,
    required this.icon,
  });
}
