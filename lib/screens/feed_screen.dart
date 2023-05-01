import 'package:akar_icons_flutter/akar_icons_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:haverr/models/user.dart';
import 'package:haverr/providers/user_provider.dart';
import 'package:haverr/screens/chat/chat_list_screen.dart';
import 'package:haverr/utils/colors.dart';
import 'package:haverr/utils/constants.dart';
import 'package:haverr/utils/global_variable.dart';
import 'package:haverr/utils/utils.dart';
import 'package:haverr/widgets/post_card.dart';
import 'package:provider/provider.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({Key? key}) : super(key: key);

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor:
          width > webScreenSize ? webBackgroundColor : mobileBackgroundColor,
      appBar: width > webScreenSize
          ? null
          : AppBar(
              backgroundColor: mobileBackgroundColor,
              centerTitle: false,
              title: Image.asset(
                'assets/headerImage.jpeg',
                width: 130,
                fit: BoxFit.fitWidth,
              ),
              actions: [
                InkWell(
                  child: getIconSvg("message", color: primaryColor),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ChatContactsListScreen(
                                  value: "",
                                )));
                  },
                ),
                InkWell(
                  onTap: () {},
                  child: getIconSvg("add", color: primaryColor),
                ),
              ],
            ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('posts').snapshots(),
        builder: (context,
            AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return SingleChildScrollView(
              child: Column(
                children: const [
                  InstagramPostLoading(),
                  InstagramPostLoading(),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (ctx, index) => Container(
              margin: EdgeInsets.symmetric(
                horizontal: width > webScreenSize ? width * 0.3 : 0,
                vertical: width > webScreenSize ? 15 : 0,
              ),
              child: PostCard(snap: snapshot.data!.docs[index].data()),
            ),
          );
        },
      ),
    );
  }
}
