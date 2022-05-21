import '/res/strings.dart';
import 'dart:convert';
import '../models/api_result_model.dart';
import 'package:http/http.dart' as http;

// Main class for the ItemRepository
abstract class ItemRepository {
  //getData is the function to get the data from the API, and return in the type of FoodModel
  Future<FoodModel> getData();
}

//Subclass of the ItemRepository
class ItemRepositoryImpl implements ItemRepository {
  @override
  Future<FoodModel> getData() async {
    //calling the response from the API link with help if http request
    var response = await http.get(Uri.parse(AppStrings.foodApiUrl));
    if (response.statusCode == 200) {
      //Decoding the body of response into Json
      var result = await json.decode(response.body);
      return FoodModel.fromJson(result);
    }
    throw UnimplementedError();
  }
}
