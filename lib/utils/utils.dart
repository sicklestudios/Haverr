import 'dart:io';

import 'package:another_flushbar/flushbar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:haverr/models/chat_model.dart';
import 'package:haverr/resources/chat_methods.dart';
import 'package:haverr/resources/colors.dart';
import 'package:haverr/screens/chat/chat_screen.dart';
import 'package:haverr/utils/constants.dart';
import 'package:haverr/utils/global_variable.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

storeNotificationToken() async {
  String? token = await FirebaseMessaging.instance.getToken();
  globalFirebaseFirestore
      .collection('users')
      .doc(globalFirebaseAuth.currentUser!.uid)
      .set({'token': token}, SetOptions(merge: true));
}

// for picking up image from gallery
pickImage(ImageSource source) async {
  final ImagePicker _imagePicker = ImagePicker();
  XFile? _file = await _imagePicker.pickImage(source: source);
  if (_file != null) {
    return await _file.readAsBytes();
  }
  print('No Image Selected');
}

// for displaying snackbars
showSnackBar(BuildContext context, String text) {
  return ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(text),
    ),
  );
}

Widget showUsersImage(
  bool isAsset, {
  String picUrl = "assets/user.png",
  double size = 25,
}) {
  if (picUrl == "") {
    picUrl = "assets/user.png";
  }
  return CircleAvatar(
    radius: size,
    backgroundImage: isAsset
        ? AssetImage(picUrl)
        : CachedNetworkImageProvider(picUrl) as ImageProvider,
  );
}

Widget getIconSvg(String path,
    {double iconSize = 30, Color color = Colors.white}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 8.0),
    child: SvgPicture.asset(
      '$assetIconPath$path.svg',
      height: iconSize,
      width: iconSize,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    ),
  );
}

void showFloatingFlushBar(
    BuildContext context, String upMessage, String downMessage) {
  Flushbar(
    borderRadius: BorderRadius.circular(8),
    duration: const Duration(seconds: 1),
    backgroundGradient: const LinearGradient(
      colors: [mainColor, mainColorFaded],
      stops: [0.6, 1],
    ),
    boxShadows: const [
      BoxShadow(
        color: Colors.white,
        offset: Offset(3, 3),
        blurRadius: 3,
      ),
    ],
    titleColor: Colors.white,
    messageColor: Colors.white,
    dismissDirection: FlushbarDismissDirection.HORIZONTAL,
    forwardAnimationCurve: Curves.fastLinearToSlowEaseIn,
    title: upMessage,
    message: downMessage,
  ).show(context);
}

showToastMessage(String toastText) {
  Fluttertoast.showToast(
      msg: toastText,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      backgroundColor: mainColor,
      textColor: Colors.white,
      fontSize: 16.0);
}

void showOTPDialog({
  required BuildContext context,
  required TextEditingController codeController,
  required VoidCallback onPressed,
}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      title: const Text("Enter OTP"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          TextField(
            controller: codeController,
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          child: const Text("Done"),
          onPressed: onPressed,
        )
      ],
    ),
  );
}

class PostLoadingEffect extends StatelessWidget {
  const PostLoadingEffect({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
        baseColor: const Color.fromARGB(255, 151, 151, 151),
        highlightColor: const Color.fromARGB(255, 156, 156, 156),
        child: StaggeredGridView.countBuilder(
          crossAxisCount: 3,
          itemCount: 20,
          itemBuilder: (context, index) => Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        'https://picsum.photos/id/$index/200/200',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 10,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: Colors.grey[300],
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  height: 10,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: Colors.grey[300],
                  ),
                ),
              ],
            ),
          ),
          staggeredTileBuilder: (index) =>
              MediaQuery.of(context).size.width > webScreenSize
                  ? StaggeredTile.count(
                      (index % 7 == 0) ? 1 : 1, (index % 7 == 0) ? 1 : 1)
                  : StaggeredTile.count(
                      (index % 7 == 0) ? 2 : 1, (index % 7 == 0) ? 2 : 1),
          mainAxisSpacing: 8.0,
          crossAxisSpacing: 8.0,
        ));
  }
}

class ReelLoadingIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color.fromARGB(255, 238, 238, 238),
      highlightColor: const Color.fromARGB(255, 182, 181, 181),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: 200,
            color: Colors.white,
          ),
          const SizedBox(height: 16.0),
          Container(
            width: double.infinity,
            height: 200,
            color: Colors.white,
          ),
          const SizedBox(height: 16.0),
          Container(
            width: double.infinity,
            height: 200,
            color: Colors.white,
          ),
        ],
      ),
    );
  }
}

class NotificationLoading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        itemCount: 10,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  radius: 24,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        height: 16,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 4),
                      Container(
                        width: 100,
                        height: 16,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        height: 50,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class InstagramPostLoading extends StatelessWidget {
  const InstagramPostLoading({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Shimmer.fromColors(
        baseColor: const Color.fromARGB(255, 238, 238, 238),
        highlightColor: const Color.fromARGB(255, 182, 181, 181),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Post Header
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.grey[300],
                  radius: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 100,
                        height: 10,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      const SizedBox(height: 5),
                      // Container(
                      //   width: 50,
                      //   height: 10,
                      //   decoration: BoxDecoration(
                      //     color: Colors.grey[300],
                      //     borderRadius: BorderRadius.circular(5),
                      //   ),
                      // ),
                    ],
                  ),
                ),
                const Icon(Icons.more_vert),
              ],
            ),

            const SizedBox(height: 10),

            Container(
              width: 150,
              height: 10,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              width: 250,
              height: 10,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            const SizedBox(height: 10),

            // Post Image
            Container(
              height: 300,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 10),
            // Post Footer
            Row(
              children: [
                const Icon(Icons.favorite_border),
                const SizedBox(width: 10),
                getIconSvg("comment", iconSize: 30),
                const SizedBox(width: 10),
                getIconSvg("send"),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(),
                ),
                getIconSvg("save")
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Container(
                  width: 80,
                  height: 10,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  width: 80,
                  height: 10,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 184, 184, 184),
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Post Caption
            // Container(
            //   width: double.infinity,
            //   height: 10,
            //   decoration: BoxDecoration(
            //     color: Colors.grey[300],
            //     borderRadius: BorderRadius.circular(5),
            //   ),
            // ),
            // const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}

// //returs a widget that acts as a prompt
// getNewChatPrompt(context) {
//   return Center(
//     child: Padding(
//       padding: const EdgeInsets.all(10.0),
//       child: SizedBox(
//         height: 150,
//         child: Card(
//           child: Column(
//             children: [
//               const Padding(
//                 padding: EdgeInsets.all(20.0),
//                 child: Text(
//                   "You dont have any chats\nstart a chat",
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//               ElevatedButton(
//                   onPressed: () {
//                     showNewMessage(context);
//                   },
//                   child: const Text('Start a chat')),
//             ],
//           ),
//         ),
//       ),
//     ),
//   );
// }
// void showNewMessage(BuildContext context) async {
//   var size = MediaQuery.of(context).size;
//   return await showDialog(
//       barrierDismissible: true,
//       context: context,
//       builder: ((context) => SimpleDialog(
//               title: Row(
//                 children: [
//                   const Expanded(
//                       child: Center(child: Text("Create New Message"))),
//                   IconButton(
//                       onPressed: () {
//                         Navigator.of(context, rootNavigator: true).pop();
//                       },
//                       icon: const Icon(Icons.close))
//                 ],
//               ),
//               shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(25)),
//               contentPadding: const EdgeInsets.all(8),
//               children: [
//                 SizedBox(
//                   height: size.height / 2,
//                   width: size.width,
//                   child: Scaffold(
//                     body: ContactsScreen(
//                       isChat: true,
//                     ),
//                   ),
//                 ),
//               ])));
// }
Widget returnNothingToShow() {
  return Center(
      child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: const [
      Icon(
        Icons.sentiment_neutral_rounded,
        size: 50,
      ),
      Padding(
        padding: EdgeInsets.only(top: 15.0),
        child: Text("Nothing to Show"),
      )
    ],
  ));
}

getMessageCard(var model, context, {bool isGroupChat = false}) {
  // Group model = models;
  bool seen = false;
  if (isGroupChat) {
    if (model.isSeen.contains(globalFirebaseAuth.currentUser!.uid)) {
      seen = true;
    } else {
      seen = false;
    }
  } else {
    seen = model.isSeen;
  }
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
    child: Container(
      height: 80,
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => ChatScreen(
                    contactModel: ChatContactModel(
                      contactId: isGroupChat ? model.groupId : model.contactId,
                      name: model.name,
                      photoUrl: isGroupChat ? model.groupPic : model.photoUrl,
                      timeSent: DateTime.now(),
                      lastMessageBy: "",
                      lastMessageId: '',
                      isSeen: false,
                      lastMessage: "",
                    ),
                    people: isGroupChat ? model.membersUid : [],
                    isGroupChat: isGroupChat,
                  )));
        },
        leading: Stack(
          children: [
            isGroupChat
                ? model.groupPic != ""
                    ? CircleAvatar(
                        radius: 25,
                        backgroundImage: CachedNetworkImageProvider(
                          model.groupPic,
                          // maxWidth: 50,
                          // maxHeight: 50,
                        ))
                    : const CircleAvatar(
                        radius: 25, child: Icon(Icons.groups_outlined))
                : showUsersImage(model.photoUrl == "",
                    size: 25,
                    picUrl: model.photoUrl != ""
                        ? model.photoUrl
                        : 'assets/user.png'),
            if (!isGroupChat)
              StreamBuilder<bool>(
                  stream: ChatMethods().getOnlineStream(model.contactId),
                  builder: (context, snapshot) {
                    return Positioned(
                        bottom: 1,
                        right: 1,
                        child: Icon(
                          Icons.circle_rounded,
                          size: 14,
                          color: snapshot.data != null
                              ? snapshot.data!
                                  ? Colors.green
                                  : Colors.grey
                              : Colors.grey,
                        ));
                  }),
          ],
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              model.name,
              // "model."
              // "name",
              style: TextStyle(
                  fontSize: 18,
                  //  bodyTextOverflow: TextOverflow.ellipsis,
                  fontWeight:
                      model.lastMessageBy != globalFirebaseAuth.currentUser!.uid
                          ? !seen
                              ? FontWeight.bold
                              : FontWeight.normal
                          : FontWeight.normal),
            ),
            Text(
              DateFormat.jm().format(model.timeSent),
              style: TextStyle(
                  fontSize: 12,
                  fontWeight:
                      model.lastMessageBy != globalFirebaseAuth.currentUser!.uid
                          ? !seen
                              ? FontWeight.bold
                              : FontWeight.normal
                          : FontWeight.normal),
            ),
          ],
        ),
        subtitle: SizedBox(
          height: 15,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 30),
                  child: Text(
                    model.lastMessage,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: model.lastMessageBy !=
                                globalFirebaseAuth.currentUser!.uid
                            ? !seen
                                ? FontWeight.bold
                                : FontWeight.normal
                            : FontWeight.normal),
                  ),
                ),
              ),
              // if (!isGroupChat)
              Icon(
                Icons.circle,
                color:
                    model.lastMessageBy != globalFirebaseAuth.currentUser!.uid
                        ? !seen
                            ? mainColor
                            : Colors.transparent
                        : Colors.transparent,
                size: 14,
              )
            ],
          ),
        ),
      ),
    ),
  );
}

getDateWithLines(dateInList) {
  var tempDate = DateFormat.MMMMEEEEd().format(DateTime.now());
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: Row(children: [
      Expanded(
        child: Container(
            margin: const EdgeInsets.only(left: 10.0, right: 20.0),
            child: const Divider(
              color: Colors.black,
              height: 36,
            )),
      ),
      Text(dateInList == tempDate ? "Today" : dateInList,
          style: const TextStyle(color: Colors.grey)),
      Expanded(
        child: Container(
            margin: const EdgeInsets.only(left: 20.0, right: 10.0),
            child: const Divider(
              color: Colors.black,
              height: 36,
            )),
      ),
    ]),
  );
}

getAvatarWithStatus(bool isGroupChat, ChatContactModel contactModel,
    {double size = 22}) {
  return Stack(
    children: [
      isGroupChat
          ? contactModel.photoUrl != ""
              ? CircleAvatar(
                  radius: size,
                  backgroundImage: CachedNetworkImageProvider(
                    contactModel.photoUrl,
                    // maxWidth: 50,
                    // maxHeight: 50,
                  ))
              : CircleAvatar(
                  radius: size, child: const Icon(Icons.groups_outlined))
          : showUsersImage(contactModel.photoUrl == "",
              picUrl: contactModel.photoUrl, size: size),
      if (!isGroupChat)
        StreamBuilder<bool>(
            stream: ChatMethods().getOnlineStream(contactModel.contactId),
            builder: (context, snapshot) {
              return Positioned(
                  bottom: 1,
                  right: 1,
                  child: Icon(
                    Icons.circle_rounded,
                    size: size >= 25 ? 25 : 14,
                    color: snapshot.data != null
                        ? snapshot.data!
                            ? Colors.green
                            : Colors.grey
                        : Colors.grey,
                  ));
            }),
    ],
  );
}

Future<File?> pickImageFromGallery(BuildContext context) async {
  File? image;
  try {
    final pickedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      image = File(pickedImage.path);
    }
  } catch (e) {
    // showSnackBar(context: context, content: e.toString());
  }
  return image;
}

Future<File?> pickVideoFromGallery(BuildContext context) async {
  File? video;
  try {
    final pickedVideo =
        await ImagePicker().pickVideo(source: ImageSource.gallery);

    if (pickedVideo != null) {
      video = File(pickedVideo.path);
    }
  } catch (e) {
    // showSnackBar(context: context, content: e.toString());
  }
  return video;
}
