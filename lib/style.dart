import 'package:flutter/material.dart';

//변수에 _붙이면 private
var theme = ThemeData(
    bottomNavigationBarTheme: BottomNavigationBarThemeData(unselectedItemColor: Colors.black, selectedItemColor: Colors.black),
    textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(backgroundColor: Colors.grey)),
    iconTheme: IconThemeData(color: Colors.black), //모든 아이콘이 같은 테마(통일감)
    appBarTheme: AppBarTheme(
        color: Colors.white,
        actionsIconTheme: IconThemeData(color: Colors.black)),
    textTheme: TextTheme(bodyMedium: TextStyle(color: Colors.black)) //그냥 변수 만들어서 쓰는게 좋을수도, Theme.of(context).textTheme.bodyMedium으로 불러올수 있음
);