import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:tieba/Util.dart';
import 'package:tieba/network/dio_client.dart';
import 'package:tieba/network/tieba_api_collection.dart';
import 'package:tieba/pages/recommend_page.dart';
import 'package:tieba/pages/thread_detail.dart';

class Notifications extends StatefulWidget {
  const Notifications({super.key});
  @override
  State<StatefulWidget> createState() => NotificationsState();
}

class NotificationsState extends State<StatefulWidget>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Widget message=const Placeholder();
  Widget atme=const Placeholder();
  Widget agreeMe=const Placeholder();
  @override
  void initState() {
    _tabController = TabController(length: 3, vsync: this);
    startReplymeRequest(1);
    startAtMeRequest();
    startAgreeMeRequest();
    super.initState();
  }

  Future<void> startReplymeRequest(int pn) async {
    DioClient dioClient = DioClient();
    dioClient.universalPost(
        PostBodyType([
          UrlKeyAndValue(
              key: 'BDUSS',
              value:
                  await dioClient.cookieManager.getCookie(key: "BDUSS") ?? ''),
          UrlKeyAndValue(key: 'pn', value: pn.toString())
        ]),
        Uri.parse(getTiebaMessagesUri)).then((value) {
          var json=jsonDecode(value);
          List<Widget> content=[];
          try{
            var replyList=json['reply_list'];
            //log(replyList[0].toString());
            for(int i=0;i<replyList.length;i++){
              content.add(
                  InkWell(
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context){
                        return ThreadDetail(tid: replyList[i]['thread_id'], barName: replyList[i]['fname']);
                      }));
                    },
                    child: CardContent(
                      threadDataType: ThreadDataType(
                          title: replyList[i]['content'],
                          subTitle: (replyList[i]['quote_user']['name_show']??replyList[i]['quote_user']['name'])+":"
                              +replyList[i]['quote_content']+"\n来自："+replyList[i]['title'],
                          forumName: replyList[i]['fname'],
                          userIconAddress: userAvatarPrefix+replyList[i]['replyer']['portrait'],
                          userName: replyList[i]['replyer']['name_show']??userAvatarPrefix+replyList[i]['replyer']['name'],
                          threadImgs: [],
                          tid: replyList[i]['thread_id'],
                          agreeNum: 0,
                          disAgreeNum: 0,
                          replyNum: 0),
                      hasAgreeBar: false,
                    ),
                  )
              );
            }
          }catch(e){
            log(e.toString());
          }
          setState(() {
            message=ListView(
              children: content,
            );
          });
    });
  }
  Future<void>startAtMeRequest()async{
    DioClient dioClient=DioClient();
    dioClient.universalPost(PostBodyType([
      UrlKeyAndValue(key: 'BDUSS', value:await dioClient.cookieManager.getCookie(key: 'BDUSS')??'')
    ]), Uri.parse(getTiebaAtMeUri)).then((value) {
      var json=jsonDecode(value);
      List<Widget> contents=[];
      try{
        var atList=json['at_list'];
        for(int i=0;i < atList.length;i++){
          contents.add(
            InkWell(
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context){
                  return ThreadDetail(tid: atList[i]['thread_id'], barName: atList[i]['fname']);
                }));
              },
              child: CardContent(
                threadDataType: ThreadDataType(
                    title: atList[i]['title'],
                    subTitle: atList[i]['content'],
                    forumName: atList[i]['fname'],
                    userIconAddress: userAvatarPrefix+atList[i]['replyer']['portrait'],
                    userName: atList[i]['replyer']['name_show']??atList[i]['replyer']['name'],
                    threadImgs: [],
                    tid: '0',
                    agreeNum: 0,
                    disAgreeNum: 0,
                    replyNum: 0,
                ),
                hasAgreeBar: false,
              ),
            )
          );
        }
      }catch(E){
        log(E.toString());
      }
      setState(() {
        atme=ListView(
          children: contents,
        );
      });
    });
  }
  Future<void>startAgreeMeRequest()async{
    DioClient dioClient=DioClient();
    dioClient.universalPost(PostBodyType([
      UrlKeyAndValue(key: 'BDUSS', value:await dioClient.cookieManager.getCookie(key: 'BDUSS')??'')
    ]), Uri.parse(getTiebaAgreeMeUri)).then((value) {
      var json=jsonDecode(value);
      List<Widget> contents=[];
      try{
        var atList=json['agree_list'];
        for(int i=0;i < atList.length;i++){
          contents.add(
              InkWell(
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context){
                    return ThreadDetail(tid: atList[i]['thread_info']['id'], barName: atList[i]['thread_info']['fname']);
                  }));
                },
                child: CardContent(
                  threadDataType: ThreadDataType(
                    title: "赞了我",
                    subTitle: "原帖：${atList[i]['post_info']['content'][0]['text']??''}",
                    forumName: atList[i]['thread_info']['fname'],
                    userIconAddress: userAvatarPrefix+atList[i]['agreeer']['portrait'],
                    userName: atList[i]['agreeer']['name_show']??atList[i]['agreeer']['name'],
                    threadImgs: [],
                    tid: '0',
                    agreeNum: 0,
                    disAgreeNum: 0,
                    replyNum: 0,
                  ),
                  hasAgreeBar: false,
                ),
              )
          );
        }
      }catch(E){
        log(E.toString());
      }
      setState(() {
        agreeMe=ListView(
          children: contents,
        );
      });
    });
  }


  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(
          unselectedLabelColor: const Color(0xff5687d2),
          labelColor: tiebaMainThemeColor,
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: "我的消息"),
            Tab(text: "提到我的"),
            Tab(
              text: "点赞",
            )
          ],
          controller: _tabController,
        ),
        SizedBox(
            height: Util().devHeight - 185,
            child: TabBarView(
              controller: _tabController,
              children: [message, atme,agreeMe],
            ))
      ],
    );
  }
}
