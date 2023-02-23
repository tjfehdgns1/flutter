import 'package:flutter/material.dart';
import './style.dart' as style;
import 'package:http/http.dart' as http;
import 'dart:convert';  //유틸리티

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

  var data = [];

  getData() async {
    var site = await http.get(Uri.parse('https://codingapple1.github.io/app/data.json'));
    if(site.statusCode == 200){print('서버 좋음');}
    else{print('서버 이상함');}

    var result = jsonDecode(site.body);
    setState(() {
      data = result;
    });
    print(site.body);
    print(result[0]['likes']);
  }  //initState 안에 async 사용불가
  @override
  void initState() {
    super.initState();
    getData();
  } //  특정 위젯이 로드되자마자 코드를 실행

  var tab = 0;
  void _onItemTapped(int index) {
    setState(() {
      tab = index;
    });
  }

  addData(a){
    setState(() {
      data.add(a);
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
      body: [page(data: data, addData : addData), Text('숍')][tab],
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
  const page({Key? key, this.data, this.addData}) : super(key: key);
  final data, addData;

  @override
  State<page> createState() => _pageState();
}

class _pageState extends State<page> {

  var scroll = ScrollController();

  getMore() async {
    var result = await http.get(Uri.parse('https://codingapple1.github.io/app/more1.json'));
    var result2 = jsonDecode(result.body);
    widget.addData(result2);
  }

  @override
  void initState(){
    super.initState();
    scroll.addListener(() {
      print(scroll.position.pixels);
      if(scroll.position.pixels == scroll.position.maxScrollExtent){
        print('마지막 스크롤');
        setState(() {
          getMore();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.data.isNotEmpty){
      return ListView.builder(
      scrollDirection: Axis.vertical,
      controller: scroll,
      padding: EdgeInsets.all(10),
      itemCount: widget.data.length,
      itemBuilder: (context, index) {
        return Column(children: [
          Image.network(widget.data[index]['image']),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(onPressed: () {}, icon: Icon(Icons.thumb_up_sharp)),  //좋아요 state 못바꿈
                  Text('${widget.data[index]['likes'].toString()}  좋아요')
                ],
              ),
              Text(widget.data[index]['user'] , textAlign: TextAlign.start,),
              Text(widget.data[index]['content'], textAlign: TextAlign.start),
            ],)
        ]);
      },
    );

    } else {
      return Text('로딩중');
    }
  }
}



