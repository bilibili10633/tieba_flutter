import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:photo_browser/photo_browser.dart';

import 'package:tieba/Util.dart';
import 'package:tieba/network/dio_client.dart';
import 'package:tieba/network/tieba_api_collection.dart';
import 'package:tieba/pages/thread_detail.dart';

class RecommendPage extends StatefulWidget {
  const RecommendPage({super.key});
  @override
  State<StatefulWidget> createState() => RecommendPageState();
}

class RecommendPageState extends State<StatefulWidget> {
  DioClient dc = DioClient();
  List<ThreadDataType> threads = [];
  ScrollController threadListController = ScrollController();
  List<Widget> items = [
    Align(
        alignment: Alignment.center,
        child: SizedBox(
            height: 200,
            width: 200,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: const [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(tiebaMainThemeColor),
                  backgroundColor: Colors.transparent,
                ),
              ],
            ))),
  ];
  RecommendPageState() {
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
    Future<String?> fs = dc.getInfo(uri: getRecommendThreadUrl);
    fs.then((value) {
      /*if(value==null){*/
      /*  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("貌似网络出问题了！")));*/
      /*  return;*/
      /*}*/
      var threadList = jsonDecode(value!);
      threadList = threadList['data']['thread_list'];
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
            forumName: threadList[i]['forum']['forum_name'],
            userIconAddress:
                '$userAvatarPrefix${threadList[i]['author']["portrait"]}',
            userName: threadList[i]['author']['user_nickname_v2'] ??
                (threadList[i]['author']['user_nickname'] ??
                    threadList[i]['author']['display_name']),
            tid: threadList[i]['tid'].toString(),
            threadImgs: imgList,
            agreeNum: threadList[i]['agree']['agree_num'],
            disAgreeNum: threadList[i]['agree']['disagree_num'],
            replyNum: threadList[i]['reply_num']));
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
    /*if(offset!=0){
      Timer.periodic(const Duration(seconds: 0), (timer) {
        threadListController.jumpTo(offset);
        timer.cancel();
      });
    }*/
    return Stack(
      children: [
        ListView(
          controller: threadListController,
          children: items,
        ),
        Positioned(
          right: 10,
          bottom: 10,
          child: FloatingActionButton(
            onPressed: () {
              buildItem();
            },
            child: const Icon(Icons.refresh),
          ),
        )
      ],
    );
  }
}

class RecommendThreadItem extends StatelessWidget {
  late final String tid;
  //late List<Widget> threadImgs;
  final ThreadDataType thread;
  RecommendThreadItem.fromDataType({super.key, required this.thread}) {
    tid = thread.tid;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        alignment: Alignment.center,
        color: const Color.fromARGB(255, 0xf3, 0xf3, 0xf7),
        //width: Util.devWidth-20,
        //height: ,
        child: SizedBox(
            width: Util().devWidth - 20,
            child: Card(
              elevation: 0,
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10))),
              child: InkWell(
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  focusColor: const Color.fromARGB(255, 0xf3, 0xf3, 0xf7),
                  onTap: () {
                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (context) {
                      return ThreadDetail(
                        tid: tid,
                        barName: thread.forumName,
                      );
                    }));
                  },
                  //TODO finish the child
                  child: CardContent(threadDataType: thread)),
            )));
  }
}

class CardDivider extends StatelessWidget {
  const CardDivider({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 15,
      color: const Color.fromARGB(0xff, 0xf3, 0xf3, 0xf7),
    );
  }
}

class ThreadDataType {
  final String title, subTitle, userIconAddress, userName, forumName, tid;
  final int agreeNum, disAgreeNum, replyNum;
  final List<String> threadImgs;
  final bool hasBarName; //是否显示吧名
  const ThreadDataType({
    required this.title,
    required this.subTitle,
    required this.forumName,
    required this.userIconAddress,
    required this.userName,
    required this.threadImgs,
    required this.tid,
    required this.agreeNum,
    required this.disAgreeNum,
    required this.replyNum,
    this.hasBarName = true,
  });
  @override
  String toString() {
    return "{userName:$userName ; forumName: $forumName ; title: $title ; subtitle : $subTitle;}";
  }
}

class _ThreadImage extends StatelessWidget {
  final String imgSrc;
  const _ThreadImage({required this.imgSrc});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 120,
      margin: const EdgeInsets.only(right: 10, bottom: 10),
      child: Image.network(
        imgSrc,
        fit: BoxFit.cover,
      ),
    );
  }
}

class CardContent extends StatelessWidget {
  static const double iconSize = 23;
  late final String title, subTitle, userIconAddress, userName, forumName, tid;
  late final int agree, disagree, reply;
  late final List imagesData;
  late final List<Widget> threadImgs = [];
  late final bool hasBarName;
  CardContent({super.key, required ThreadDataType threadDataType}) {
    title = threadDataType.title;
    subTitle = threadDataType.subTitle;
    forumName = threadDataType.forumName;
    userIconAddress = threadDataType.userIconAddress;
    userName = threadDataType.userName;
    tid = threadDataType.tid;
    agree = threadDataType.agreeNum;
    disagree = threadDataType.disAgreeNum;
    reply = threadDataType.replyNum;
    imagesData = threadDataType.threadImgs;
    hasBarName = threadDataType.hasBarName;
  }
  @override
  Widget build(BuildContext context) {
    _getImages(context);
    late List<Widget> stackChildren;
    if (hasBarName) {
      stackChildren = [
        Positioned(
            //头像
            top: 17,
            left: 13,
            child: SizedBox(
              width: 35,
              height: 35,
              child: CircleAvatar(
                backgroundImage: NetworkImage(userIconAddress),
                radius: 100,
              ),
            )), //头像
        Positioned(
            //昵称
            top: 15,
            left: 57,
            child: Text(
              userName,
              style: const TextStyle(
                  fontWeight: FontWeight.w600, color: mainTextColor),
            )), //昵称
        Positioned(
            top: 35,
            left: 57,
            child: Text(
              "来自 $forumName吧",
              style: const TextStyle(
                  fontSize: 12,
                  color: Color.fromARGB(255, 0xd0, 0xd0, 0xd0),
                  fontWeight: FontWeight.w600),
            ))
      ];
    }
    else {
      stackChildren = [
        Positioned(
            //头像
            top: 17,
            left: 13,
            child: SizedBox(
              width: 35,
              height: 35,
              child: CircleAvatar(
                backgroundImage: NetworkImage(userIconAddress),
                radius: 100,
              ),
            )), //头像
        Positioned(
            //昵称
            top: 15,
            left: 57,
            child: Text(
              userName,
              style: const TextStyle(
                  fontWeight: FontWeight.w600, color: mainTextColor),
            )), //昵称
      ];
    }

    return Column(
      children: [
        SizedBox(
          height: 58,
          child: Stack(children: stackChildren),
        ),
        ListTile(
          title: Text(title),
          subtitle: Text(subTitle),
        ),
        Container(
          width: Util().devWidth - 60,
          alignment: Alignment.center,
          child: Row(children: threadImgs),
        ),
        Row(
          children: [
            Expanded(
                flex: 1,
                child: TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.thumb_up_alt_outlined,
                    size: iconSize,
                  ),
                  label: Text("$agree"),
                  style: ButtonStyle(
                    foregroundColor: MaterialStateColor.resolveWith((states) {
                      return const Color.fromARGB(0xff, 0xa5, 0xa5, 0xa5);
                    }),
                  ),
                )),
            Expanded(
                flex: 1,
                child: TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.thumb_down_alt_outlined,
                    size: iconSize,
                  ),
                  label: Text("$disagree"),
                  style: ButtonStyle(
                    foregroundColor: MaterialStateColor.resolveWith((states) {
                      return const Color.fromARGB(0xff, 0xa5, 0xa5, 0xa5);
                    }),
                  ),
                )),
            Expanded(
                flex: 1,
                child: TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.message_outlined,
                    size: iconSize,
                  ),
                  label: Text("$reply"),
                  style: ButtonStyle(
                    foregroundColor: MaterialStateColor.resolveWith((states) {
                      return const Color.fromARGB(0xff, 0xa5, 0xa5, 0xa5);
                    }),
                  ),
                )),
            Expanded(
                flex: 1,
                child: TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.share,
                    size: iconSize,
                  ),
                  label: const Text(""),
                  style: ButtonStyle(
                    foregroundColor: MaterialStateColor.resolveWith((states) {
                      return const Color.fromARGB(0xff, 0xa5, 0xa5, 0xa5);
                    }),
                  ),
                ))
          ],
        )
      ],
    );
  }

  void _getImages(BuildContext context) {
    if (imagesData.isNotEmpty) {
      for (int i = 0; i < imagesData.length && i < 2; i++) {
        threadImgs.add(GestureDetector(
          onTap: () {
            PhotoBrowser photoBrowser = PhotoBrowser(
              heroTagBuilder: (index) => imagesData[index],
              allowPullDownToPop: true,
              itemCount: imagesData.length,
              initIndex: i,
              pullDownPopConfig: const PullDownPopConfig(bgColorMinOpacity: 0),
              imageUrlBuilder: (index) {
                return imagesData[index];
              },
            );
            photoBrowser.push(context);
          },
          child: Hero(
            tag: imagesData[i],
            child: _ThreadImage(imgSrc: imagesData[i]),
          ),
        ));
      }
    }
  }
}
