import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:tieba/Util.dart';
import 'package:tieba/network/dio_client.dart';
import 'package:tieba/network/dio_cookie_manager.dart';
import 'package:tieba/network/tieba_api_collection.dart';
import 'package:tieba/pages/thread_detail.dart';
import 'package:tieba/pages/tieba_login_page.dart';

class DrawerContent extends StatelessWidget {
  const DrawerContent({super.key});
  @override
  Widget build(BuildContext context) {
    final TextEditingController textEditingController = TextEditingController();
    return Column(
      children: [
        const MyDrawerHeader(),
        ListTile(
          title: const Text("测试接口"),
          onTap: () async {
            showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text("输入kz："),
                    content: EditableText(
                      controller: textEditingController,
                      focusNode: FocusNode(),
                      style: const TextStyle(color: Colors.black),
                      cursorColor: Colors.black,
                      backgroundCursorColor: Colors.black,
                    ),
                    actions: [
                      TextButton(
                          onPressed: () {
                            //log("value：${textEditingController.value.text}");
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return ThreadDetail(
                                  tid: textEditingController.value.text,
                                  barName: "");
                            }));
                          },
                          child: const Text("跳转"))
                    ],
                  );
                });
          },
        ),
        ListTile(
          title: const Text("刷新cookie"),
          onTap: () {
            showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text("刷新cookie"),
                    content: const Text(
                        "当cookie过期时，可能会无法发帖、获取关注的吧以及个性化推荐等等，点击确定可以重新获取cookie"),
                    actions: [
                      TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text("确认")),
                      TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text("取消")),
                    ],
                  );
                });
          },
        ),
        ListTile(
          title: const Text("关于"),
          onTap: () {
            showDialog(
                context: context,
                builder: (context) {
                  return AboutDialog(
                    applicationName: "贴吧Flutter",
                    applicationVersion: "1.0",
                    applicationIcon: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Image.asset("images/application_ic.png"),
                    ),
                    children: const [
                      Text("此应用使用Flutter构建"),
                      Text(
                        "开发者：不动の大音乐厅",
                        textDirection: TextDirection.rtl,
                        style: TextStyle(fontSize: 14,fontWeight: FontWeight.w600),
                      )
                    ],
                  );
                });
          },
        ),
        ListTile(
          title: const Text("消息测试"),
          onTap: (){
            showDialog(context: context, builder: (context)=>const AlertDialog(title:Text("Nothing To Do"),));
          },
        ),
      ],
    );
  }
}

class MyDrawerHeader extends StatefulWidget {
  const MyDrawerHeader({super.key});

  @override
  State<StatefulWidget> createState() => MyDrawerHeaderState();
}

class MyDrawerHeaderState extends State<StatefulWidget> {
  Map<String, String> userInfo = {"userName": '未登录', "userSig": "没有签名哦"};
  ImageProvider userAvatar = const AssetImage('images/akari.jpg');
  var onTapFunc = (BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return TiebaLoginPage();
    }));
    log("用户未登录");
  };
  var onUserAvatarTapFunc = () {
    log('点击用户头像');
  };
  MyDrawerHeaderState() {
    _checkLoginState().then((value) {
      if (value) {
        Util util = Util();
        userAvatar = NetworkImage(userAvatarPrefix +
            util.sessionMap["userData"]["data"]["user_portrait"]);
        userInfo = {
          "userName": util.sessionMap["userData"]["data"]["user_name_show"],
          "userSig": util.sessionMap["userData"]["data"]["mobilephone"]
        };
        onTapFunc = (BuildContext context) {
          log("什么都不做");
        };
        setState(() {});
        //TODO implement login stuff
      } else {
        log("用户未登录");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onTapFunc(context);
      },
      child: UserAccountsDrawerHeader(
          decoration: const BoxDecoration(
              image: DecorationImage(
                  fit: BoxFit.cover,
                  image: NetworkImage(
                      "https://img1.baidu.com/it/u=3155218111,2884938364&fm=253&fmt=auto&app=138&f=JPEG?w=889&h=500"))),
          accountName: Text(userInfo['userName']!),
          accountEmail: Text(userInfo['userSig']!),
          currentAccountPicture: GestureDetector(
            onTap: onUserAvatarTapFunc,
            child: CircleAvatar(
              radius: 50,
              backgroundImage: userAvatar,
            ),
          )),
    );
  }

  Future<bool> _checkLoginState() async {
    Util util = Util();
    var isLogin = util.sessionMap["isLogin"];
    if (isLogin == null) {
      DioClient dioClient = DioClient();
      String? userInfo =
          await dioClient.getInfo(uri: Uri.parse(tiebaUserInfoUrl));
      if (userInfo == null || userInfo == "null") {
        util.sessionMap.addAll({"isLogin": false});
        return false;
      }
      Map<String, dynamic> userInfoData = jsonDecode(userInfo);
      log(userInfoData.toString());
      util.sessionMap.addAll({"isLogin": true, "userData": userInfoData});
      return true;
    } else {
      return isLogin;
    }
  }
}
