
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:tieba/network/api.dart';
import 'package:tieba/network/dio_client.dart';

class Profile extends StatefulWidget {
  final String username;
  const Profile({Key? key,required this.username}) : super(key: key);
  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  Widget build(BuildContext context) {
    TiebaApi.getUserThreads(widget.username);

    return const Placeholder();
  }
}
