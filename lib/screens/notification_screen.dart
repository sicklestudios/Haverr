import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:haverr/models/notification.dart';
import 'package:haverr/utils/utils.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  bool isLoading = true;
  List<NotificationModel> notifications = [];

  @override
  void initState() {
    super.initState();
    // simulate a delay to demonstrate the loading effect
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        isLoading = false;
        notifications = [
          NotificationModel(
            username: 'john_doe',
            avatarUrl: 'https://picsum.photos/id/101/50/50',
            message: 'started following you',
            imageUrl: '',
            isFollowing: true,
            isLiked: false,
            isCommented: false,
          ),
          NotificationModel(
            username: 'jane_doe',
            avatarUrl: 'https://picsum.photos/id/102/50/50',
            message: 'liked your photo',
            imageUrl: 'https://picsum.photos/id/201/300/300',
            isFollowing: false,
            isLiked: true,
            isCommented: false,
          ),
          NotificationModel(
            username: 'joe_doe',
            avatarUrl: 'https://picsum.photos/id/103/50/50',
            message: 'commented on your post',
            imageUrl: 'https://picsum.photos/id/202/300/300',
            isFollowing: false,
            isLiked: false,
            isCommented: true,
          ),
          NotificationModel(
            username: 'jim_doe',
            avatarUrl: 'https://picsum.photos/id/104/50/50',
            message: 'liked your comment',
            imageUrl: '',
            isFollowing: false,
            isLiked: true,
            isCommented: false,
          ),
        ];
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: isLoading
          ? NotificationLoading()
          : ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage:
                        CachedNetworkImageProvider(notification.avatarUrl),
                  ),
                  title: RichText(
                    text: TextSpan(
                      style: DefaultTextStyle.of(context).style,
                      children: [
                        TextSpan(
                          text: '${notification.username} ',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(text: notification.message),
                      ],
                    ),
                  ),
                  trailing: notification.imageUrl.isNotEmpty
                      ? Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              fit: BoxFit.cover,
                              image: CachedNetworkImageProvider(
                                  notification.imageUrl),
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                );
              },
            ),
    );
  }
}
