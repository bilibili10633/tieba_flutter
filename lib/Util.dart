import 'dart:developer';
import 'dart:ui';

import 'package:chewie/chewie.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

const SystemUiOverlayStyle systemUiOverlayStyle = SystemUiOverlayStyle(
  statusBarColor: Colors.transparent,
  statusBarBrightness: Brightness.dark,
  systemNavigationBarColor: Colors.transparent
);
/*
使用前请在style.xml内加入：
  <item name="android:windowTranslucentStatus">false</item>
  <!--设置状态栏为透明-->
  <item name="android:statusBarColor">@android:color/transparent</item>
*/
const mainTextColor=Color.fromARGB(255, 0x34, 0x34, 0x34);

int geT=0;

bool utilGet=false;

class Util{
  late double devWidth,devHeight;
  late int gTime;
  Map<String,dynamic> sessionMap={

  };
  static Util? _util;
  static  ColorScheme defaultLightColorScheme = const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff5d5d6c),
      onPrimary: Color(0xff1a1b27),
      secondary: Color(0xff5e5d67),
      onSecondary: Color(0xff1a1b27),
      error: Color(0xffba1a1a),
      onError: Color(0xffba1a1a),
      surface: Color(0xfffffbff),
      onSurface: Color(0xff1c1b1d)
  );

  static  ColorScheme defaultDarkColorScheme = const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffc6c5d6),
      onPrimary: Color(0xff2f2f3d),
      secondary: Color(0xffc7c5d0),
      onSecondary:  Color(0xff303038),
      error: Color(0xffffb4ab),
      onError:  Color(0xff690005),
      surface: Color(0xff1c1b1d),
      onSurface: Color(0xffe5e1e3)
  );
  static void transparentSystemUI(){
    SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }
  Util._privateConstructor(){
    geT++;
    gTime=geT;
    log("constructor called");
    _initWidthAndHeight();
  }
  static bool isDarkMode(BuildContext context) {
    return Theme.of(context).colorScheme.brightness == Brightness.dark;
  }

  factory Util(){
    if(!utilGet){
      _util=Util._privateConstructor();
      if(_util?.devWidth==0){
        print("获取屏幕信息失败");
        utilGet=false;
      }else{
        print("---------------------------------------------------");
        print("屏幕高度${_util?.devHeight}  屏幕宽度${_util?.devWidth}");
        print("---------------------------------------------------");
        utilGet=true;
      }
    }
    return _util!;
  }
  void _initWidthAndHeight(){
      devWidth= window.physicalSize.width / window.devicePixelRatio;
      devHeight= window.physicalSize.height / window.devicePixelRatio;
  }


  //屏幕宽高


}
const tiebaMainThemeColor=Color.fromARGB(0xff, 0x17, 0x7b, 0xfe);




//Widgets
class MyVideoWidget extends StatefulWidget {
  String url;
  int w,h;
  MyVideoWidget({Key? key,required this.url,required this.w,required this.h}) : super(key: key);

  @override
  State<MyVideoWidget> createState() {
    return _MyVideoWidgetState();
  }
}

class _MyVideoWidgetState extends State<MyVideoWidget> {
  late VideoPlayerController controller;
  late ChewieController chewieController;
  Widget w=Placeholder(child: Image.asset("images/video_loading.png"),);
  @override
  void initState() {
    try{
      widget.url=widget.url.replaceFirst("http://", "https://");//in case of cleartext HTTP not supported by okhttp
      controller=VideoPlayerController.network(widget.url);
      controller.initialize().then((value){
        chewieController=ChewieController(
            videoPlayerController: controller,
            aspectRatio: widget.w/widget.h,
            autoPlay: false,
            looping: true
        );
        setState(() {
          w=Chewie(controller: chewieController);
        });
      });
      super.initState();
    }catch(e){
      print("MyVideoWidget:====================\n");
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return w;
  }

  @override
  void dispose() {
    // TODO: implement dispose
    controller.dispose();
    chewieController.dispose();
    super.dispose();
  }
}
