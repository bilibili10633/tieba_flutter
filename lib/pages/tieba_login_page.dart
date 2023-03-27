import 'dart:developer';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:tieba/LocalStorage/local_storage.dart' as mystorage;
import 'package:flutter/material.dart';
import 'package:tieba/network/dio_client.dart';
import 'package:tieba/network/tieba_api_collection.dart';

class TiebaLoginPage extends StatelessWidget {
  TiebaLoginPage({super.key}) ;
  final CookieManager cookieManager=CookieManager.instance();
  bool flag=false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("登录"),
      ),
      body: InAppWebView(

        initialUrlRequest:
            URLRequest(url: Uri.parse("https://passport.baidu.com")),
        onLoadStop: (controller,url)async{
          mystorage.LocalStorage ls=await mystorage.LocalStorage.getInstance();
          Uri p=Uri.parse("https://passport.baidu.com");
          Uri tb=Uri.parse("https://tieba.baidu.com");
          //log("PTOKEN:::::${await cookieManager.getCookie(url: p,name:"PTOKEN")}");
          Cookie? ptoken=await cookieManager.getCookie(url: p,name:"PTOKEN");
          List<Cookie?> cookies=[];
          if(ptoken!=null){
            log("获取PToken成功: ${ptoken.toString()}");
            cookies.add(ptoken);
            cookies.add(await cookieManager.getCookie(url: p, name:"BDUSS"));
            await ls.setCookie(cookie: await _cookieList2String(cookies));

            //再加载一次Cookie
            DioClient().cookieManager.reloadCookie();
            //认证并获取STOKEN，这样才能访问关注的贴吧
            await DioClient().getInfo(uri: Uri.parse(tiebaAuthURL)).catchError((error){
              showDialog(context: context, builder: (context){
                return  AlertDialog(
                  title: const Text("触发了百度CAPTCHA，请过一段时间再试"),
                  icon: const Icon(Icons.error_outline),
                  actions: [
                    TextButton(onPressed: (){
                        Navigator.pop(context);
                    }, child:const Text("好的"))
                  ],
                );
              });
            });
            Navigator.pop(context);
            if(!flag){
              flag=true;
              controller.evaluateJavascript(source: "document.location=\"http://passport.baidu.com/v3/login/api/auth/?tpl=tb&jump=&return_type=3&u=https%3A%2F%2Ftieba.baidu.com%2Findex.html\"");
            }
          }
          },
        onTitleChanged: (controller,title)async{
          log("当前标题：$title");
          if(title!.contains("管理我喜欢的吧_百度贴吧")){
            log(await _cookieList2String(await cookieManager.getCookies(url: Uri.parse("passport.baidu.com"))));
          }
        },
      ),
    );
  }

  Future<String> _cookieList2String(List<Cookie?> cookies)async{
    String convert="";
    for (var element in cookies) {
      convert+="${element?.name}=${element?.value}; ";
    }
    return convert;
  }
}
