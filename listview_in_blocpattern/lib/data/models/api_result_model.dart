
// This is the Model for ItemBloc
class FoodModel {
  int? responseCode;
  String? message;
  List<Data>? data;
  
  //Named constractor for FoodModel
  FoodModel({this.responseCode, this.message, this.data});
  
  //.fromJson Method is used when We want to get the data 
  FoodModel.fromJson(Map<String, dynamic> json) {
    responseCode = json['responseCode'];
    message = json['message'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(new Data.fromJson(v));
      });
    }
  }

  // toJson method is used when we need to send the data 
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['responseCode'] = this.responseCode;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

// This is the Data close to wrap the data array recieved from the API 
class Data {
  int? itemId;
  String? itemName;

  Data({this.itemId, this.itemName});

  Data.fromJson(Map<String, dynamic> json) {
    itemId = json['item_id'];
    itemName = json['item_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['item_id'] = this.itemId;
    data['item_name'] = this.itemName;
    return data;
  }
}
