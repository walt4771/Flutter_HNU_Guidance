import 'package:flutter/material.dart';
import 'package:html/parser.dart' as parser;
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';


void main() => runApp(MaterialApp(
    theme: ThemeData(
      scaffoldBackgroundColor: Colors.white,
      primaryColor: Colors.lightGreen,
      colorScheme:
        ColorScheme
            .fromSwatch()
            .copyWith(secondary: Colors.lightGreenAccent),
    ),
    home: const MyApp()));

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  Future<List> extractData() async {
    // Getting the response from the targeted url
    final response =
      await http.Client()
          .get(Uri.parse('http://www.hannam.ac.kr/kor/community/community_01_4.html'));

    // Status Code 200 means response has been received successfully
    if (response.statusCode == 200) {

      // Getting the html document from the response
      var document = parser.parse(response.body);

        // Scraping the first article title
        var responseString1 = document
            .getElementsByClassName('simple-type')[0]
            .getElementsByTagName('tbody')[0]
            .getElementsByTagName("a");

        var links = document
            .getElementsByClassName('simple-type')[0]
            .getElementsByTagName('tbody')[0]
            .getElementsByTagName('a')
            .where((e) => e.attributes.containsKey('href'))
            .map((e) => e.attributes['href'])
            .toList();

        print(responseString1[1].text);

        return [ responseString1, links ];
    } else {
      return [ 'ERROR: ${response.statusCode}.'];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('학사정보'),
          backgroundColor: const Color.fromARGB(255, 107, 179, 73),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder(
            future: extractData(),
            builder:(context, AsyncSnapshot snapshot) {
              if (snapshot.hasData == false) {
                return const CircularProgressIndicator();
              }else{
                return ListView.builder(
                    padding: const EdgeInsets.all(2),
                    itemCount: snapshot.data[0].length,
                    itemBuilder: (BuildContext context, int index) {
                      return InkWell(
                        onTap: () => launchUrl(
                            Uri.parse("http://www.hannam.ac.kr${snapshot.data[1][index]}")
                        ),
                        child: SizedBox(
                          height: 50,
                          child: Center(child: Text('${snapshot.data[0][index].text}')),
                        )
                      );
                    }
                );
              }
            }
        )
      ),
    );
  }
}