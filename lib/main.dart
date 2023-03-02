import 'package:flutter/material.dart';
import './style.dart' as style;
import 'package:http/http.dart' as http;
import 'dart:convert';  //유틸리티
import 'package:image_picker/image_picker.dart';  //갤러리에서 가져오기
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
      MultiProvider(providers: [
        ChangeNotifierProvider(create: (context) => Store1(),),
        ChangeNotifierProvider(create: (context) => Store2(),)
      ],
        child: MaterialApp(
            theme: style.theme,
            home: MyApp()
        ),
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
  var userContent;
  addUpload(a){
    setState(() {
      userContent = a;
    });
  }

  addMyData(){
    var myData = {
      'id': data.length,
      'image': userImage,
      'likes': 0,
      'date': 'July 25',
      'content': userContent,
      'liked': false,
      'user': 'Me'
    };
    setState(() {
      data.insert(0, myData);
    });
  }

  addLikes(a){
    setState(() {
      data[a]['likes']++;
    });
  }

  var userImage;

  saveData() async {
    var storage = await SharedPreferences.getInstance();  //이미지는 저장 안되는 캐싱 패키지를 사용할것
    storage.setString('name', 'Seol');   //map은 jsonEncoding 이용하여 저장
    var result = storage.getString('name');
    print(result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            actions: [IconButton(
                onPressed: () async {
                  var picker = ImagePicker();
                  var image = await picker.pickImage(source: ImageSource.gallery); //이미지 픽커 사용법
                  if (image != null){
                    userImage = File(image.path);
                  }

                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) {return Upload(userImage : userImage,data: data, addMyData:addMyData,addUpload:addUpload);},) //return 밖에 없느면 {}쓰지않고 ==>
                  );
                },
                icon: Icon(Icons.add_box_outlined))],
            title: Text('Instagram', style: TextStyle(color: Colors.black, fontSize: 20,fontWeight: FontWeight.bold),)),
        body: [page(data: data, addData : addData, addLikes : addLikes), Text('숍')][tab],
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
  const page({Key? key, this.data, this.addData,this.addLikes}) : super(key: key);
  final data, addData, addLikes;

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
          widget.data[index]['image'].runtimeType == String ?
          Image.network(widget.data[index]['image']) : Image.file(widget.data[index]['image']),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(onPressed: () {widget.addLikes(index);}, icon: Icon(Icons.thumb_up_sharp)),
                  Text('${widget.data[index]['likes'].toString()}  좋아요'),

                ],
              ),
              GestureDetector(child:Text(widget.data[index]['user'] , textAlign: TextAlign.start,),
              onLongPress: () {
                Navigator.push(context,
                  MaterialPageRoute(builder: (context) => Profile()));
              },), //Text위젯은 onpressed가 없음
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

class Upload extends StatelessWidget {
  const Upload({Key? key,this.userImage, this.addMyData,this.addUpload,this.data}) : super(key: key);
  final userImage,addMyData,addUpload,data;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
                padding: EdgeInsets.all(10), height: 300,
                child: Image.file(userImage)),
          ),
          TextField(
            onChanged: (value) {addUpload(value);},
            decoration: InputDecoration(
                labelText: '글내용'),
          ),
          Row(mainAxisAlignment: MainAxisAlignment.center ,
            children: [
            IconButton(onPressed: () {Navigator.pop(context);}, icon: Icon(Icons.close)),
            IconButton(onPressed: () {
              addMyData();
              Navigator.pop(context);
              }, icon: Icon(Icons.check)),

          ],),
        ],
      ),
    );
  }
}

/*MaterialApp(
    initialRoute: '/',
    routes: {
      '/': (context) => Text('첫페이지'),
      '/detail': (context) => Text('둘째페이지'),
    },
);  페이지가 많아지면 라우트 방식으로 관리 가능,  Navigator.pushNamed(context, '/detail');로 페이지이동*/

class Profile extends StatelessWidget {
  const Profile({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(context.watch<Store1>().name),
          titleTextStyle: TextStyle(color: Colors.black)),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: ProfileHeader(),),
          SliverGrid(
              delegate: SliverChildBuilderDelegate((context, index) =>
                  Container(
                      child: Image.network('${context.read<Store1>().profileImage[index]}')),
                  childCount: context.watch<Store1>().profileImage.length),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4))
        ],
      ),
    );
  }
}

class Store1 extends ChangeNotifier{
  var name = 'me';
  changeName(){
    name = 'Me2'; //저장소안에서 state변경
    notifyListeners(); //setState같은것
  }
  var follower = 0;
  bool isFollowed = false;
  addFollower(){
    if(isFollowed == false){
      follower++;
      isFollowed = true;
    }
    else{
      follower--;
      isFollowed = false;
    }
    notifyListeners();
  }
  var profileImage = [];
  getData() async {
    var result = await http.get(Uri.parse('https://codingapple1.github.io/app/profile.json'));
    var result2 = jsonDecode(result.body);
    profileImage = result2;
    print(profileImage);
    notifyListeners();
  }
}

class Store2 extends ChangeNotifier{
  
}

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          child: Row (
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CircleAvatar(
                backgroundImage:AssetImage('assets/images/images.png'),
                backgroundColor: Colors.grey,
                radius: 30,
              ),
              Text('                 팔로워 ${context.watch<Store1>().follower} 명',
                  textScaleFactor: 1.3),
              ElevatedButton(
                  onPressed: (){
                    context.read<Store1>().addFollower();
                  },
                  child: Text('팔로우')
              ),
            ],
          ),
        ),
      ],
    );
  }
}

