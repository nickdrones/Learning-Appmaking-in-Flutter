import 'package:flutter/material.dart';
import 'package:get_mac/get_mac.dart'; //get_mac plugin for returning device mac address
import 'package:flutter/services.dart';
import 'package:crypto/crypto.dart'; //crypto plugin for creating hash of mac address
import 'dart:convert'; // for the utf8.encode method
import 'package:location/location.dart'; //plugin for returning GPS location easily
import 'package:wifi_info_plugin/wifi_info_plugin.dart'; //plugin for returning wifi info
import 'dart:async';



void main() {
  runApp(MyApp()); //run app
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Get Device MAC address'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  WifiInfoWrapper _wifiObject; //init the wifi object to be referenced later

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }
  String _platformVersion = 'Unknown'; //temp var for device mac
  String _encodedDeviceID = 'Not Calculated Yet';  //device id will be md5 of mac
  var GPScoords; //init var for holding GPS location
  String macAddr; //init var for wifi AP mac address
  String signalStrength; //init var for AP signal strength
  @override
  void initState() {
    super.initState();
    initPlatformState();
  }
  Future<void> initPlatformState() async {
    String platformVersion;
    var encodedDeviceID; //init temp var for device ID
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformVersion = await GetMac.macAddress; //get mac address, write to temp var
      var bytes = utf8.encode(platformVersion); //encode mac as utf8
      encodedDeviceID =md5.convert(bytes);  //then encode mac as md5 hash
    } on PlatformException {
      platformVersion = 'Failed to get Device MAC Address.'; //if it fails to get mac, print error
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    Location location = new Location(); //init location object

    bool _serviceEnabled;
    PermissionStatus _permissionGranted; //vars for getting location permission
    LocationData _locationData;

    _serviceEnabled = await location.serviceEnabled(); //wait until location is enabled
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission(); //wait until location permission is granted
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _locationData = await location.getLocation(); //actually get current location



    WifiInfoWrapper wifiObject; //init wifi object
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      wifiObject = await  WifiInfoPlugin.wifiDetails; //try getting details written to object

    }
    on PlatformException{

    }
    if (!mounted) return;

    setState(() {

      _wifiObject = wifiObject;
    });


    setState(() {
      _platformVersion = platformVersion; //set device mac
      _encodedDeviceID = encodedDeviceID.toString(); //set device ID
      GPScoords = _locationData.toString();  //set location
      macAddr = _wifiObject!=null?_wifiObject.bssId.toString():"";  //set AP mac address
      signalStrength = _wifiObject!=null?_wifiObject.signalStrength.toString():"";  //set signal strength

    });

  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
//            Text(
//              'You have pushed the button this many times:',
//            ),
            Text(
              '    MAC Address of device: $_platformVersion\n',
            ),
            Text(
              '    Encoded Mac of device: $_encodedDeviceID\n',     //print text on screen
            ),
            Text(
              '    MAC Of Connected AP: $macAddr\n',
            ),
            Text(
              '    Signal Strength Connected AP: $signalStrength\n',
            ),
            Text(
              //    GPS Location
              '       $GPScoords\n',
            ),
//            Text(
//              '$_counter',
//              style: Theme.of(context).textTheme.headline4,
//            ),
          ],
        ),
      ),
//      floatingActionButton: FloatingActionButton(
//        onPressed: _incrementCounter,
//        tooltip: 'Increment',
//        child: Icon(Icons.add),
//      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
