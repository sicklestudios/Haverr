import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:haverr/models/chat_model.dart';
import 'package:haverr/models/group.dart';
import 'package:haverr/models/user.dart';
import 'package:haverr/providers/user_provider.dart';
import 'package:haverr/resources/message_enum.dart';
import 'package:haverr/resources/message_reply.dart';
import 'package:haverr/resources/storage_methods.dart';
import 'package:haverr/utils/global_variable.dart';
import 'package:haverr/utils/utils.dart';
import 'package:path/path.dart';
import 'package:uuid/uuid.dart';

class ChatMethods {
  void _saveContactMessageAfterDeletion(
    String text,
    DateTime timeSent,
    String lastMessageId,
    String recieverUserId,
  ) async {
    // users -> current user id  => chats -> reciever user id -> set data
    //  var timeSent = DateTime.now();
    UserModel? recieverUserData;
    var userDataMap = await globalFirebaseFirestore
        .collection('users')
        .doc(recieverUserId)
        .get();
    recieverUserData = UserModel.fromSnap(userDataMap);

    var senderChatContact = ChatContactModel(
        name: recieverUserData.username,
        photoUrl: recieverUserData.photoUrl,
        contactId: recieverUserData.uid,
        timeSent: timeSent,
        lastMessage: text,
        lastMessageId: lastMessageId,
        lastMessageBy: globalFirebaseAuth.currentUser!.uid,
        isSeen: true);

    await globalFirebaseFirestore
        .collection('users')
        .doc(globalFirebaseAuth.currentUser!.uid)
        .collection('chats')
        .doc(recieverUserId)
        .set(
          senderChatContact.toMap(),
        );
  }

  void _saveDataToContactsSubcollection(
    UserModel senderUserData,
    UserModel? recieverUserData,
    String text,
    DateTime timeSent,
    String lastMessageId,
    String recieverUserId,
    bool isGroupChat,
  ) async {
    if (isGroupChat) {
      await globalFirebaseFirestore
          .collection('groups')
          .doc(recieverUserId)
          .update({
        'lastMessage': text,
        'lastMessageBy': globalFirebaseAuth.currentUser!.uid,
        'timeSent': DateTime.now().millisecondsSinceEpoch,
      });
    } else {
// users -> reciever user id => chats -> current user id -> set data
      var recieverChatContact = ChatContactModel(
          // name: senderUserData.username,
          name: senderUserData.username,
          photoUrl: senderUserData.photoUrl,
          contactId: senderUserData.uid,
          timeSent: timeSent,
          lastMessage: text,
          lastMessageId: lastMessageId,
          lastMessageBy: globalFirebaseAuth.currentUser!.uid,
          isSeen: false);

      //checking if the receiver has blocked this user
      if (!await checkMessageAllowed(recieverUserId)) {
        await globalFirebaseFirestore
            .collection('users')
            .doc(recieverUserId)
            .collection('chats')
            .doc(globalFirebaseAuth.currentUser!.uid)
            .set(
              recieverChatContact.toMap(),
            );
      }

      // users -> current user id  => chats -> reciever user id -> set data
      var senderChatContact = ChatContactModel(
          name: recieverUserData!.username,
          photoUrl: recieverUserData.photoUrl,
          contactId: recieverUserData.uid,
          timeSent: timeSent,
          lastMessage: text,
          lastMessageId: lastMessageId,
          lastMessageBy: globalFirebaseAuth.currentUser!.uid,
          isSeen: false);

      await globalFirebaseFirestore
          .collection('users')
          .doc(globalFirebaseAuth.currentUser!.uid)
          .collection('chats')
          .doc(recieverUserId)
          .set(
            senderChatContact.toMap(),
          );
      // }
    }
  }

  void _saveMessageToMessageSubcollection({
    required String recieverUserId,
    required String text,
    required DateTime timeSent,
    required String messageId,
    required String username,
    required MessageEnum messageType,
    required MessageReply? messageReply,
    required String senderUsername,
    required String? recieverUserName,
    required bool isGroupChat,
  }) async {
    final message = Message(
      senderUsername: senderUsername,
      senderId: globalFirebaseAuth.currentUser!.uid,
      recieverid: recieverUserId,
      text: text,
      type: messageType,
      timeSent: timeSent,
      messageId: messageId,
      isSeen: false,
      repliedMessage: messageReply == null ? '' : messageReply.message,
      repliedTo: messageReply == null
          ? ''
          : messageReply.isMe
              ? senderUsername
              : recieverUserName ?? '',
      repliedMessageType:
          messageReply == null ? MessageEnum.text : messageReply.messageEnum,
    );
    if (isGroupChat) {
      // groups -> group id -> chat -> message
      await globalFirebaseFirestore
          .collection('groups')
          .doc(recieverUserId)
          .collection('chats')
          .doc(messageId)
          .set(
            message.toMap(),
          );

      //Setting the value of the isSeen list to null on new message
      await globalFirebaseFirestore
          .collection('groups')
          .doc(recieverUserId)
          .update({
        "isSeen": [globalFirebaseAuth.currentUser!.uid]
      });
      //get all the people in the group
      var snapshot = await globalFirebaseFirestore
          .collection('groups')
          .doc(recieverUserId)
          .get();
      Group group = Group.fromMap(snapshot.data()!);
      List users = group.membersUid;
      for (var element in users) {
        if (element != globalFirebaseAuth.currentUser!.uid) {
          log(element);
          // getting token of all the people in the group
          String token = await getUserNotificationToken(element);

          // sendNotification(element, token, "You have a new message");

          // //adding the message to the collection of infos
          // if (message.type == MessageEnum.link) {
          //   InfoStorage().storeLink(timeSent, text, element, isGroupChat);
          // } else if (message.type == MessageEnum.file) {
          //   String fileName = text.substring(0, text.indexOf("@@@"));
          //   String url = text.substring(text.indexOf("@@@") + 3, text.length);
          //   InfoStorage().storeFile(timeSent, url, fileName, element,
          //       globalFirebaseAuth.currentUser!.uid, isGroupChat);
          // } else if (message.type == MessageEnum.image) {
          //   InfoStorage().storeMedia(timeSent, text, element,
          //       globalFirebaseAuth.currentUser!.uid, isGroupChat);
          // }
        }
      }
      // if (message.type == MessageEnum.link) {
      //   InfoStorageGroup().storeLink(timeSent, text, recieverUserId);
      // } else if (message.type == MessageEnum.file) {
      //   String fileName = text.substring(0, text.indexOf("@@@"));
      //   String url = text.substring(text.indexOf("@@@") + 3, text.length);
      //   InfoStorageGroup().storeFile(timeSent, url, fileName, recieverUserId,
      //       globalFirebaseAuth.currentUser!.uid);
      // } else if (message.type == MessageEnum.image) {
      //   InfoStorageGroup().storeMedia(
      //       timeSent, text, recieverUserId, globalFirebaseAuth.currentUser!.uid);
      // }
    } else {
      // users -> sender id -> reciever id -> messages -> message id -> store message
      await globalFirebaseFirestore
          .collection('users')
          .doc(globalFirebaseAuth.currentUser!.uid)
          .collection('chats')
          .doc(recieverUserId)
          .collection('messages')
          .doc(messageId)
          .set(
            message.toMap(),
          );
      // users -> eeciever id  -> sender id -> messages -> message id -> store message
      if (!await checkMessageAllowed(recieverUserId)) {
        await globalFirebaseFirestore
            .collection('users')
            .doc(recieverUserId)
            .collection('chats')
            .doc(globalFirebaseAuth.currentUser!.uid)
            .collection('messages')
            .doc(messageId)
            .set(
              message.toMap(),
            );

        String token = await getUserNotificationToken(recieverUserId);

        // sendNotification(recieverUserId, token, "You have a new message");

        // //adding the message to the collection of infos
        // if (message.type == MessageEnum.link) {
        //   InfoStorage().storeLink(timeSent, text, recieverUserId, isGroupChat);
        // } else if (message.type == MessageEnum.file) {
        //   String fileName = text.substring(0, text.indexOf("@@@"));
        //   String url = text.substring(text.indexOf("@@@") + 3, text.length);
        //   InfoStorage().storeFile(timeSent, url, fileName, recieverUserId,
        //       globalFirebaseAuth.currentUser!.uid, isGroupChat);
        // } else if (message.type == MessageEnum.image) {
        //   InfoStorage().storeMedia(timeSent, text, recieverUserId,
        //       globalFirebaseAuth.currentUser!.uid, isGroupChat);
        // }
      }
    }
  }

  Future<String> getUserNotificationToken(String id) async {
    DocumentSnapshot documentSnapshot =
        await globalFirebaseFirestore.collection('users').doc(id).get();
    //receivers token for sending notification to the user
    return documentSnapshot.get('token');
  }

  void sendTextMessage({
    required BuildContext context,
    required String text,
    required String recieverUserId,
    required UserModel senderUser,
    required MessageReply? messageReply,
    required bool isGroupChat,
  }) async {
    try {
      var timeSent = DateTime.now();
      UserModel? recieverUserData;
      if (!isGroupChat) {
        var userDataMap = await globalFirebaseFirestore
            .collection('users')
            .doc(recieverUserId)
            .get();
        recieverUserData = UserModel.fromSnap(userDataMap);
      }

      var messageId = const Uuid().v1();

      _saveDataToContactsSubcollection(
        senderUser,
        recieverUserData,
        text,
        timeSent,
        messageId,
        recieverUserId,
        isGroupChat,
      );
      MessageEnum val;
      if (text.toLowerCase().startsWith("http:") ||
          text.toLowerCase().startsWith("https:")) {
        val = MessageEnum.link;
      } else {
        val = MessageEnum.text;
      }
      _saveMessageToMessageSubcollection(
          recieverUserId: recieverUserId,
          text: text,
          timeSent: timeSent,
          messageType: val,
          messageId: messageId,
          username: senderUser.username,
          messageReply: messageReply,
          recieverUserName: recieverUserData?.username,
          senderUsername: senderUser.username,
          isGroupChat: isGroupChat);
    } catch (e) {
      showFloatingFlushBar(context, "Error", e.toString());
    }
  }

  void sendFileMessage({
    required BuildContext context,
    required File file,
    required String recieverUserId,
    required UserModel senderUserData,
    required MessageEnum messageEnum,
    required MessageReply? messageReply,
    required bool isGroupChat,
  }) async {
    try {
      var timeSent = DateTime.now();
      var messageId = const Uuid().v1();

      String imageUrl = await StorageMethods().storeFileToFirebase(
        'chat/${messageEnum.type}/${senderUserData.uid}/$recieverUserId/$messageId',
        file,
      );

      UserModel? recieverUserData;
      if (!isGroupChat) {
        var userDataMap = await globalFirebaseFirestore
            .collection('users')
            .doc(recieverUserId)
            .get();
        recieverUserData = UserModel.fromSnap(userDataMap);
      }

      String contactMsg;

      switch (messageEnum) {
        case MessageEnum.image:
          contactMsg = '📷 Photo';
          break;
        case MessageEnum.video:
          contactMsg = '📸 Video';
          break;
        case MessageEnum.audio:
          contactMsg = '🎵 Audio';
          break;
        case MessageEnum.link:
          contactMsg = 'Link';
          break;
        case MessageEnum.file:
          contactMsg = basename(file.path);
          break;
        default:
          contactMsg = 'GIF';
      }

      _saveDataToContactsSubcollection(senderUserData, recieverUserData,
          contactMsg, timeSent, messageId, recieverUserId, isGroupChat);

      _saveMessageToMessageSubcollection(
          recieverUserId: recieverUserId,
          text: messageEnum == MessageEnum.file
              ? "$contactMsg@@@$imageUrl"
              : imageUrl,
          timeSent: timeSent,
          messageId: messageId,
          username: senderUserData.username,
          messageType: messageEnum,
          messageReply: messageReply,
          recieverUserName: recieverUserData?.username,
          senderUsername: senderUserData.username,
          isGroupChat: isGroupChat);
    } catch (e) {
      showFloatingFlushBar(context, "Error", e.toString());
    }
  }

  void sendForwardedFileMessage(
      {required BuildContext context,
      required String fileUrl,
      required String recieverUserId,
      required UserModel senderUserData,
      required MessageEnum messageEnum,
      required MessageReply? messageReply,
      required bool isGroupChat}) async {
    try {
      var timeSent = DateTime.now();
      var messageId = const Uuid().v1();

      // String imageUrl = await StorageMethods().storeFileToFirebase(
      //   'chat/${messageEnum.type}/${senderUserData.uid}/$recieverUserId/$messageId',
      //   file,
      // );

      UserModel? recieverUserData;
      if (!isGroupChat) {
        var userDataMap = await globalFirebaseFirestore
            .collection('users')
            .doc(recieverUserId)
            .get();
        recieverUserData = UserModel.fromSnap(userDataMap);
      }

      String contactMsg;

      switch (messageEnum) {
        case MessageEnum.image:
          contactMsg = '📷 Photo';
          break;
        case MessageEnum.video:
          contactMsg = '📸 Video';
          break;
        case MessageEnum.audio:
          contactMsg = '🎵 Audio';
          break;
        case MessageEnum.link:
          contactMsg = 'Link';
          break;
        // case MessageEnum.file:
        //   contactMsg = fileUrl;
        //   break;
        default:
          contactMsg = 'GIF';
      }
      String fileName = "";
      if (messageEnum == MessageEnum.file) {
        fileName = fileUrl.substring(0, fileUrl.indexOf("@@@"));
      }

      _saveDataToContactsSubcollection(
          senderUserData,
          recieverUserData,
          messageEnum == MessageEnum.file ? fileName : contactMsg,
          timeSent,
          messageId,
          recieverUserId,
          isGroupChat);

      _saveMessageToMessageSubcollection(
          recieverUserId: recieverUserId,
          text: fileUrl,
          timeSent: timeSent,
          messageId: messageId,
          username: senderUserData.username,
          messageType: messageEnum,
          messageReply: messageReply,
          recieverUserName: recieverUserData?.username,
          senderUsername: senderUserData.username,
          isGroupChat: isGroupChat);
    } catch (e) {
      showFloatingFlushBar(context, "Error", e.toString());
    }
  }

  // stremas
  Stream<List<ChatContactModel>> getChatContacts() {
    return globalFirebaseFirestore
        .collection('users')
        .doc(globalFirebaseAuth.currentUser!.uid)
        .collection('chats')
        .orderBy('timeSent', descending: true)
        .snapshots()
        .asyncMap((event) async {
      List<ChatContactModel> contacts = [];
      for (var document in event.docs) {
        try {
          var chatContact = ChatContactModel.fromMap(document.data());
          contacts.add(chatContact);
        } catch (e) {
          log(e.toString());
        }
      }
      return contacts;
    });
  }

  // stremas
  Stream<List<Group>> getChatGroups() {
    return globalFirebaseFirestore
        .collection('groups')
        .snapshots()
        .map((event) {
      List<Group> groups = [];
      for (var document in event.docs) {
        var group = Group.fromMap(document.data());
        if (group.membersUid.contains(globalFirebaseAuth.currentUser!.uid)) {
          groups.add(group);
        }
      }
      return groups;
    });
  }

  Stream<List<Message>> getGroupChatStream(String groupId) {
    return globalFirebaseFirestore
        .collection('groups')
        .doc(groupId)
        .collection('chats')
        .orderBy(
          'timeSent',
        )
        .snapshots()
        .map((event) {
      List<Message> messages = [];
      for (var document in event.docs) {
        try {
          messages.add(Message.fromMap(document.data()));
        } catch (e) {
          log(e.toString());
        }
      }
      return messages;
    });
  }

  Stream<List<Message>> getChatStream(int limit, String recieverUserId) {
    return globalFirebaseFirestore
        .collection('users')
        .doc(globalFirebaseAuth.currentUser!.uid)
        .collection('chats')
        .doc(recieverUserId)
        .collection('messages')
        .orderBy(
          'timeSent',
        )
        .limitToLast(limit)
        .snapshots()
        .map((event) {
      List<Message> messages = [];
      for (var document in event.docs) {
        messages.add(Message.fromMap(document.data()));
      }
      return messages;
    });
  }

  //get online status
  Stream<bool> getOnlineStream(String recieverUserId) {
    return globalFirebaseFirestore
        .collection('users')
        .doc(recieverUserId)
        .snapshots()
        .map((event) {
      return UserModel.fromSnap(event).isOnline;
    });
  }

  //get online status
  Stream<UserModel> getBlockStatus() {
    return globalFirebaseFirestore
        .collection('users')
        .doc(globalFirebaseAuth.currentUser!.uid)
        .snapshots()
        .map((event) {
      return UserModel.fromSnap(event);
    });
  }

  //to check if the receiving user has blocked or not
  //if the sender is blocked it will return true else false
  Future<bool> checkMessageAllowed(String recieverUserId) async {
    return await _getBlockInfo(recieverUserId).then((value) {
      if (value.blockList.contains(globalFirebaseAuth.currentUser!.uid)) {
        log("blocked");
        return true;
      } else {
        log("noit blocked");
        return false;
      }
    });
  }

  //get online status
  Future<UserModel> _getBlockInfo(String receiverId) async {
    return await globalFirebaseFirestore
        .collection('users')
        .doc(receiverId)
        .get()
        .then((event) {
      return UserModel.fromSnap(event);
    });
  }

  void setTyping(String recieverUserId) async {
    // if (await checkMessageAllowed(recieverUserId))
    {
      await globalFirebaseFirestore
          .collection('users')
          .doc(recieverUserId)
          .collection('chats')
          .doc(globalFirebaseAuth.currentUser!.uid)
          .collection('messages')
          .doc(globalFirebaseAuth.currentUser!.uid)
          .set(Message(
            senderId: globalFirebaseAuth.currentUser!.uid,
            recieverid: recieverUserId,
            text: "/////TYPINGZK????",
            type: MessageEnum.text,
            timeSent: DateTime.now(),
            messageId: globalFirebaseAuth.currentUser!.uid,
            isSeen: false,
            repliedMessage: "",
            repliedTo: "",
            repliedMessageType: MessageEnum.text,
          ).toMap());
      log("Setting type");
    }
  }

  void stopTyping(String recieverUserId) async {
    await globalFirebaseFirestore
        .collection('users')
        .doc(recieverUserId)
        .collection('chats')
        .doc(globalFirebaseAuth.currentUser!.uid)
        .collection('messages')
        .doc(globalFirebaseAuth.currentUser!.uid)
        .delete();
  }

  void deleteSingleMessage(
      {required String recieverUserId, required String messageId}) async {
    //if it was the last message than delete the contact model
    await globalFirebaseFirestore
        .collection('users')
        .doc(globalFirebaseAuth.currentUser!.uid)
        .collection('chats')
        .doc(recieverUserId)
        .collection('messages')
        .get()
        .then((value) {
      if (value.docs.length == 1) {
        //if there is only one message there than delete the contact model
        deleteContactMessage(recieverUserId);
      } else {
        updateContactMessage(value, messageId, recieverUserId);
      }
    });
  }

  void updateContactMessage(
      QuerySnapshot value, String messageId, String recieverUserId) async {
    //firstly getting the message reference
    await globalFirebaseFirestore
        .collection('users')
        .doc(globalFirebaseAuth.currentUser!.uid)
        .collection('chats')
        .doc(recieverUserId)
        .collection('messages')
        .doc(messageId)
        .delete();

//going to the contact model and checking if the deleted message was the last message
//if it was the last message than update the contact model

    ChatContactModel? contactModel;
    Message? sendableMessage;
    await globalFirebaseFirestore
        .collection('users')
        .doc(globalFirebaseAuth.currentUser!.uid)
        .collection('chats')
        .doc(recieverUserId)
        .get()
        .then((value) async {
      contactModel = ChatContactModel.fromMap(value.data()!);
      if (contactModel!.lastMessageId == messageId) {
        await globalFirebaseFirestore
            .collection('users')
            .doc(globalFirebaseAuth.currentUser!.uid)
            .collection('chats')
            .doc(recieverUserId)
            .collection('messages')
            .orderBy('timeSent', descending: true)
            .get()
            .then((value) {
          // DateTime time=DateTime();
          // value.docs.forEach((element) {
          // var message = Message.fromMap(element.data());
          //   if (message.timeSent.isAfter(time!)) {
          //     sendableMessage = message;
          //   }
          var message = Message.fromMap(value.docs[0].data());
          sendableMessage = message;
        });
        String contactMsg;
        switch (sendableMessage!.type) {
          case MessageEnum.text:
            contactMsg = sendableMessage!.text;
            break;
          case MessageEnum.image:
            contactMsg = '📷 Photo';
            break;
          case MessageEnum.video:
            contactMsg = '📸 Video';
            break;
          case MessageEnum.audio:
            contactMsg = '🎵 Audio';
            break;
          case MessageEnum.link:
            contactMsg = sendableMessage!.text;
            break;
          case MessageEnum.file:
            contactMsg = sendableMessage!.text
                .substring(0, sendableMessage!.text.indexOf("@@@"));
            break;
          default:
            contactMsg = 'GIF';
        }

        _saveContactMessageAfterDeletion(contactMsg, sendableMessage!.timeSent,
            sendableMessage!.messageId, recieverUserId);
      }
      // });
      // }
    });
  }

// streams
  Future<List<UserModel>> getMembersOfGroup(String id) {
    List<UserModel> contactUsers = [];

    return globalFirebaseFirestore
        .collection('groups')
        .doc(id)
        .get()
        .then((event) async {
      // log(event.docs[0].data().toString());
      try {
        var userVal = Group.fromMap(event.data()!);
        for (var element in userVal.membersUid) {
          // if (element != globalFirebaseAuth.currentUser!.uid) {
          contactUsers.add(await getUserInfo(element));
          // }
        }
      } catch (e) {
        log(e.toString());
      }

      return contactUsers;
    });
  }

  Future<UserModel> getUserInfo(String id) async {
    return globalFirebaseFirestore
        .collection('users')
        .doc(id)
        .get()
        .then((value) {
      return UserModel.fromSnap(value);
    });
  }

  void deleteContactMessage(String recieverUserId) async {
    var ref = globalFirebaseFirestore
        .collection('users')
        .doc(globalFirebaseAuth.currentUser!.uid)
        .collection('chats')
        .doc(recieverUserId);

    //deleting the subcollections
    ref.collection("messages").get().then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        doc.reference.delete();
      });
    });
    ref.delete();
    // doc.update(
    //   {"showStatus": false},
    // );
  }

  void setChatMessageSeen(
    String recieverUserId,
    String messageId,
  ) async {
    try {
      await globalFirebaseFirestore
          .collection('users')
          .doc(globalFirebaseAuth.currentUser!.uid)
          .collection('chats')
          .doc(recieverUserId)
          .collection('messages')
          .doc(messageId)
          .update({'isSeen': true});

      await globalFirebaseFirestore
          .collection('users')
          .doc(globalFirebaseAuth.currentUser!.uid)
          .collection('chats')
          .doc(recieverUserId)
          .update({'isSeen': true});

      await globalFirebaseFirestore
          .collection('users')
          .doc(recieverUserId)
          .collection('chats')
          .doc(globalFirebaseAuth.currentUser!.uid)
          .collection('messages')
          .doc(messageId)
          .update({'isSeen': true});

      await globalFirebaseFirestore
          .collection('users')
          .doc(recieverUserId)
          .collection('chats')
          .doc(globalFirebaseAuth.currentUser!.uid)
          .update({'isSeen': true});
    } catch (e) {
      // showSnackBar(context: context, content: e.toString());
    }
  }

  void setChatContactMessageSeen(
      String recieverUserId, bool isGroupChat) async {
    if (isGroupChat) {
      try {
        await globalFirebaseFirestore
            .collection('groups')
            .doc(recieverUserId)
            .update({
          'isSeen': FieldValue.arrayUnion([globalFirebaseAuth.currentUser!.uid])
        });
      } catch (e) {}
    } else {
      try {
        await globalFirebaseFirestore
            .collection('users')
            .doc(globalFirebaseAuth.currentUser!.uid)
            .collection('chats')
            .doc(recieverUserId)
            .update({'isSeen': true});

        await globalFirebaseFirestore
            .collection('users')
            .doc(recieverUserId)
            .collection('chats')
            .doc(globalFirebaseAuth.currentUser!.uid)
            .update({'isSeen': true});
      } catch (e) {
        // showSnackBar(context: context, content: e.toString());
      }
    }
  }

  blockUnblockUser(String receiverUid) async {
    var ref = globalFirebaseFirestore
        .collection("users")
        .doc(globalFirebaseAuth.currentUser?.uid);

    DocumentSnapshot snapshot = await ref.get();
    if ((snapshot.data()! as dynamic)['blockList'].contains(receiverUid)) {
      await ref.update({
        'blockList': FieldValue.arrayRemove([receiverUid]),
      });
    } else {
      await ref.update({
        'blockList': FieldValue.arrayUnion([receiverUid]),
      });
    }
  }

  leaveGroup(String groupId) async {
    var ref = globalFirebaseFirestore.collection("groups").doc(groupId);
    DocumentSnapshot snapshot = await ref.get();
    if ((snapshot.data()! as dynamic)['membersUid']
        .contains(globalFirebaseAuth.currentUser!.uid)) {
      await ref.update({
        'membersUid':
            FieldValue.arrayRemove([globalFirebaseAuth.currentUser!.uid]),
      });
    }
  }

  void deleteMessageInGroup(
      {required String groupId, required String messageId}) async {
    //if it was the last message than delete the contact model

    var ref = globalFirebaseFirestore.collection('groups').doc(groupId);
    ref.collection('chats').get().then((value) {
      ref.update({
        'lastMessage': "...",
        'lastMessageBy': "..",
      });
    });
    await ref.collection('chats').doc(messageId).update({
      'isMessageDeleted':
          FieldValue.arrayUnion([globalFirebaseAuth.currentUser!.uid]),
    });
  }
}
