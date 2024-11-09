import 'dart:convert';
import 'dart:developer';
import 'package:chewie/chewie.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:photo_browser/photo_browser.dart';
import 'package:tieba/network/tieba_api_collection.dart';
import 'package:tieba/widgets/forum_level.dart';
import 'package:tieba/widgets/reply_post_bar.dart';
import 'package:video_player/video_player.dart';
import '../Util.dart';
import '../network/dio_client.dart';

String globalTid = "";
const Color bg = Color(0xffffffff);
int currentPage = 1, hasMorePage = 1;

class ThreadDetail extends StatelessWidget {
  final String tid, barName;
  late final ReplyPostBar replyPostBar;
  ThreadDetail({super.key, required this.tid, required this.barName}) {
    globalTid = tid;
    currentPage = hasMorePage = 1;
    replyPostBar = ReplyPostBar(tid: globalTid, kw: barName);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          // backgroundColor: const Color(0xffffffff),
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
        body: DetailPage(
          replyPostBar: replyPostBar,
        ));
  }

  Widget actionSheetBuilder(BuildContext context) {
    return Container(
      height: 400,
    );
  }
}

class DetailPage extends StatefulWidget {
  final ReplyPostBar replyPostBar;
  const DetailPage({super.key, required this.replyPostBar});

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

  void loadRes() async {
    DioClient dioClient = DioClient();
    if (hasMorePage == 1) {
      //Future<String?> fs =
      //   dioClient.getInfo(uri: getThreadDetailUri(globalTid, "$currentPage"));
      Future<String?> fs = dioClient.universalPost(
          PostBodyType([
            UrlKeyAndValue(
                key: "BDUSS",
                value: await dioClient.cookieManager.getCookie(key: "BDUSS") ??
                    ""),
            UrlKeyAndValue(key: "kz", value: globalTid),
            UrlKeyAndValue(key: "pn", value: currentPage.toString()),
            UrlKeyAndValue(key: "rn", value: '30'),
            UrlKeyAndValue(key: "floor_rn", value: '50'),
            UrlKeyAndValue(key: "with_floor", value: '1')
          ]),
          Uri.parse(postThreadDetail));

      fs.then((value) {
        var postList = jsonDecode(value!);
        try {
          hasMorePage = postList['page']['has_more'];
          postList = postList['post_list'];
          if (!firstFloorLoaded) {
            posts = _parseData(postList);
          } else {
            posts.addAll(_parseData(postList));
            List<Widget> tmp = posts;
            posts = tmp.toList();
            tmp.clear();
          }
          currentPage++;
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(postList['errmsg'] ?? "发生了一些错误，请重试..."),
            duration: const Duration(seconds: 4),
          ));
          posts = [
            SizedBox(
              height: 500,
              child: Align(
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset("images/notfound.png"),
                      Text(
                        postList['errmsg'] ?? "发生了一些错误，请重试...",
                        style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 20,
                            color: Color(0xffa3a3a3)),
                      ),
                    ],
                  )),
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
            tmp = tmp.replaceAll("<br/>", "\n");
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
            postContent.add(TextSpan(
                text: content[j]['text'],
                style: const TextStyle(color: tiebaMainThemeColor)));
            break;
          case 2: //表情
            postContent.add(WidgetSpan(
                child: SizedBox(
              width: 16,
              height: 16,
              child: Image.network((content[j]['text'] == "image_emoticon"
                  ? "$tiebaEmojiPrefix${content[j]['text']}1.png"
                  : "$tiebaEmojiPrefix${content[j]['text']}.png")),
            )));
            break;
          case 3:
            images.add(content[j]['origin_src']);
            break;
          case 5:
            postContent.add(WidgetSpan(
                child: SizedBox(
              height: 280,
              child: MyVideoWidget(
                url: content[j]['link'],
                w: content[j]['width'],
                h: content[j]['height'],
              ),
            )));
            break;
          default:
            postContent.add(const TextSpan(
                text: "{未识别的内容}", style: TextStyle(color: mainTextColor)));
            log(content[j].toString());
        }
      }
      var controller=PhotoBrowserController();
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
                        controller: controller,
                        positionBuilders: [(ctx,index,total){
                          return Positioned(
                              left: 20,
                              bottom: 20,
                              child: CupertinoButton(
                                onPressed: () {
                                  Util.saveNetworkImage(images[index]);
                                },
                                child: const Icon(Icons.save),));
                        }],
                      );
                      photoBrowser.push(context);
                    },
                    child: Hero(
                      tag: images[k],
                      child: Image.network(images[k], loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress){
                        if (loadingProgress == null) {
                          return child;
                        }
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? (loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes??1))
                                : null,
                          ),
                        );
                      },),
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
    DetailPage detailPage = widget as DetailPage;
    return Stack(
      children: [
        Positioned(
          top: 0,
          width: Util().devWidth,
          height: Util().devHeight - 125,
          child: Material(
            // color: bg,
            child: ListView(
              controller: _scrollController,
              children: posts,
            ),
          ),
        ),
        Positioned(
            bottom: 0,
            child: Container(
                decoration:  BoxDecoration(
                  boxShadow:  [
                    BoxShadow(
                        color: !Util.isDarkMode(context)?const Color(0x28CBCBCB):const Color(0x28000000),
                        offset: const Offset(0, -1),
                        spreadRadius: 2,
                        blurRadius: 5)
                  ],
                  color: !Util.isDarkMode(context)?const Color(0xffffffff):Util.defaultDarkColorScheme.surface,
                ),
                width: Util().devWidth,
                height: 45,
                child: detailPage.replyPostBar))
      ],
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    if (controller != null) controller!.dispose();
    if (chewieController != null) chewieController!.dispose();
    super.dispose();
  }
}

class _UserInfoModule extends StatelessWidget {
  final String userName, userAvatarSrc;
  final int time, floorNum, level;
  const _UserInfoModule(
      {required this.userName,
      required this.userAvatarSrc,
      required this.time,
      required this.floorNum,
      required this.level});
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
                    // color: mainTextColor,
                    fontWeight: FontWeight.w600),
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
              )),
          Positioned(
            top: 35,
            left: 24,
            child: ForumLevelWidget(level: level),
          )
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
    var obj = w.singlePostData['sub_post_list'] ?? {'sub_post_list': []};
    subPosts = obj['sub_post_list'];
    //log("楼中楼:$subPosts");
    //parsedSubPosts.isEmpty 防止重复加载触发百度CAPTCHA
    if (subPosts.isNotEmpty && w.parsedSubPosts.isEmpty) {
      log("in parsing", name: "build");
      _parseSubPosts(globalTid, w.singlePostData['id'].toString())
          .then((value) {
        try {
          w.parsedSubPosts.addAll(List.from(value));
          setState(() {});
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
                floorNum: w.singlePostData['floor'],
                level: authorInfo['level_id']),
            w.hasTitle
                ? SizedBox(
                    width: Util().devWidth,
                    child: Text(
                      w.singlePostData['title'],
                      style: const TextStyle(
                          //color: Util.mainTextColor,
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
                  color: Util.isDarkMode(context)?const Color(0xff1E1F22):const Color(0xffededed),
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
                )));
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
          // color: const Color(0xffff0000),
          child: InkWell(
              onTap: () {
                log("subpost tap");
              },
              child: RichText(
                text: TextSpan(children: inlineSpan,),
                textAlign: TextAlign.left,
              )),
        ),
      ));
    }
    return pSubPosts;
  }
}
