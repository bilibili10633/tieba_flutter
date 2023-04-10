import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:tieba/Util.dart';
import 'package:tieba/network/dio_client.dart';
import 'package:tieba/network/tieba_api_collection.dart';

class ReplyForm extends StatefulWidget {
  final String kw, tid;

  const ReplyForm({Key? key, required this.kw, required this.tid}) : super(key: key);

  @override
  State<ReplyForm> createState() => _ReplyFormState();
}

class _ReplyFormState extends State<ReplyForm> {
  final TextEditingController textEditingController=TextEditingController();
  @override
  Widget build(BuildContext context) {
    log("tid=${widget.tid}.kw=${widget.kw}");
    return Container(
        decoration: const BoxDecoration(color: Color(0xffffffff), boxShadow: [
          BoxShadow(
              color: Color(0x7e333333),
              offset: Offset(0, -1),
              spreadRadius: 5,
              blurRadius: 5)
        ]),
        width: Util().devWidth,
        height: 240,
        child: Stack(
          children: [
            Positioned(
                left: 20,
                width: Util().devWidth-20,
                height: 40,
                child: Row(
                  children: [
                    const Expanded(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text("回帖",style: TextStyle(fontWeight: FontWeight.w600),),
                      ),
                    ),
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                            onPressed: () {
                              _performReply().then((value) => Navigator.pop(context));
                            },
                            child: const Text("发布")),
                      ),
                    )
                  ],
                )),
            Positioned(
                width: Util().devWidth-50,
                left: 20,
                height: 150,
                top: 40,
                child: TextField(
                  maxLines: 6,
                  autofocus: true,
                  controller: textEditingController,
                  decoration: const InputDecoration(
                      hintText: "友善回帖~~",
                      border: InputBorder.none
                  ),
                )),
            Positioned(
              width: Util().devWidth,
                height: 45,
                bottom: 0,
                child:Row(
                  children: [
                    Expanded(
                        child: MaterialButton(
                            onPressed: (){},
                            child: const Icon(Icons.emoji_emotions_outlined))
                    ),
                    Expanded(
                        child: MaterialButton(
                            onPressed: (){},
                            child: const Icon(Icons.emoji_emotions_outlined))
                    ),
                    Expanded(
                        child: MaterialButton(
                            onPressed: (){},
                            child: const Icon(Icons.emoji_emotions_outlined))
                    ),
                    Expanded(
                        child: MaterialButton(
                            onPressed: (){},
                            child: const Icon(Icons.emoji_emotions_outlined))
                    ),
                    Expanded(
                        child: MaterialButton(
                            onPressed: (){},
                            child: const Icon(Icons.emoji_emotions_outlined))
                    )
                  ],
                )
            )
          ],
        ));
  }
  Future<void> _performReply()async{
    if(textEditingController.value.text==""){
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("内容为空")));
      return;
    }
    DioClient dioClient=DioClient();
    String tbsStr=await dioClient.getInfo(uri: Uri.parse(tiebaGetTbs))??"";
    var tbs=jsonDecode(tbsStr);
    if(tbs['is_login']==0){
      if(mounted)ScaffoldMessenger.maybeOf(context)?.showSnackBar(const SnackBar(content: Text("用户未登录！")));
      return;
    }
    /*获取fid*/
    String data=await dioClient.getInfo(
        uri: Uri.parse("https://tieba.baidu.com/mg/p/getPbData/?kz=${widget.tid}&rn=1&pn=1&only_post=2"))??"";
    var jsonData=jsonDecode(data);
    String? response=await dioClient.universalPost(PostBodyType([
      UrlKeyAndValue(key: 'kw', value: widget.kw),
      UrlKeyAndValue(key: 'tbs', value: tbs['tbs']),
      UrlKeyAndValue(key: 'fid', value: jsonData['data']['forum']['id'].toString()),
      UrlKeyAndValue(key: 'tid', value: widget.tid),
      UrlKeyAndValue(key: 'ie', value: 'utf-8'),
      UrlKeyAndValue(key: 'content', value: textEditingController.value.text),
      UrlKeyAndValue(key: 'ev', value: 'comment'),
      UrlKeyAndValue(key: '_type_', value: 'reply'),
      UrlKeyAndValue(key: 'floor_num', value: "1"),
      UrlKeyAndValue(key: 'rich_text', value: '1'),
      UrlKeyAndValue(key: 'files', value: '[]'),
      UrlKeyAndValue(key: 'ua', value: 'bdtb for Android 12.24.1.0')
    ]), Uri.parse(tiebaNewPostUrl),header: {
      "Referer":"https://tieba.baidu.com/p/${widget.tid}"//添加此请求头才不会系统删帖
    });
    var res2Json=jsonDecode(response);
    if(res2Json['err_code']==0){
      if(mounted)ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("发送成功")));
      return;
    }
    if(mounted)ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("发送失败，原因：${res2Json['error']}")));
  }
}
