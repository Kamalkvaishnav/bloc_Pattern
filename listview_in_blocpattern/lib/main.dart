import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:listview_in_blocpattern/MessageBox.dart';
import 'package:listview_in_blocpattern/auth_service.dart';
import 'package:listview_in_blocpattern/database_manager.dart';
import 'package:listview_in_blocpattern/home_page.dart';
import 'package:listview_in_blocpattern/signin.dart';
import 'package:provider/provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'blocs/item_blocs.dart';
import 'data/repository/item_repo.dart';
import 'notification_setvice/local_notification.dart';

Future<void> backgroundHandler(RemoteMessage message) async {
  print(message.data.toString());
  print(message.notification!.title);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(backgroundHandler);
  LocalNotificationService.initialize();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthService>(
            create: (context) => AuthService(FirebaseAuth.instance)),
        StreamProvider(
          create: (context) => context.read<AuthService>().authStateChanges,
          initialData: null,
        )
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Chat App',
        theme: ThemeData(
            primarySwatch: Colors.blue,
            visualDensity: VisualDensity.adaptivePlatformDensity),
        home: const AuthanticationWrapper(),
      ),
    );
  }
}

class AuthanticationWrapper extends StatefulWidget {
  const AuthanticationWrapper({Key? key}) : super(key: key);

  @override
  State<AuthanticationWrapper> createState() => _AuthanticationWrapperState();
}

class _AuthanticationWrapperState extends State<AuthanticationWrapper> {
  List<String> userToken = [];

  @override
  void initState() {
    SendToken();
    super.initState();

    // 1. This method call when app in terminated state and you get a notification
    // when you click on notification app open from terminated state and you can get notification data in this method

    FirebaseMessaging.instance.getInitialMessage().then(
      (message) {
        print("FirebaseMessaging.instance.getInitialMessage");
        if (message != null) {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => BlocProvider(
                  create: (context) =>
                      ItemBloc(repository: ItemRepositoryImpl()),
                  child: MessageBox(
                    //this token is users token
                    token: jsonDecode(message.data['SenderToken']),
                    chatroomID: message.data['ChatRoomID'],
                    receiver: message.data['Receiver'],
                  ))));
        }
      },
    );

    // 2. This method only call when App in forground it mean app must be opened
    FirebaseMessaging.onMessage.listen(
      (message) {
        print("FirebaseMessaging.onMessage.listen");
        if (message.notification != null) {
          print(message.notification!.title);
          print(message.notification!.body);
          print("message.data11 ${message.data}");
          LocalNotificationService.createanddisplaynotification(message);
        }
        if (message != null) {
          print(message.data['ChatRoomID']);
          print(message.data['Receiver']);
          print(jsonDecode(message.data['SenderToken']));

          Navigator.push(context, MaterialPageRoute(
              builder: (context) => BlocProvider(
                  create: (context) =>
                      ItemBloc(repository: ItemRepositoryImpl()),
                  child: MessageBox(
                    //this token is users token
                    token: jsonDecode(message.data['SenderToken']),
                    chatroomID: message.data['ChatRoomID'],
                    receiver: message.data['Receiver'],
                  ))));
        }
      },
    );

    // 3. This method only call when App in background and not terminated(not closed)
    FirebaseMessaging.onMessageOpenedApp.listen(
      (message) {
        print("FirebaseMessaging.onMessageOpenedApp.listen");
        if (message.notification != null) {
          print(message.notification!.title);
          print(message.notification!.body);
          print("message.data22 ${message.data['ChatRoomID']}");
        }
        if (message != null) {
          print(message.data['SenderToken']);
          print(message.data['ChatRoomID']);
          print(message.data['Receiver']);

          Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (context) => BlocProvider(
                      create: (context) =>
                          ItemBloc(repository: ItemRepositoryImpl()),
                      child: MessageBox(
                        //this token is users token
                        token: jsonDecode(message.data['SenderToken']),
                        chatroomID: message.data['ChatRoomID'],
                        receiver: message.data['Receiver'],
                      ))));
        }
      },
    );
  }

  SendToken() async {
    await FirebaseMessaging.instance.getToken().then((value) {
      setState(() {
        userToken.add(value!);
      });
      return userToken;
    });
  }

  @override
  Widget build(BuildContext context) {
    final appuser = context.watch<User?>();

    if (appuser != null) {
      DatabaseManager().createuser(appuser.email!, appuser.uid, userToken);

      return const HomePage();
    } else {
      return const SignInPage();
    }
  }
}
