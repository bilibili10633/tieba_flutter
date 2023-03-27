import 'dart:developer';
import 'package:html/parser.dart';


//List<Map<String,String>>
class HTMLParser{
  static Map<String,dynamic> parseTiebaFocusList(String html){
    var doc=parse(html);
    var tr=doc.getElementsByTagName("tr");
    List<Map<String,String>> parsedData=[];
    if(tr.length<2) {
      return {};
    }
    for(int i=1;i<tr.length;i++){
      var children=tr[i].children;
      Map<String,String> forumInfo={
        "forumName":children[0].children[0].innerHtml,
        "exp":children[1].children[0].innerHtml,
        "level":children[2].children[0].children[1].innerHtml,
        "levelName":children[2].children[0].children[0].innerHtml,
      };
      parsedData.add(forumInfo);
    }

    var pagination=doc.getElementsByClassName("pagination");
    bool hasMore=false;
    for(var child in pagination[0].children){
         if(child.innerHtml=="下一页"){
           hasMore=true;
           break;
         }
    }
    return {
      "data":parsedData,
      "hasMore":hasMore
    };
    //log(parsedData.toString());
  }
}