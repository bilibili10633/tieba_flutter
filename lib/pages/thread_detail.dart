import 'dart:convert';
import 'dart:developer';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:photo_browser/photo_browser.dart';
import 'package:tieba/network/tieba_api_collection.dart';
import 'package:video_player/video_player.dart';
import '../Util.dart';
import '../network/dio_client.dart';

String globalTid = "";
const Color bg = Color(0xffffffff);
int currentPage = 1, hasMorePage = 1;

class ThreadDetail extends StatelessWidget {
  final String tid, barName;
  ThreadDetail({super.key, required this.tid, required this.barName}) {
    globalTid = tid;
    currentPage = hasMorePage = 1;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xffffffff),
          foregroundColor: tiebaMainThemeColor,
          shadowColor: Colors.transparent,
          title: Text("帖子详细  -  $barName吧"),
          actions: [
            IconButton(
              onPressed: () {
                showModalBottomSheet(
                    context: context, builder: actionSheetBuilder);
              },
              icon: const Icon(Icons.more_vert),
            )
          ],
        ),
        body: const DetailPage());
  }

  Widget actionSheetBuilder(BuildContext context) {
    return Container(
      height: 400,
    );
  }
}

class DetailPage extends StatefulWidget {
  const DetailPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return DetailPageState();
  }

}

class DetailPageState extends State<StatefulWidget> {
  bool firstFloorLoaded = false;
  List<Widget> posts = [
    const SizedBox(
      height: 500,
      child: Align(
        alignment: Alignment.center,
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation(tiebaMainThemeColor),
          backgroundColor: Colors.transparent,
        ),
      ),
    )
  ];
  final ScrollController _scrollController = ScrollController();
  DetailPageState() {
    _scrollController.addListener(() {
      if (_scrollController.position.maxScrollExtent ==
          _scrollController.offset) {
        log("滑到底部了");
        loadRes();
      }
      //log("maxScrollExtent:${_scrollController.position.maxScrollExtent}   offset:${_scrollController.offset}");
    });
    loadRes();
  }

  void loadRes() {
    DioClient dioClient = DioClient();
    if (hasMorePage == 1) {
      Future<String?> fs =
          dioClient.getInfo(uri: getThreadDetailUri(globalTid, "$currentPage"));
      fs.then((value) {
        var postList = jsonDecode(value!);
        try{
          hasMorePage = postList['data']['page']['has_more'];
          postList = postList['data']['post_list'];
          if (!firstFloorLoaded) {
            posts = _parseData(postList);
          } else {
            posts.addAll(_parseData(postList));
            List<Widget> tmp = posts;
            posts = tmp.toList();
            tmp.clear();
          }
          currentPage++;
        }catch(e){
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(postList['errmsg']??"发生了一些错误，请重试..."),duration: const Duration(seconds: 4),)
          );
          posts=[
            SizedBox(
              height: 500,
              child: Align(
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset("images/notfound.png")
                    ,
                    Text(postList['errmsg']??"发生了一些错误，请重试...",style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 20,
                        color: Color(0xffa3a3a3)
                    ),),
                  ],
                )
              ),
            )
          ];
          log(postList['errmsg']);
        }
        setState(() {});
      });
    } else {
      log("没有更多页面了");
    }
  }
  VideoPlayerController? controller;
  ChewieController? chewieController;
  List<Widget> _parseData(dynamic postListInList) {
    List<Widget> replyPosts = [];
    for (int i = 0; i < postListInList.length; i++) {
      var content = postListInList[i]['content'];
      List<InlineSpan> postContent = [];
      List<String> images = [];
      if (content == null) {
        if (i == 0 && (!firstFloorLoaded)) {
          replyPosts.add(_PostItem(
            singlePostData: postListInList[i],
            postContent: postContent,
            hasTitle: true,
          ));
          firstFloorLoaded = true;
        }
        continue; //只有标题的帖子要跳过内容的处理
      }
      for (int j = 0; j < content.length; j++) {
        switch (content[j]['type']) {
          case 0:
            String tmp = content[j]['text'];
            tmp = tmp.replaceAll("<br/>", " ");
            postContent.add(WidgetSpan(
                child: SelectableText(
                  tmp,
                ),
                style: const TextStyle(
                    color: mainTextColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w600)));
            break;
          case 1:
            postContent.add(TextSpan(text: content[j]['text'],style: const TextStyle(color: tiebaMainThemeColor)));
            break;
          case 2: //表情
            postContent.add(WidgetSpan(
                child: SizedBox(
              width: 16,
              height: 16,
              child: Image.network(
                content[j]['src'],
              ),
            )));
            break;
          case 3:
            images.add(content[j]['src']);
            break;
          case 5:
            postContent.add(
              WidgetSpan(child: SizedBox(
                height: 280,
                child: MyVideoWidget(
                  url: postListInList[i]['video_info']['video_url'],
                  w: postListInList[i]['video_info']['video_width'],
                  h: postListInList[i]['video_info']['video_height'],
                ),
              ))
            );
            break;
          default:
            postContent.add(const TextSpan(
                text: "{未识别的内容}", style: TextStyle(color: mainTextColor)));
            log(content[j].toString());
        }
      }
      if (images.isNotEmpty) {
        //帖子配图
        for (int k = 0; k < images.length; k++) {
          postContent.add(const TextSpan(text: "\n"));
          postContent.add(WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: Container(
                  decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(5)),
                      border: Border.all(color: const Color(0xFFeeeeee))),
                  child: GestureDetector(
                    onTap: () {
                      PhotoBrowser photoBrowser = PhotoBrowser(
                        allowSwipeDownToPop: true,
                        heroTagBuilder: (index) {
                          return images[index];
                        },
                        allowPullDownToPop: true,
                        itemCount: images.length,
                        initIndex: k,
                        imageUrlBuilder: (index) {
                          return images[index];
                        },
                      );
                      photoBrowser.push(context);
                    },
                    child: Hero(
                      tag: images[k],
                      child: Image.network(images[k]),
                    ),
                  ))));
        }
      }

      //添加
      if (i == 0 && (!firstFloorLoaded)) {
        replyPosts.add(_PostItem(
          singlePostData: postListInList[i],
          postContent: postContent,
          hasTitle: true,
        ));
        firstFloorLoaded = true;
      } else {
        replyPosts.add(_PostItem(
          singlePostData: postListInList[i],
          postContent: postContent,
          hasTitle: false,
        ));
      }
      //楼中楼

      replyPosts.add(const Divider(
        height: 2,
      ));
    }
    return replyPosts;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        //color: bg,
        width: Util().devWidth,
        height: Util().devHeight - 80,
        child: Material(
          color: bg,
          child: ListView(
            controller: _scrollController,
            children: posts,
          ),
        ));
  }
  @override
  void dispose() {
    // TODO: implement dispose
    if(controller!=null)controller!.dispose();
    if(chewieController!=null)chewieController!.dispose();
    super.dispose();
  }
}

class _UserInfoModule extends StatelessWidget {
  final String userName, userAvatarSrc;
  final int time, floorNum;
  const _UserInfoModule(
      {required this.userName,
      required this.userAvatarSrc,
      required this.time,
      required this.floorNum});
  @override
  Widget build(BuildContext context) {
    DateTime convertedTime = DateTime.fromMillisecondsSinceEpoch(time * 1000);
    return SizedBox(
      height: 60,
      child: Stack(
        children: [
          Positioned(
            top: 10,
            left: 0,
            child: SizedBox(
                width: 35,
                height: 35,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage(userAvatarSrc),
                )),
          ), //头像
          Positioned(
              left: 45,
              top: 9,
              child: Text(
                userName,
                style: const TextStyle(
                    color: mainTextColor, fontWeight: FontWeight.w600),
              )),
          Positioned(
              top: 30,
              left: 45,
              child: Text(
                "发布于：${convertedTime.toString()}",
                style: const TextStyle(
                    color: Color.fromARGB(255, 0xd0, 0xd0, 0xd0), fontSize: 12),
              )),
          Positioned(
              right: 0,
              top: 11,
              child: Text(
                "#$floorNum楼",
                style: TextStyle(color: Colors.grey.shade800),
              ))
        ],
      ),
    );
  }
}

class SubPost extends StatefulWidget {
  const SubPost({super.key});

  @override
  State<StatefulWidget> createState() => SubPostState();
}

class SubPostState extends State<StatefulWidget> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      color: const Color(0xffaaaaaa),
    );
  }
}



class _PostItem extends StatefulWidget {
  final Map singlePostData;
  final List<InlineSpan>? postContent;
  final bool hasTitle;
  final List<Widget> parsedSubPosts = [];
  _PostItem(
      {required this.singlePostData, this.postContent, required this.hasTitle});
  @override
  State<StatefulWidget> createState() => _PostItemState();

}



class _PostItemState extends State<StatefulWidget> {

  late List subPosts;

  @override
  Widget build(BuildContext context) {
    _PostItem w = widget as _PostItem;
    subPosts= w.singlePostData['sub_post_list']??[];
    //log("楼中楼:$subPosts");
    //parsedSubPosts.isEmpty 防止重复加载触发百度CAPTCHA
    if (subPosts.isNotEmpty&&w.parsedSubPosts.isEmpty) {
      log("in parsing",name: "build");
      _parseSubPosts(globalTid, w.singlePostData['id'].toString())
          .then((value) {
        try {
          w.parsedSubPosts.addAll(List.from(value));
          setState(() {

          });
        } catch (E) {
          log("non fatal exception", name: "trying parse");
        }
      });
    }


    var authorInfo = w.singlePostData['author'];
    return InkWell(
      focusColor: bg,
      onTap: () {
        log("get Tap");
      },
      child: Container(
        alignment: Alignment.topLeft,
        width: Util().devWidth,
        padding: const EdgeInsets.only(left: 20, right: 20, bottom: 15),
        child: Column(
          children: [
            _UserInfoModule(
                userName: authorInfo['name_show'],
                userAvatarSrc: "$userAvatarPrefix${authorInfo['portrait']}",
                time: w.singlePostData['time'],
                floorNum: w.singlePostData['floor']),
            w.hasTitle
                ? SizedBox(
                    width: Util().devWidth,
                    child: Text(
                      w.singlePostData['title'],
                      style: const TextStyle(
                          color: mainTextColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 17),
                    ),
                  )
                : const SizedBox(
                    height: 0,
                  ),
            Align(
              alignment: Alignment.topLeft,
              child: RichText(
                  textAlign: TextAlign.left,
                  text: TextSpan(children: w.postContent ?? [])),
            ),
            const SizedBox(
              height: 20,
            ),
            Container(
                //color: const Color(0xffededed),
                alignment: Alignment.centerLeft,
                width: Util().devWidth,
                child: Ink(
                  color: const Color(0xffededed),
                  child: Column(
                    children: w.parsedSubPosts,
                  ),
                ))
          ],
        ),
      ),
    );
  }
  @override
  void dispose() {
    //w.parsedSubPosts.clear();
    super.dispose();
    // TODO: implement dispose

  }
  Future<List<Widget>> _parseSubPosts(String tid, String pid) async {
    List<Widget> pSubPosts = [];
    DioClient dioClient = DioClient();
    var data = jsonDecode(
        await dioClient.getInfo(uri: getFloorInFloorUri(tid, pid)) ?? "");
    var subPosts = data['data']['sub_post_list'];

    for (var data in subPosts) {
      // Text text =Text("${data['author']['name_show']}：${data['content'].toString()}");

      //log(data.toString());
      List<InlineSpan> inlineSpan = [];
      inlineSpan.add(TextSpan(
        text:
            "${data['author']['show_nickname'] ?? data['author']['name_show']}",
        style: const TextStyle(
          color: tiebaMainThemeColor,
        ),
      ));
      inlineSpan.add(
          const TextSpan(text: "：", style: TextStyle(color: mainTextColor)));

      var content = data['content'];
      for (int k = 0; k < content.length; k++) {
        switch (content[k]['type']) {
          case 0:
            inlineSpan.add(WidgetSpan(
                child: SelectableText(content[k]['text'],
                    style: const TextStyle(color: mainTextColor))));
            break;
          case 2:
            inlineSpan.add(
              WidgetSpan(
                  child: SizedBox(
                width: 16,
                height: 16,
                child: Image.network(content[k]['src']),
              )),
            );
            break;
          case 4:
            inlineSpan.add(TextSpan(
                text: content[k]['text'],
                style: const TextStyle(color: tiebaMainThemeColor)));
            break;
          default:
            log("内容：${content[k]}");
            break;
        }
      }

      pSubPosts.add(Align(
        alignment: Alignment.centerLeft,
        child: Ink(
          color: const Color(0xffededed),
          child: InkWell(
              onTap: () {
                log("subpost tap");
              },
              child: RichText(
                text: TextSpan(children: inlineSpan),
                textAlign: TextAlign.left,
              )),
        ),
      ));
    }
    return pSubPosts;
  }
}
