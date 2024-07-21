import 'dart:convert';
import 'dart:developer';

import 'package:tieba/network/dio_client.dart';
import 'package:tieba/network/tieba_api_collection.dart';

class TiebaApi {
  static DioClient dioClient=DioClient();
  static getUserThreads(String username)async{
    var resp=await dioClient.getInfo(uri: Uri.parse("$profile?un=$username&pn=1&ie=utf8"),useClientUA: false);
    log(resp??"aa");
  }
  static getUserInfo(String username)async{

  }
}