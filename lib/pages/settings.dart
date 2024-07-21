import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:tieba/LocalStorage/local_storage.dart';
import 'package:tieba/main.dart';

var divider=const Divider(color: Colors.black87,indent: 0,);
class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  LocalStorage? localStorage;
  @override
  void initState(){
    LocalStorage.getInstance();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("设置"),
      ),
      body: ListView(
        children: [
          divider,
          ListTile(
            title: const Text("使用Material3"),
            onTap: (){_setUseMD3(!useMd3.flag);},
            trailing: Switch(
              value: useMd3.flag,
              onChanged: (state){_setUseMD3(state);},
            ),
          ),
          divider,
          ListTile(
            title: const Text("关于"),
            onTap: () {
              showDialog(
                  context: context,
                  builder: (context) {
                    return AboutDialog(
                      applicationName: "贴吧Flutter",
                      applicationVersion: "1.0",
                      applicationIcon: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Image.asset("images/application_ic.png"),
                      ),
                      children: const [
                        Text("此应用使用Flutter构建"),
                        Text(
                          "开发者：不动の大音乐厅",
                          textDirection: TextDirection.rtl,
                          style: TextStyle(fontSize: 14,fontWeight: FontWeight.w600),
                        )
                      ],
                    );
                  });
            },
          ),
          divider
        ],
      ),
    );
  }
  void _setUseMD3 (bool v)async{
    useMd3.setValue(v);
    setState(() {});
    (await LocalStorage.getInstance()).saveOtherThings(key: "useMD3", value: v.toString());
  }
}
