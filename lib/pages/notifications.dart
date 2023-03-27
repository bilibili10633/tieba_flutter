import 'package:flutter/material.dart';

class Notifications extends StatefulWidget{
  const Notifications({super.key});
  @override
  State<StatefulWidget> createState()=>NotificationsState();
}
class NotificationsState extends State<StatefulWidget>{
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.red,
      child: const Center(child:Text("please unplug before death"),));
  }
}