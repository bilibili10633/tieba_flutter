import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';



import 'package:tieba/pages/drawer.dart';
import 'package:tieba/pages/forum_list_page.dart';
import 'package:tieba/pages/notifications.dart';
import 'package:tieba/pages/recommend_page.dart';
import 'Util.dart';



void main() {
  runApp(const MyApp());
  Util.transparentSystemUI();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(builder: (lightColorScheme,darkColorScheme){
      return MaterialApp(
        theme: ThemeData(
            useMaterial3: true,
            colorScheme: lightColorScheme??Util.defaultLightColorScheme
        ),
        darkTheme: ThemeData(
            useMaterial3: true,
            colorScheme: darkColorScheme??Util.defaultDarkColorScheme
        ),
        home: const TiebaHome(),
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
      backgroundColor: const Color(0xffffffff),
      appBar: AppBar(
        foregroundColor: tiebaMainThemeColor,
        backgroundColor: const Color(0xffffffff),
        shadowColor: const Color(0x00000000),
        title: Text(labels[pageCurrentIndex]),
        actions: [
          IconButton(onPressed: (){}, icon: const Icon(Icons.search_outlined)),
        ],
      ),
      drawer: const Drawer(
          backgroundColor: Color(0xffffffff),
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

