import 'package:flutter/material.dart';

class MultiPageSwitcher extends StatelessWidget{
  //const MultiPageSwitcher({super.key});
  final int currentIndex;
  final List<Widget> pages;
  const MultiPageSwitcher({super.key, required this.currentIndex, required this.pages});
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    if(pages.length-1<currentIndex)throw Error();
    return pages[currentIndex];
  }
}