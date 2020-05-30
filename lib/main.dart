import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';



//
Future<List<Photo>> fetchPhotos(http.Client client) async{
  final response =
  await client.get('https://jsonplaceholder.typicode.com/photos');
  // compute 함수를 사용하여 parsePhotos를 별도 isolate에서 수행 == flutter에서는 subThread가 아닌 isolate이라 부른다. 
  return compute(parsePhotos,response.body);//postman에서 볼 수 있는 내용이 body부분. 
  //return parsePhotos(response.body); //이걸 사용하면 mainThread에서 작동됨. 
}

//response.body함수가 들어가진다, List<Photo>를 반환.  
//json은 import 'dart:convert';에서 받아옴. 
List<Photo> parsePhotos(String responseBody){
   final parsed = json.decode(responseBody).cast<Map<String,dynamic>>();//decode -> Map<String, dynamic>으로 변환. 
  return parsed.map<Photo>((json) => Photo.fromJson(json)).toList(); //json은 response.body의 여러 클래스 중 하나의 json을 의미함. 

}

//response.body의 
class Photo{
  final int albumId;
  final int id;
  final String title;
  final String url;
  final String thumbnailUrl;

  Photo({this.albumId, this.id, this.title, this.url, this.thumbnailUrl} );
  
  //json data -> object로 변경하는 함수. 
  factory Photo.fromJson(Map<String,dynamic> json){
    return Photo(
      albumId : json['albumId'] as int,
      id : json['id'] as int,
      title : json['title'] as String,
      url : json['url'] as String,
      thumbnailUrl : json['thumbnailUrl'] as String,
    );
  }
}


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final appTitle = "Isolate Demo";
    
    return MaterialApp(
      title: appTitle,
      home: MyHomePage(title:appTitle),
    );
  }
}

class MyHomePage extends StatelessWidget {
  final String title;
  const MyHomePage({Key key, this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Column(
        children: <Widget>[
          SizedBox(height: 200, width: 200, child: CircularProgressIndicator(),),//UI 담당 - MainThread. 
          Expanded(child: FutureBuilder<List<Photo>>(//<List<Photo>>을 가짐. 
            future: fetchPhotos(http.Client()),//반환값이 FutureBuilder<List<Photo>>여야한다. 
            builder: (context, snapshot){//future의 정보가 snaphost으로 전달. 
                if (snapshot.hasError) print(snapshot.error);
                return snapshot.hasData //true or false 
                ? PhotosList(photos:snapshot.data)//Builder썼다는 것 -> List를 쓴다는 것. 
                : Center(child: CircularProgressIndicator());
            })),
        ],
      ),
    );
  }
}

class PhotosList extends StatelessWidget {
  final List<Photo> photos;

  PhotosList({Key key, this.photos}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
      ),
      itemCount: photos.length,
      itemBuilder: (context, index) {
        return Image.network(photos[index].thumbnailUrl);
      },
    );
  }
}
