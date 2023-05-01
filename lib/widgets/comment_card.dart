import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:haverr/providers/user_provider.dart';
import 'package:haverr/resources/firestore_methods.dart';
import 'package:haverr/widgets/like_animation.dart';
import 'package:intl/intl.dart';
import 'package:haverr/models/user.dart' as model;
import 'package:provider/provider.dart';

class CommentCard extends StatelessWidget {
  final String postId;
  final snap;
  const CommentCard({Key? key, required this.postId, required this.snap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final model.UserModel user = Provider.of<UserProvider>(context).getUser;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: Row(
        children: [
          CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(
              snap.data()['profilePic'],
            ),
            radius: 18,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                            text: snap.data()['name'],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            )),
                        TextSpan(
                          text: ' ${snap.data()['text']}',
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      DateFormat.yMMMd().format(
                        snap.data()['datePublished'].toDate(),
                      ),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            child: LikeAnimation(
              isAnimating: snap.data()['likes'].contains(user.uid),
              smallLike: true,
              child: IconButton(
                icon: snap.data()['likes'].contains(user.uid)
                    ? const Icon(
                        Icons.favorite,
                        color: Colors.red,
                      )
                    : const Icon(
                        Icons.favorite_border,
                      ),
                onPressed: () => FireStoreMethods().likeComment(
                  postId,
                  snap.data()['commentId'].toString(),
                  user.uid,
                  snap.data()['likes'],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
