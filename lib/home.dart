import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:pewdiepievstseries/channel.dart';

final color = const Color(0xFF3c415e);
final lightDarkGrey = const Color(0xFF738598);

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final oneSec = const Duration(seconds: 1);
  final format = new NumberFormat("#,##0", "en_US");
  Channel channelP;
  Channel channelT;
  bool onGoingRequest = false;
  bool isDataAvailable = false;

  void fetchPost() async {
    onGoingRequest = true;
    final responseP = await http.get(
        'https://www.googleapis.com/youtube/v3/channels/?part=snippet%2CcontentDetails%2Cstatistics%20&forUsername=PewDiePie&key=<YOUR_API_KEY>');
    final responseT = await http.get(
        'https://www.googleapis.com/youtube/v3/channels/?part=snippet%2CcontentDetails%2Cstatistics%20&forUsername=tseries&key=<YOUR_API_KEY>');
    print(responseP.body);
    if (responseP.statusCode == 200 && responseT.statusCode == 200) {
      setState(() {
        channelP = Channel.fromJSON(json.decode(responseP.body));
        channelT = Channel.fromJSON(json.decode(responseT.body));
        isDataAvailable = true;
        onGoingRequest = false;
      });
    } else {
      throw Exception('Failed to load channel data');
      //<YOUR_API_KEY>
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    fetchPost();
    Timer.periodic(oneSec, (Timer t) {
      fetchPost();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightDarkGrey,
      appBar: AppBar(
        title: Text('PewDiePie VS T-Series'),
        backgroundColor: color,
      ),
      body: Center(
        child: isDataAvailable
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  ClipRRect(
                    child: Image.network(
                      channelP.imgUrl,
                      width: 100,
                      height: 100,
                    ),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  Padding(
                    child: Text(
                      '${channelP.name}',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 25.0,
                          fontFamily: 'OSWALD'),
                    ),
                    padding: const EdgeInsets.only(top: 20.0, bottom: 20.0),
                  ),
                  //Text('Subscriber Count : ${channelP.subCount}',
                  Text('Subscriber Count : ${format.format(channelP.subCount)}',

                      //  print("Eg. 1: ${oCcy.format(123456789.75)}");
                      style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'OSWALD',
                          fontSize: 20.0)),
                  Padding(
                    child: Text('VS',
                        style: TextStyle(
                            color: Colors.blue,
                            fontFamily: 'OSWALD',
                            fontSize: 40.0)),
                    padding: EdgeInsets.all(30.0),
                  ),
                  ClipRRect(
                    child: Image.network(
                      channelT.imgUrl,
                      width: 100,
                      height: 100,
                    ),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  Padding(
                    child: Text('${channelT.name}',
                        style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'OSWALD',
                            fontSize: 25.0)),
                    padding: EdgeInsets.only(top: 20.0, bottom: 20.0),
                  ),
                  Text('Subscriber Count : ${format.format(channelT.subCount)}',
                      style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'OSWALD',
                          fontSize: 20.0)),
                ],
              )
            : CircularProgressIndicator(),
      ),
    );
  }
}
