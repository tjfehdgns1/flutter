import 'package:flutter/material.dart';
import './style.dart' as style;

void main() {
  runApp( MaterialApp(
    theme: style.theme,
      home: MyApp()
    )
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  var tab = 0;
  void _onItemTapped(int index) {
    setState(() {
      tab = index;
    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [IconButton(
            onPressed: (){},
            icon: Icon(Icons.add_box_outlined))],
        title: Text('Instagram', style: TextStyle(color: Colors.black, fontSize: 20,fontWeight: FontWeight.bold),)),
      body: [page(), Text('숍')][tab],
      bottomNavigationBar: BottomNavigationBar(
        showSelectedLabels: true,
        showUnselectedLabels: false,
        currentIndex: tab,
        onTap: _onItemTapped,
        items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_bag_outlined),
          label: 'Shopping',
          ),
        ],
      ) //동적ui만드는법 1.state에 현재UI상태 저장 2.state에 따라 UI 어떵게 보일지 작성 3. 유저가 state 조작
    );
  }
}

//홈페이지
class page extends StatefulWidget {
  const page({Key? key,}) : super(key: key);


  @override
  State<page> createState() => _pageState();
}

class _pageState extends State<page> {
  var likes = 0;
  addOne() {
    setState(() {
      likes++;
    });
  }
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        scrollDirection: Axis.vertical,
        itemCount: 3,
        itemBuilder: (context, index) {
          return Column(children: [
            Image.network('https://codingapple1.github.io/kona.jpg'),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              Row(
                children: [
                  TextButton(onPressed: () {addOne();}, child: Text('좋아요 : ')),
                  Text(likes.toString())
                ],
              ),
              Text('글쓴이 : ', textAlign: TextAlign.start,),
              Text('글내용 :  ', textAlign: TextAlign.start),

            ],)
          ]);
          },
    );
  }
}



