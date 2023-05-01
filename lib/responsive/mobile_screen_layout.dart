
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:haverr/models/user.dart';
import 'package:haverr/providers/user_provider.dart';
import 'package:haverr/utils/colors.dart';
import 'package:haverr/utils/global_variable.dart';
import 'package:haverr/utils/utils.dart';

class MobileScreenLayout extends StatefulWidget {
  const MobileScreenLayout({Key? key}) : super(key: key);

  @override
  State<MobileScreenLayout> createState() => _MobileScreenLayoutState();
}

class _MobileScreenLayoutState extends State<MobileScreenLayout> {
  int _page = 0;
  late PageController pageController; // for tabs animation
  @override
  void initState() {
    super.initState();
    storeNotificationToken();
    pageController = PageController();
  }

  @override
  void dispose() {
    super.dispose();
    pageController.dispose();
  }

  void onPageChanged(int page) {
    setState(() {
      _page = page;
    });
  }

  void navigationTapped(int page) {
    //Animating Page
    pageController.jumpToPage(page);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.data != null) {
              if (snapshot.data!.data()!.isNotEmpty) {
                UserProvider()
                    .refreshUserStream(UserModel.fromSnap(snapshot.data!));
              }
            }
            return PageView(
              controller: pageController,
              onPageChanged: onPageChanged,
              children: homeScreenItems,
            );
          }),
      bottomNavigationBar: CupertinoTabBar(
        backgroundColor: mobileBackgroundColor,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: getIconSvg(
              _page == 0 ? "home_filled" : "home",
              color: _page == 0 ? primaryColor : secondaryColor,
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: getIconSvg(
              _page == 1 ? "search_filled" : "search",
              color: _page == 1 ? primaryColor : secondaryColor,
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: getIconSvg(
              _page == 2 ? "play_filled" : "play",
              color: _page == 2 ? primaryColor : secondaryColor,
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: getIconSvg(
              _page == 3 ? "notification_filled" : "notification",
              color: _page == 3 ? primaryColor : secondaryColor,
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: getIconSvg(
              _page == 4 ? "user_filled" : "user",
              color: _page == 4 ? primaryColor : secondaryColor,
            ),
            label: '',
          ),
          // BottomNavigationBarItem(
          //   icon: Icon(
          //     AkarIcons.person,
          //     color: (_page == 4) ? primaryColor : secondaryColor,
          //   ),
          //   label: '',
          //   backgroundColor: primaryColor,
          // ),
        ],
        onTap: navigationTapped,
        currentIndex: _page,
      ),
    );
  }
}
