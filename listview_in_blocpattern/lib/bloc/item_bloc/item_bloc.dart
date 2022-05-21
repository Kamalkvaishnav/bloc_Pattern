import 'package:bloc/bloc.dart';

import '/bloc/item_bloc/item_event.dart';
import '/bloc/item_bloc/item_state.dart';
import '/data/repositories/item_repository.dart';

import '../../data/models/api_result_model.dart';

class ItemBloc extends Bloc<ItemEvent, ItemState> {
  //Initalizing the ItemRepository as repository for our Bloc
  late ItemRepository repository;

  @override
  ItemState get initialState => ItemInitialState();
  //Constructor for ItemBloc
  ItemBloc({required this.repository}) : super(ItemInitialState()) {

    //On fuction reads the Event and return the corresponding States using emit
    on<FetchItemEvent>((event, emit) async {
      emit(ItemLoadingState());
      try {
        FoodModel items = await repository.getData();
        emit(ItemLoadedState(items: items));
      } catch (e) {
        emit(ItemErrorState(message: e.toString()));
      }
    });
  }
}
