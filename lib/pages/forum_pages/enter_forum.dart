import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';

import 'package:tieba/Util.dart';
import 'package:tieba/network/dio_client.dart';
import 'package:tieba/network/tieba_api_collection.dart';
import '../recommend_page.dart';


String forName="";
class ForumPage extends StatefulWidget {

  ForumPage({super.key,forumName}){
    forName=forumName;
  }
  @override
  State<StatefulWidget> createState() => ForumPageState();
}

class ForumPageState extends State<StatefulWidget> {
  DioClient dc = DioClient();
  List<ThreadDataType> threads = [];
  ScrollController threadListController = ScrollController();
  List<Widget> items = [
    const Align(
        alignment: Alignment.center,
        child: SizedBox(
            height: 200,
            width: 200,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(tiebaMainThemeColor),
                  backgroundColor: Colors.transparent,
                ),
              ],
            ))),
  ];
  ForumPageState() {
    buildItem();
    threadListController.addListener(() {
      //log("Offset:${threadListController.offset}       Max:${threadListController.position.maxScrollExtent}");
      if (threadListController.position.maxScrollExtent ==
          threadListController.offset) {
        log("滑到底部了");
        buildItem();
      }
    });
  }
  Future<void> buildItem() async {
    Future<String?> fs= dc.universalPost(PostBodyType([
      UrlKeyAndValue(key: "kw", value: forName),
      UrlKeyAndValue(key: "BDUSS", value: await dc.cookieManager.getCookie(key: "BDUSS")??"")
    ]), Uri.parse(tiebaWatchPostUrl));
    fs.then((value) {
      //log("数据：$value",name: "进吧");

      var threadList = jsonDecode(value!);
      threadList = threadList['thread_list'];
      for (int i = 0; i < threadList.length; i++) {
        var abstract = threadList[i]['abstract'];
        String subTitle = "";
        if (abstract != null) {
          subTitle = abstract[0]['text'];
        }
        List<String> imgList = [];
        var media = threadList[i]['media'];
        if (media != null) {
          for (int i = 0; i < media.length; i++) {
            var imgUrl = media[i]['small_pic'];
            if (imgUrl != null) {
              imgList.add(imgUrl);
            }
          }
        }
        threads.add(ThreadDataType(
            title: threadList[i]['title'],
            subTitle: subTitle,
            forumName: forName,//threadList[i]['forum']['forum_name'],
            userIconAddress:
            '$userAvatarPrefix${threadList[i]['author']["portrait"]}',
            userName: threadList[i]['author']['name_show'],
            tid: threadList[i]['tid'].toString(),
            threadImgs: imgList,
            agreeNum: threadList[i]['agree']['agree_num'],
            disAgreeNum: threadList[i]['agree']['disagree_num'],
            replyNum: threadList[i]['reply_num'],
            hasBarName: false//不显示吧名
        ));
      }
      List<Widget> newTh = [];
      newTh.add(const CardDivider());
      for (int i = 0; i < threads.length; i++) {
        newTh.add(RecommendThreadItem.fromDataType(thread: threads[i]));
        newTh.add(const CardDivider());
      }
      newTh.add(const CardDivider());
      items = newTh;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    log("Build recommend page");
    return Stack(
      children: [
        ListView(
          controller: threadListController,
          children: items,
        ),
      ],
    );
  }
}





