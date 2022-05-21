import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/item_bloc/item_event.dart';

import '../bloc/item_bloc/item_bloc.dart';
import '../bloc/item_bloc/item_state.dart';
import '../data/models/api_result_model.dart';

class ItemScreen extends StatefulWidget {
  const ItemScreen({Key? key}) : super(key: key);

  @override
  State<ItemScreen> createState() => _ItemScreenState();
}

class _ItemScreenState extends State<ItemScreen> {
  //here we are callinfg  our bloc 
  late ItemBloc itemBloc;
  //decearing fooItems as an empty array which will be used in ItemLoadedState to store the data.
  List<Data> fooditems = [];

  @override
  void initState() {
    super.initState();
    itemBloc = BlocProvider.of<ItemBloc>(context);
    //We are adding FetchItemEvent in our ItemBloc
    itemBloc.add(FetchItemEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Foods'),
      ),
      body: Container(
        //BlocListener is listing the states the and not returning anything 
        child: BlocListener<ItemBloc, ItemState>(
          listener: (context, state) => {
            if (state is ItemErrorState) {Text("Something went wrong :(")}
          },

          //BlocBuilder is building the widgets and returning according the state.
          child: BlocBuilder<ItemBloc, ItemState>(
            builder: (context, ItemState state) {
              if (state is ItemErrorState) {
                final error = state.message;
                String ErrorMessage = "${error}\n, Try again.";
                return Text(ErrorMessage);
              }
              if (state is ItemLoadingState) {
                return  Container(
                margin: EdgeInsets.all(20),
                child: Column(
                
                  mainAxisAlignment: MainAxisAlignment.center,
                  
                  children: [SizedBox(width: MediaQuery.of(context).size.width ,) ,CircularProgressIndicator(
                  backgroundColor: Colors.grey,
                  color: Colors.purple,
                  strokeWidth: 5,
                  ),
                ]),
              );
              }
              if (state is ItemLoadedState) {
                fooditems = state.items.data!;
                return ListView.builder(
                    itemCount: fooditems.length,
                    itemBuilder: (context, index) {
                      return Card(
                        child: ListTile(
                            onTap: () {
                              print(fooditems[index].itemName);
                            },
                            title: Text("${fooditems[index].itemName}"),
                            leading: Text("${fooditems[index].itemId}")),
                      );
                    });
              }
              return Container();
            },
          ),
        ),
      ),
    );
  }
}
