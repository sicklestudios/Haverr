import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:haverr/models/chat_model.dart';
import 'package:haverr/models/group.dart';
import 'package:haverr/resources/chat_methods.dart';
import 'package:haverr/utils/utils.dart';
import 'package:intl/intl.dart';

class ChatContactsListScreen extends StatefulWidget {
  String value;
  ChatContactsListScreen({required this.value, super.key});

  @override
  State<ChatContactsListScreen> createState() => _ChatContactsListScreenState();
}

class _ChatContactsListScreenState extends State<ChatContactsListScreen> {
  bool isShown = false;
  String previousTime = "";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: const Text("Chat"),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 10.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              StreamBuilder<List<Group>>(
                  stream: ChatMethods().getChatGroups(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: Text(""),
                      );
                    }
                    List<Group> tempGroups = [];

                    tempGroups = [];
                    // if (snapshot.data == null) {
                    //   return getNewChatPrompt(context);
                    // }
                    if (widget.value != "") {
                      for (var element in snapshot.data!) {
                        if (element.name.contains(widget.value)) {
                          tempGroups.add(element);
                        }
                      }
                    } else {
                      tempGroups = snapshot.data!;
                    }
                    // if (temp.isEmpty) {
                    //   // return const Center(
                    //   //   child: Text("Nothing to show"),
                    //   // );
                    //   return getNewChatPrompt(context);
                    // }
                    return StreamBuilder<List<ChatContactModel>>(
                        stream: ChatMethods().getChatContacts(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          if (snapshot.data == null) {
                            return returnNothingToShow();
                          }
                          List temp = [...tempGroups];
                          if (widget.value != "") {
                            for (var element in snapshot.data!) {
                              if (element.name
                                  .toLowerCase()
                                  .contains(widget.value.toLowerCase())) {
                                temp.add(element);
                              }
                            }
                          } else {
                            temp += snapshot.data!;
                          }
                          if (temp.isEmpty) {
                            // return const Center(
                            //   child: Text("Nothing to show"),
                            // );
                            return returnNothingToShow();
                          }

                          // sorting the chats list
                          temp.sort((a, b) {
                            var adate;
                            var bdate;
                            try {
                              ChatContactModel model1 = a;
                              adate = model1.timeSent;
                            } catch (e) {
                              Group group1 = a;
                              adate = group1.timeSent;
                            }
                            try {
                              ChatContactModel model2 = b;
                              bdate = model2.timeSent;
                            } catch (e) {
                              Group group2 = b;
                              bdate = group2.timeSent;
                            }

                            return adate.compareTo(bdate);
                          });
                          temp = temp.reversed.toList();

                          return ListView.builder(
                              itemCount: temp.length,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemBuilder: ((context, index) {
                                var data = temp[index];

                                //getting the dates
                                var dateInList = DateFormat.MMMMEEEEd()
                                    .format(data.timeSent);
                                if (previousTime != dateInList) {
                                  previousTime = dateInList;
                                  isShown = false;
                                } else {
                                  isShown = true;
                                }
                                try {
                                  ChatContactModel model = data;
                                  return Column(
                                    children: [
                                      if (!isShown)
                                        getDateWithLines(dateInList),
                                      getMessageCard(model, context)
                                    ],
                                  );
                                } catch (e) {
                                  Group group = data;
                                  return Column(
                                    children: [
                                      if (!isShown)
                                        getDateWithLines(dateInList),
                                      getMessageCard(group, context,
                                          isGroupChat: true)
                                    ],
                                  );
                                }
                                // log((data == Group).toString());
                              }));
                        });
                  }),
            ],
          ),
        ),
      ),
    );
  }
  //showing the time
}

// ListView.builder(
//                       itemCount: temp.length,
//                       shrinkWrap: true,
//                       physics: const NeverScrollableScrollPhysics(),
//                       itemBuilder: ((context, index) {
//                         var data = temp[index];
//                         return getMessageCard(data, context, isGroupChat: true);
//                       }));

 