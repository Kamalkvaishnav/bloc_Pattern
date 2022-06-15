//Constructor for token and message to be parametrized
import 'dart:convert';
import 'package:listview_in_blocpattern/data/models/Models.dart';
import 'package:http/http.dart' as http;
import '../../res/API.dart';

// Main class for the ItemRepository

abstract class ItemRepository {
  //getData is the function to get the data from the API, and return in the type of FoodModel
  Future<ApiResultModel> sendMessage(List token, String title, String body,
      String chatRoomID, dynamic senderToken, String SenderEmail);
}

//Subclass of the ItemRepository
class ItemRepositoryImpl implements ItemRepository {
  @override
  Future<ApiResultModel> sendMessage(List token, String title, String body,
      String chatRoomID, dynamic senderToken, String SenderEmail) async {
    Map? bodyforNotification;
    String key =
        'key=AAAAfIAwgFg:APA91bHs-PUH5lXteAK03p-srZHZWSuLOVVouhJXGv1Qv4NE-ySaEufvoyX2uhPCbM9rmr2mQVHQJ0XEYQ3CswwtCw0Jw-w81RVsBeoWUJ838t5fXke3F0P-j_NLYm4m8du9-ZOypYFb';

    if (token.length != 1) {
      token.remove(senderToken.toString());
      bodyforNotification = {
        "registration_ids": token,
        "content_available": true,
        "priority": "high",
        "notification": {
          "title": "Message for you in Group",
          "body": body,
          "click_action": "FLUTTER_NOTIFICATION_CLICK",
          "android_channel_id": "chatAppInFlutter"
        },
        "data": {
          "ChatRoomID": chatRoomID,
          "SenderToken": token,
          "Receiver": chatRoomID
        }
      };
    } else {
      bodyforNotification = {
        "to": token[0],
        "content_available": true,
        "priority": "high",
        "notification": {
          "title": "Message for you !!",
          "body": body,
          "click_action": "FLUTTER_NOTIFICATION_CLICK",
          "android_channel_id": "chatAppInFlutter"
        },
        "data": {
          "ChatRoomID": chatRoomID,
          "SenderToken": senderToken,
          "Receiver": SenderEmail
        }
      };
    }

    print(bodyforNotification);
    final response = await http.post(Uri.parse(AppStrings.apikey),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': key
        },
        body: jsonEncode(bodyforNotification));
    print(response.statusCode);

    if (response.statusCode == 200) {
      var Body = jsonDecode(response.body.toString());
      print(Body);
      if (Body['success'] >= 1) {
        return ApiResultModel.fromJson(Body);
      } else {
        throw Exception();
      }
    } else {
      throw Exception();
    }
  }
}
