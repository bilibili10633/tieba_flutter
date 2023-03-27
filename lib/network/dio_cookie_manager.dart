import 'dart:developer';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:tieba/LocalStorage/local_storage.dart';
import 'package:tieba/network/tieba_api_collection.dart';



class MyCookieManager extends Interceptor{
  late LocalStorage _localStorage;
  late List<Cookie> _cookies;
  bool initialized=false;
  Future<void> init()async {
    if(!initialized){
      _localStorage=await LocalStorage.getInstance();
      String? cookieStr=_localStorage.getCookie();
      if(cookieStr==null||cookieStr==''){
        //第一次请求，先请求Cookie
        _cookies=[];
        HttpClient httpClient=HttpClient();
        var req=await httpClient.getUrl(Uri.parse(tiebaUrl));
        var res=await req.close();
        if(res.cookies.isNotEmpty){
          for(Cookie cookie in res.cookies){
            _cookies.add(cookie);
          }
        }
        _localStorage.setCookie(cookie:await cookieList2String(_cookies));
      }else{
        _cookies=await string2cookieList(cookieStr);
      }
      initialized=true;
    }
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler)async {
    String cookieStr="";
    cookieStr=await cookieList2String(_cookies);
    options.headers.addAll({
      "host":"  ",
      'access':"no",
      "user-agent":"bdtb for Android 12.24.1.0",
      'cookie':cookieStr
    });
    super.onRequest(options, handler);
  }
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    var setCookie=response.headers['set-cookie'];
    if(setCookie!=null){
      log("setCookie:$setCookie 长度${setCookie.length}");
    }
    if(setCookie!=null){
      for(String original in setCookie){
        var second =original.split("; ");
        var keyAndValue=second[0].split("=");
        for(int i=0;i<_cookies.length;i++){
          if(_cookies[i].name==keyAndValue[0]){
            _cookies.removeAt(i);
            break;
          }
        }
        _cookies.add(Cookie(keyAndValue[0], keyAndValue[1]));
      }
      log(_cookies.toString());
      cookieList2String(_cookies).then((value) {
        _localStorage.setCookie(cookie: value);
      });
    }
    //处理获取STOKEN
    if(response.isRedirect){
      log(response.headers.toString());
      var str =response.redirects[0].location.toString();
      log("重定向：$str");
      if(str.startsWith("https://tieba.baidu.com/index.html?errmsg=Auth+Login+Sucess&errno=0")){
        HttpClient httpClient = HttpClient();
        httpClient.getUrl(Uri.parse(str)).then((req)async {
          req.headers.add('cookie', await cookieList2String(_cookies));
          req.headers.host="     ";
          req.followRedirects=false;
          req.close().then((res){
            var setCookie=res.headers.value("set-cookie");
            if(setCookie!=null){
              log("设置Cookie：$setCookie");
              var list=setCookie.split("; ");
              var keyAndValue=list[0].split("=");
              _cookies.add(Cookie(keyAndValue[0], keyAndValue[1]));
              //写入STOKEN
              cookieList2String(_cookies).then((value) => _localStorage.setCookie(cookie: value));
            }
          } );
        });
      }
    }
    super.onResponse(response, handler);
  }
  /*
  从存储重新加载Cookie
  * */
  Future<void> reloadCookie()async{
    try{
      _cookies=await string2cookieList(_localStorage.getCookie()!);
    }catch(E){
      log("存储对象可能未初始化！");
    }
  }

  Future<String> getCookieFromStorage()async{
    _localStorage ??= await LocalStorage.getInstance();
    return _localStorage.getCookie()!;
  }

  static Future<List<Cookie>> string2cookieList(String readFromStorage) async {
    List<Cookie> cookies = [];
    var cookiePair = readFromStorage.split("; ");
    for (String item in cookiePair) {
      var cookieStr = item.split('=');
      if (cookieStr.length < 2) continue;
      String name = cookieStr[0], value = cookieStr[1];
      Cookie cookie = Cookie(name, value);
      cookies.add(cookie);
    }
    return cookies;
  }
/*
* 把Cookie转成String以便储存
* */
  static Future<String> cookieList2String(List<Cookie> cookies) async {
    String convert = "";
    for (var element in cookies) {
      convert += "${element.name}=${element.value}; ";
    }
    return convert;
  }
//获取Cookie
  Future<String?> getCookie({required String key})async{
    if(!initialized){
      await init();
    }
    for(var it in _cookies){
        if(it.name==key){
          return it.value;
        }
    }
    return null;
  }
}