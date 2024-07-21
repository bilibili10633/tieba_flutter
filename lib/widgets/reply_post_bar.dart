import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:tieba/Util.dart';
import 'package:tieba/widgets/reply_form.dart';

class ReplyPostBar extends StatefulWidget {
  final String kw, tid;
  late final ReplyForm replyForm;
  late final String fid;
  ReplyPostBar({super.key, required this.kw, required this.tid}){
    replyForm=ReplyForm(kw: kw, tid: tid);
  }


  @override
  State<ReplyPostBar> createState() => _ReplyPostBarState();
}

class _ReplyPostBarState extends State<ReplyPostBar> {
  @override
  Widget build(BuildContext context) {
    log("tid=${widget.tid},kw=${widget.kw}");
    return SizedBox(
      width: Util().devWidth,
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: MaterialButton(
              onPressed: () {
                showBottomSheet(context: context, builder: (context)=>widget.replyForm);
              },
              height: 45,
              child: RichText(
                text: TextSpan(
                    style: TextStyle(fontSize: 15,color: !Util.isDarkMode(context)?const Color(0xff000000):const Color(0xffffffff)),
                    children: [
                      WidgetSpan(child: Icon(Icons.edit,size: 20,),),
                      TextSpan(text: "编辑回复")
                    ]),
              ),
            ),
          ),
          Expanded(
              child: Row(
            children: [
              Expanded(
                  child: MaterialButton(
                    child: const Icon(Icons.message_outlined,size: 20),
                  onPressed: () {},
              )),
              Expanded(
                  child: MaterialButton(
                    child: const Icon(Icons.thumb_up_alt_outlined,size: 20),
                  onPressed: () {},
              )),
              Expanded(
                  child: MaterialButton(
                    child: const Icon(Icons.share,size: 20),
                  onPressed: () {},
              ))
            ],
          )),
        ],
      ),
    );
  }
}
