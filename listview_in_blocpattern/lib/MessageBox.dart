import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:listview_in_blocpattern/blocs/item_state.dart';
import 'package:listview_in_blocpattern/data/models/Models.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:listview_in_blocpattern/database_manager.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'blocs/item_blocs.dart';
import 'blocs/item_events.dart';

class MessageBox extends StatefulWidget {
  String token;
  MessageBox({required this.token});
  @override
  State<MessageBox> createState() => _MessageBoxState();
}

final TextEditingController msgController = TextEditingController();

class _MessageBoxState extends State<MessageBox> {
  List Messages = [];
  late ItemBloc itemBloc;

  List<Results> fooditems = [];

  @override
  void initState() {
    fetchMessages();
    super.initState();
    itemBloc = BlocProvider.of<ItemBloc>(context);
  }

  fetchMessages() async {
    dynamic result = await DatabaseManager().fetchMessages();
    if (result == null) {
      print('Error in retriving UserData');
    } else {
      setState(() {
        Messages = result;
      });
      print(Messages.length);
      return Messages;
    }
  }

  _sendMessageArea(dynamic SenderUID, String token) {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        height: 70,
        color: Colors.white,
        child: Row(
          children: <Widget>[
            Expanded(
              child: TextField(
                controller: msgController,
                decoration: const InputDecoration.collapsed(
                    hintText: "Write message...",
                    hintStyle: TextStyle(color: Colors.black54),
                    border: InputBorder.none),
                textCapitalization: TextCapitalization.sentences,
              ),
            ),
            const SizedBox(
              width: 15,
            ),
            FloatingActionButton(
              onPressed: () {
                int timedata = DateTime.now().millisecondsSinceEpoch;
                DatabaseManager().createMessage(
                    timedata, SenderUID, token, msgController.text.trim());
                //We are adding FetchItemEvent in our ItemBloc
                itemBloc.add(SendMessage(
                    token: widget.token,
                    title: 'You got new Message',
                    body: msgController.text.trim()));
                    msgController.clear();
                    fetchMessages();
              },
              backgroundColor: Colors.blue,
              elevation: 0,
              child: const Icon(
                Icons.send,
                color: Colors.white,
                size: 18,
              ),
            ),
          ],
        ));
  }

  @override
  Widget build(BuildContext context) {
    final SenderUID = context.read<User>().uid;

    return Scaffold(
        appBar: AppBar(
          backgroundColor: Color.fromARGB(255, 112, 121, 181),
          title: const ListTile(
            title: Text("Receiver"),
            leading:
                CircleAvatar(backgroundImage: AssetImage('assets/avatar1.png')),
          ),
        ),
        resizeToAvoidBottomInset: true,
        body: BlocListener<ItemBloc, ItemState>(
          listener: (context, state) => {
            if (state is ItemErrorState) {Text("Something went wrong :(")}
          },
          child: BlocBuilder<ItemBloc, ItemState>(
            builder: (context, state) {
              if (state is ItemErrorState) {
                final error = state.message;
                String ErrorMessage = "${error}\n, Try again.";

                return Text(ErrorMessage);
              }
              if (state is ItemLoadingState) {
                return Container(
                  margin: EdgeInsets.all(20),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width,
                        ),
                        CircularProgressIndicator(
                          backgroundColor: Colors.grey,
                          color: Colors.purple,
                          strokeWidth: 5,
                        ),
                      ]),
                );
              }
              if (state is ItemLoadedState) {
                fooditems = state.items.results!;
                Fluttertoast.showToast(
                    msg: "Message sent!", // message
                    toastLength: Toast.LENGTH_SHORT, // length
                    gravity: ToastGravity.CENTER, // location
                    timeInSecForIosWeb: 1 // duration
                    );
                print('You send a message to user!');
              }
              return Column(children: <Widget>[
                Expanded(
                  child: ListView.builder(
                    itemCount: Messages.length,
                    shrinkWrap: true,
                    reverse: true,
                    padding: const EdgeInsets.only(top: 10, bottom: 10),
                    // physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      return Container(
                        padding: const EdgeInsets.only(
                            left: 14, right: 14, top: 10, bottom: 10),
                        child: Align(
                          alignment:
                              (Messages[index]['receiver_token'] != widget.token
                                  ? Alignment.topLeft
                                  : Alignment.topRight),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: (Messages[index]['receiver_token'] !=
                                      widget.token
                                  ? Colors.grey.shade200
                                  : Colors.blue[200]),
                            ),
                            padding: EdgeInsets.all(16),
                            child: Text(
                              Messages.length > 0
                                  ? Messages[index]['Message']
                                  : 'No messages yet',
                              style: TextStyle(fontSize: 15),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                _sendMessageArea(SenderUID, widget.token),
              ]);
              ;
            },
          ),
        ));
  }
}