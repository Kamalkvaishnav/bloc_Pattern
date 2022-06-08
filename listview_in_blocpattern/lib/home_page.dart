import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:listview_in_blocpattern/auth_service.dart';
import 'package:listview_in_blocpattern/chatList.dart';
import 'package:listview_in_blocpattern/database_manager.dart';
import 'package:listview_in_blocpattern/multiselect.dart';
import 'package:listview_in_blocpattern/userModel.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List Users = [];
  List<dynamic> groups = [];
  List<String> userEmails = [];
  String currUserEmail = '';

  @override
  void initState() {
    fetchuserInfo();
    fetchGroupList();
    super.initState();
  }

  fetchGroupList() async {
    dynamic resultGroups = await DatabaseManager().fetchGroupList();
    if (resultGroups == null) {
      print('Error in retriving UserData');
    } else {
      setState(() {
        groups = resultGroups;
      });
      print(groups.length);
    }
    print(groups);
    return groups;
  }

  fetchuserInfo() async {
    dynamic resultUsers = await DatabaseManager().fetchUserList();
    if (resultUsers == null) {
      print('Error in retriving UserData');
    } else {
      setState(() {
        Users = resultUsers;
      });
      print(Users.length);
    }
    for (int i = 0; i < Users.length; i++) {
      print(Users[i]['Email']);
      if (currUserEmail == Users[i]['Email']) {
        continue;
      } else {
        setState(() {
          userEmails.add(Users[i]['Email']);
        });
      }
    }
    print('This is userEmails' + userEmails.toString());
    return Users;
  }

  @override
  Widget build(BuildContext context) {
    UserModel? user =
        UserModel(context.read<User>().email!, context.read<User>().uid);
    currUserEmail = user.email;

    return Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(user.email),
              ElevatedButton(
                  style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all(Colors.blueGrey)),
                  onPressed: (() {
                    Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                            builder: (BuildContext context) => MultiSelect(
                                  senderUID: user.email,
                                  userEmails: userEmails,
                                  
                                )));
                  }),
                  child: Text('+ Grp')),
              ElevatedButton(
                  style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all(Colors.blueGrey)),
                  onPressed: (() {
                    context.read<AuthService>().signOut();
                  }),
                  child: Text('Log out'))
            ],
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ListView.builder(
                itemCount: Users.length,
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                padding: EdgeInsets.only(top: 16),
                itemBuilder: (context, index) {
                  return (currUserEmail == Users[index]['Email'])
                      ? Container()
                      : ChatList(
                          imageUrl: 'assets/avatar1.png',
                          date: '10/05',
                          receieverTokens: Users[index]['Token'],
                          // usertoken: user.
                          //ChatroomId
                          chatroomId:
                              // getChatRoomId(user.uId!, Users[index]['uID']),
                              getChatRoomId(user.email, Users[index]['Email']),
                          sender: user.email,
                          receiver: Users[index]['Email']);
                },
              ),
              ListView.builder(
                itemCount: groups.length,
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                padding: EdgeInsets.only(top: 16),
                itemBuilder: (context, index) {
                  return ChatList(
                      imageUrl: 'assets/group.png',
                      date: '10/05',
                      receieverTokens: groups[index]['receiver_token'],
                      // usertoken: user.
                      //ChatroomId
                      chatroomId: groups[index]['group_name'],
                      sender: groups[index]['admin_uID'],
                      receiver: groups[index]['group_name']);
                },
              ),
            ],
          ),
        ));
  }
}

//Forfinding The chatroom Id
getChatRoomId(String a, String b) {
  for (int i = 0; i < min(a.length, b.length); i++) {
    int x = a[i].compareTo(b[i]);
    if (x > 0) {
      return "$b\_$a";
    } else if (x < 0) {
      return "$a\_$b";
    }
  }
  // if (a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)) {
  //   return "$b\_$a";
  // } else if (a.substring(0, 1).codeUnitAt(0) <b.substring(0, 1).codeUnitAt(0)) {
  //   return "$a\_$b";
  // } else {
  //  return getChatRoomId(a.substring(1, a.length - 1), b.substring(1, b.length - 1));
  // }
}
