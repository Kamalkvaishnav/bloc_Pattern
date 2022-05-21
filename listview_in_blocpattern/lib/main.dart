// ignore_for_file: avoid_print
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import './bloc/item_bloc/item_bloc.dart';
import './bloc/item_bloc/item_event.dart';
import './bloc/item_bloc/item_state.dart';
import './data/repositories/item_repository.dart';
import './ui/Item_Screen.dart';

import 'data/models/api_result_model.dart';

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        //In home, we are providing the bloc ItemBloc with ItemRepositoryImpl repository and as a child we are returning ItemScreen.
        home: BlocProvider(
          create: (context) => ItemBloc(
              repository:
              ItemRepositoryImpl()),
              child: ItemScreen(),),
        );
        
  }
}
