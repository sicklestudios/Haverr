import 'dart:developer';

import 'package:akar_icons_flutter/akar_icons_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:haverr/providers/user_provider.dart';
import 'package:haverr/models/user.dart' as model;
import 'package:haverr/resources/firestore_methods.dart';
import 'package:haverr/screens/comments_screen.dart';
import 'package:haverr/utils/colors.dart';
import 'package:haverr/utils/global_variable.dart';
import 'package:haverr/utils/utils.dart';
import 'package:haverr/widgets/like_animation.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:haverr/utils/constants.dart';

class PostCard extends StatefulWidget {
  final snap;
  PostCard({
    Key? key,
    required this.snap,
  }) : super(key: key);

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  int commentLen = 0;
  bool isLikeAnimating = false;

  @override
  void initState() {
    super.initState();
    fetchCommentLen();
  }

  fetchCommentLen() async {
    try {
      QuerySnapshot snap = await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.snap['postId'])
          .collection('comments')
          .get();
      commentLen = snap.docs.length;
    } catch (err) {
      showSnackBar(
        context,
        err.toString(),
      );
    }
    if (mounted) {
      setState(() {});
    }
  }

  deletePost(String postId) async {
    try {
      await FireStoreMethods().deletePost(postId);
    } catch (err) {
      showSnackBar(
        context,
        err.toString(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    model.UserModel user = Provider.of<UserProvider>(context).getUser;

    final width = MediaQuery.of(context).size.width;

    return Container(
      // boundary needed for web
      decoration: BoxDecoration(
        border: Border.all(
          color: width > webScreenSize ? secondaryColor : mobileBackgroundColor,
        ),
        color: mobileBackgroundColor,
      ),
      padding: const EdgeInsets.symmetric(
        vertical: 10,
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      // mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                    20), // sets rounded corners
                                border: Border.all(
                                    width: 2,
                                    color: Colors.white), // sets border
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20), // set
                                child: Image(
                                  fit: BoxFit.fitWidth,
                                  image: CachedNetworkImageProvider(
                                    widget.snap['profImage'].toString(),
                                  ),
                                ),
                              ),
                            ),
                            // SizedBox(
                            //   width: 40,
                            //   height: 40,
                            //   child: ClipRRect(
                            //     borderRadius: BorderRadius.circular(10),
                            //     child:
                            //   ),
                            // ),
                            const SizedBox(
                              width: 5,
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  widget.snap['username'].toString(),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(
                                  height: 15,
                                ),
                                // if(widget.snap[])
                                // Icon(Icons.verified)
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    widget.snap['uid'].toString() == user.uid
                        ? IconButton(
                            onPressed: () {
                              showDialog(
                                useRootNavigator: false,
                                context: context,
                                builder: (context) {
                                  return Dialog(
                                    child: ListView(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 16),
                                        shrinkWrap: true,
                                        children: [
                                          'Delete',
                                        ]
                                            .map(
                                              (e) => InkWell(
                                                  child: Container(
                                                    padding: const EdgeInsets
                                                            .symmetric(
                                                        vertical: 12,
                                                        horizontal: 16),
                                                    child: Text(e),
                                                  ),
                                                  onTap: () {
                                                    deletePost(
                                                      widget.snap['postId']
                                                          .toString(),
                                                    );
                                                    // remove the dialog box
                                                    Navigator.of(context).pop();
                                                  }),
                                            )
                                            .toList()),
                                  );
                                },
                              );
                            },
                            icon: const Icon(Icons.more_vert),
                          )
                        : Container(),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    "Posted On${DateFormat.yMMMd().format(widget.snap['datePublished'].toDate())}",
                    style: const TextStyle(
                      color: secondaryColor,
                    ),
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(
                    top: 2,
                  ),
                  child: InkWell(
                    onTap: () {
                      if (widget.snap['description'].length > 25) {}
                    },
                    child: Text('${widget.snap['description']}',
                        style:
                            const TextStyle(color: Colors.white, fontSize: 14)),
                  ),
                ),
              ],
            ),
          ),
          // IMAGE SECTION OF THE POST
          GestureDetector(
            onDoubleTap: () {
              FireStoreMethods().likePost(
                widget.snap['postId'].toString(),
                user.uid,
                widget.snap['likes'],
              );
              setState(() {
                isLikeAnimating = true;
              });
            },
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  // height: MediaQuery.of(context).size.height * 0.35,
                  width: double.infinity,
                  child: CachedNetworkImage(
                    placeholder: (context, url) {
                      return Image.asset(
                        "assets/image_placeholder.jpg",
                        fit: BoxFit.fill,
                      );
                    },
                    // progressIndicatorBuilder:
                    //     (context, url, downloadProgress) =>
                    //         CircularProgressIndicator(
                    //             value: downloadProgress.progress),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error),
                    imageUrl: widget.snap['postUrl'].toString(),
                    fit: BoxFit.cover,
                  ),
                ),
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: isLikeAnimating ? 1 : 0,
                  child: LikeAnimation(
                    isAnimating: isLikeAnimating,
                    duration: const Duration(
                      milliseconds: 400,
                    ),
                    onEnd: () {
                      setState(() {
                        isLikeAnimating = false;
                      });
                    },
                    child: const Icon(
                      Icons.favorite,
                      color: Colors.white,
                      size: 100,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // LIKE, COMMENT SECTION OF THE POST
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    LikeAnimation(
                      isAnimating: widget.snap['likes'].contains(user.uid),
                      smallLike: true,
                      child: IconButton(
                        icon: widget.snap['likes'].contains(user.uid)
                            ? const Icon(
                                Icons.favorite,
                                color: Colors.red,
                              )
                            : const Icon(
                                Icons.favorite_border,
                              ),
                        onPressed: () => FireStoreMethods().likePost(
                          widget.snap['postId'].toString(),
                          user.uid,
                          widget.snap['likes'],
                        ),
                      ),
                    ),
                    InkWell(
                      child: getIconSvg("comment", iconSize: 30),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => CommentsScreen(
                            postId: widget.snap['postId'].toString(),
                          ),
                        ),
                      ),
                    ),
                    InkWell(child: getIconSvg("send"), onTap: () {}),
                  ],
                ),
                ValueListenableBuilder<List<dynamic>>(
                  builder: (BuildContext context, value, Widget? child) {
                    return InkWell(
                        child: value.contains(widget.snap['postId'])
                            ? getIconSvg("save_filled")
                            : getIconSvg("save"),
                        onTap: () {
                          FireStoreMethods()
                              .savePost(widget.snap['postId'], user.uid, value);
                        });
                  },
                  valueListenable: userSaves,
                ),
              ],
            ),
          ),
          // Bottome SECTION OF THE POST

          //DESCRIPTION AND NUMBER OF COMMENTS
          Padding(
            padding: const EdgeInsets.only(
              left: 8,
            ),
            child: DefaultTextStyle(
                style: Theme.of(context)
                    .textTheme
                    .titleSmall!
                    .copyWith(fontWeight: FontWeight.w800),
                child: Row(
                  children: [
                    const Icon(
                      Icons.favorite,
                      size: 15,
                    ),
                    Text(
                      ' ${widget.snap['likes'].length} likes',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    getIconSvg('comment', iconSize: 20),
                    Text(
                      '$commentLen replies',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                )),
          ),
        ],
      ),
    );
  }
}
