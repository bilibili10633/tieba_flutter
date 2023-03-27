import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter_gbk2utf8/flutter_gbk2utf8.dart';
import 'package:tieba/network/dio_cookie_manager.dart';
import 'package:tieba/network/tieba_api_collection.dart';



class DioClient {
  final Dio _dio = Dio();
  final HttpClient _httpClient = HttpClient();
  late final MyCookieManager cookieManager;
  //http://tieba.baidu.com/mg/o/getRecommPage?load_type=1&page_thread_count=50
  DioClient._privateConstructor() {
    cookieManager = MyCookieManager();
    _dio.interceptors.add(cookieManager);
  }
  static final DioClient _instance = DioClient._privateConstructor();
  factory DioClient() {
    return _instance;
  }
  Future<String?> getInfo({required Uri uri}) async {
    if (!cookieManager.initialized) {
      await cookieManager.init();
    }
    //获取存储对象
    Response data =await _dio.getUri(uri, options: Options(followRedirects: true)).onError((error, stackTrace)async{
      Future<Response<dynamic>> dd=Future(() => Response(requestOptions: RequestOptions()));  
      return dd;
    });
    return data.toString();
  }

  Future<String> getFollowedForum({required Uri uri}) async {
    var req = await _httpClient.getUrl(uri);
    req.headers.add("cookie", await cookieManager.getCookieFromStorage());
    req.headers.removeAll("host");
    var res = await req.close();
    var list = await res.toList();
    //log(list.toString());
    return gbk.decode(list[0]);
  }

  Future<String> universalPost(PostBodyType body, Uri uri) async {
    var response = await _dio.postUri(
      uri,
      options: Options(
        headers: {
          'cookie': "ka=open",
          "User-Agent": "bdtb for Android 12.24.1.0",
          'connection': 'close',
          "Accept-Encoding": "gzip",
        },
        contentType: Headers.formUrlEncodedContentType,
      ),
      data: body.toString(),
    );
    return response.data.toString();
  }
}

class PostBodyType {
  final List<UrlKeyAndValue> requestContent;
  PostBodyType(this.requestContent) {
    requestContent
        .add(UrlKeyAndValue(key: "_client_version", value: "12.24.1.0"));
    requestContent
        .add(UrlKeyAndValue(key: "phone_imei", value: "000000000000000"));
  }
  String _autoSignWithMD5() {
    /*
      * 需要排序后再使用MD5加密
      * */
    requestContent.sort((a, b) {
      return a.key.codeUnitAt(0) - b.key.codeUnitAt(0);
    });

    String waitForSign = "";
    for (var it in requestContent) {
      waitForSign += "${it.key}=${it.value}";
    }
    waitForSign += appSecret;
    const Utf8Encoder e = Utf8Encoder();
    var encoded = e.convert(waitForSign);
    var sign = md5.convert(encoded).toString().toUpperCase();

    String result = "";
    for (var it in requestContent) {
      result += it.toString();
    }
    result += "sign=$sign";
    return result;
  }

  @override
  String toString() {
    return _autoSignWithMD5();
  }
}

class UrlKeyAndValue {
  final String key, value;
  UrlKeyAndValue({required this.key, required this.value});
  @override
  String toString() {
    return "$key=$value&";
  }
}
