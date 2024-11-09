import 'dart:developer';

import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tieba/LocalStorage/local_storage.dart';



import 'package:tieba/pages/drawer.dart';
import 'package:tieba/pages/forum_list_page.dart';
import 'package:tieba/pages/notifications.dart';
import 'package:tieba/pages/recommend_page.dart';
import 'package:tieba/pages/search_page.dart';
import 'package:toastification/toastification.dart';
import 'Util.dart';

UseMD3FlagObserver useMd3=UseMD3FlagObserver(true);

void main() async{
  runApp(const MyApp());
  Util.transparentSystemUI();

}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  LocalStorage? localStorage;
  @override
  void initState() {
    // TODO: implement initState
    LocalStorage.getInstance().then((v){
      localStorage=v;
      useMd3.flag=(localStorage!.getOtherThings(key: "useMD3"))=="true";
      setState(() {});
      useMd3.addListener((){setState(() {});});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(builder: (lightColorScheme,darkColorScheme){
      log("Scheme========> $darkColorScheme");
      return ToastificationWrapper(
          child: MaterialApp(
            theme: ThemeData(
                useMaterial3: useMd3.flag,
                colorScheme: lightColorScheme??Util.defaultLightColorScheme
            ),
            darkTheme: ThemeData(
                useMaterial3: useMd3.flag,
                colorScheme: darkColorScheme??Util.defaultDarkColorScheme
            ),
            home: const TiebaHome(),
          )
      );
    });
  }
}

class TiebaHome extends StatefulWidget {
  const TiebaHome({super.key});

  @override
  State<StatefulWidget> createState() => TiebaHomeState();
}

class TiebaHomeState extends State<StatefulWidget> {
  int pageCurrentIndex=0;
  var labels=["首页","进吧","消息"];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: const Color(0xffffffff),
      appBar: AppBar(
        foregroundColor: tiebaMainThemeColor,
        title: Text(labels[pageCurrentIndex]),
        actions: [
          IconButton(onPressed: (){
            Navigator.push(context, CupertinoPageRoute(builder: (ctx){
              return const SearchPage();
            }));
          }, icon: const Icon(Icons.search_outlined)),
        ],
      ),
      drawer: const Drawer(
          // backgroundColor: Color(0xffffffff),
        child: DrawerContent(),
      ),
      body: IndexedStack(index: pageCurrentIndex,children: const [
        RecommendPage(),
        ForumListPage(),
        Notifications(),
      ],),
      bottomNavigationBar:BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home),label: "首页"),
          BottomNavigationBarItem(icon: Icon(Icons.category),label: "进吧"),
          BottomNavigationBarItem(icon: Icon(Icons.notifications),label: "消息"),
        ],
        onTap: (index){
          setState(() {
            pageCurrentIndex=index;
          });
        },
        currentIndex: pageCurrentIndex,
      ),
    );
  }
}

class UseMD3FlagObserver extends ChangeNotifier {
  bool flag=true;

  UseMD3FlagObserver(bool v){flag=v;}

  void setValue(v) {
    flag=v;
    notifyListeners();
  }
}
