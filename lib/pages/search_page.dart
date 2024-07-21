import 'package:flutter/cupertino.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  @override
  Widget build(BuildContext context) {
    return  CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(middle: const CupertinoSearchTextField(),trailing: CupertinoButton(onPressed: (){}, child: const Text("搜索",style: TextStyle(fontSize: 10),)),),
        child: const Center(child: Text("搜索页面"),),
    );
  }
}
