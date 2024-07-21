import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tieba/main.dart';

import 'package:tieba/network/dio_client.dart';
import 'package:tieba/network/tieba_api_collection.dart';
import 'package:tieba/Util.dart';
import 'package:tieba/pages/forum_pages/enter_forum.dart';

import '../widgets/forum_level.dart';

class ForumListPage extends StatefulWidget {
  const ForumListPage({super.key});


  @override
  State<StatefulWidget> createState() => ForumListPageState();
}

GlobalKey gdKey = GlobalKey();

class ForumListPageState extends State<StatefulWidget>{
  List<Widget> list = [
    const GridTile(
      child: Text("正在加载"),
    )
  ];

  void initAll(){
    _getAllFollowedForum().then((all) {
      List<Widget> allWidget = [];
      for (Map<String, String> forumInfo in all) {
        allWidget.add(GridTile(
            child: Ink(
              decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  border: Border.all(width:useMd3.flag?1:0,color: Util.isDarkMode(context)?const Color(0xff666666):const Color(0xff222222)),
                  color: Util.isDarkMode(context)?const Color(0xff1E1F22):const Color(0xffffffff)
              ),
              child: InkWell(
                borderRadius: const BorderRadius.all(Radius.circular(10)),
                onTap: () {
                  Navigator.of(context).push(CupertinoPageRoute(builder: (context){
                    return Scaffold(
                      appBar: AppBar(
                        foregroundColor: tiebaMainThemeColor,
                        // backgroundColor: const Color(0xffffffff),
                        shadowColor: const Color(0x00000000),
                        title: Text("${forumInfo["forumName"]}吧",style: const TextStyle(color: tiebaMainThemeColor),),
                      ),
                      body: ForumPage(forumName: forumInfo["forumName"],),
                    );
                  }));
                  log("tap事件");
                },
                child: Stack(
                  children: [
                    Positioned(
                        top: (gdKey.currentContext?.size?.width ?? 300) /
                            2 *
                            (0.2 / 1) *
                            0.19,
                        left: (gdKey.currentContext?.size?.width ?? 300) /
                            2 *
                            (0.2 / 1) +
                            20,
                        child: Text(forumInfo["forumName"]!)),
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: SizedBox.square(
                              dimension:
                              (gdKey.currentContext?.size?.width ?? 300) /
                                  2 *
                                  (0.2 / 1),
                              child: Image.network(
                                forumInfo["forumAvatar"]!,
                                fit: BoxFit.cover,
                              )),
                        ),
                      ),
                    ),
                    Positioned(
                        bottom: (gdKey.currentContext?.size?.width ?? 300) /
                            2 *
                            (0.2 / 1) *
                            0.19,
                        left: (gdKey.currentContext?.size?.width ?? 300) /
                            2 *
                            (0.2 / 1) +
                            20,
                        child: ForumLevelWidget(level: int.parse(forumInfo['level']!),))
                  ],
                ),
              ),
            )
        ));
      }
      setState(() {list = allWidget;});
    });
  }

  @override
  Widget build(BuildContext context) {
    initAll();
    return Stack(
      children: [
        SizedBox(
            width: Util().devWidth,
            height: Util().devHeight - 80,
            child: GridView.builder(
                key: gdKey,
                padding: const EdgeInsets.only(top: 12, left: 12, right: 12),
                itemCount: list.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1 / 0.3,
                ),
                itemBuilder: (context, index) {
                  return list[index];
                }))
      ],
    );
  }

  Future<List<Map<String, String>>> _getAllFollowedForum() async {
    DioClient dioClient = DioClient();
    List<Map<String, String>> allFollowedForum = [];
    var res = await dioClient.universalPost(
        PostBodyType(<UrlKeyAndValue>[
          UrlKeyAndValue(
              key: "BDUSS",
              value: await dioClient.cookieManager.getCookie(key: "BDUSS") ?? ""),
          UrlKeyAndValue(key: "like_forum", value: "1")
        ]),
        Uri.parse(tiebaRecommendForum));

    var response = jsonDecode(res);
    var likeForum = response['like_forum'];
    if (likeForum == null) {
      return <Map<String, String>>[]; //出错或者未登录
    }
    for (var it in likeForum) {
      allFollowedForum.add({
        "forumName": it['forum_name'],
        "level": it['level_id'],
        "forumAvatar": it['avatar'],
      });
    }

    /*int i=1;

    while(true){
      String part=await dioClient.getFollowedForum(uri: getFavoriteForumUri(i.toString()));
      Map<String,dynamic> parsedPart=HTMLParser.parseTiebaFocusList(part);
      allFollowedForum.addAll(parsedPart["data"]);
      i++;
      if(!parsedPart["hasMore"]){
        break;
      }
    }
    log(allFollowedForum.toString());*/
    return allFollowedForum;
  }
}
