// import 'package:flutter/material.dart';
// import 'package:haverr/models/user.dart';
// import 'package:haverr/resources/chat_methods.dart';


// class ForwardMessageScreen extends StatefulWidget {
//   final List<Message> messageList;
//   const ForwardMessageScreen({required this.messageList, super.key});

//   @override
//   State<ForwardMessageScreen> createState() => _ForwardMessageScreenState();
// }

// class _ForwardMessageScreenState extends State<ForwardMessageScreen> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         automaticallyImplyLeading: false,
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         title: Row(
//           mainAxisAlignment: MainAxisAlignment.start,
//           children: [
//             IconButton(
//                 onPressed: () {
//                   Navigator.pop(context);
//                 },
//                 icon: const Icon(
//                   Icons.arrow_back,
//                   size: 25,
//                   color: Colors.black,
//                 )),
//             const SizedBox(
//               width: 10,
//             ),
//             const Text(
//               "Forward Message",
//               style: TextStyle(
//                 color: Colors.black,
//               ),
//             ),
//           ],
//         ),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.only(top: 20.0),
//         child: FutureBuilder<List<UserModel>>(
//             future: ChatMethods().getContacts(),
//             builder: (context, snapshot) {
//               if (snapshot.connectionState == ConnectionState.waiting) {
//                 return const Center(
//                   child: CircularProgressIndicator(),
//                 );
//               }
//               if (snapshot.data == null) {
//                 return const Center(
//                   child: Text("Nothing to show you"),
//                 );
//               }
//               return ListView.builder(
//                   itemCount: snapshot.data!.length,
//                   shrinkWrap: true,
//                   itemBuilder: ((context, index) {
//                     var data = snapshot.data![index];
//                     return InkWell(
//                       onTap: () {
//                         Navigator.of(context).pushAndRemoveUntil(
//                             MaterialPageRoute(
//                                 builder: (context) => ChatScreen(
//                                       message: widget.messageList,
//                                       contactModel: ChatContactModel(
//                                           contactId: data.uid,
//                                           name: data.username,
//                                           photoUrl: data.photoUrl,
//                                           timeSent: DateTime.now(),
//                                           lastMessageBy: "",
//                                           lastMessageId: "",
//                                           isSeen: false,
//                                           lastMessage: ""),
//                                     )),
//                             (route) => route.isFirst);
//                       },
//                       child: getForwardCard(data, context),
//                     );
//                   }));
//             }),
//       ),
//     );
//   }
// }
