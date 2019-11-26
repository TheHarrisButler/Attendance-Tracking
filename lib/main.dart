import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qrscan/qrscan.dart' as scanner;
import 'dart:typed_data';

void main() => runApp(AttendanceTracker());

class AttendanceTracker extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: new ATLoginPage(),
        routes: <String, WidgetBuilder> {
          '/landingPage' : (context) => landingPage(),
          '/atQRScanner' : (context) => atQRScanner()
        },
        theme: new ThemeData(primarySwatch: Colors.blue));
  }
}

class ATLoginPage extends StatefulWidget {
  @override
  State createState() => ATLoginPageState();
}

class ATLoginPageState extends State<ATLoginPage> {
  AnimationController _logoAnimationController;
  Animation<double> _logoAnimation;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Image(
            image: AssetImage("assets/grad.jpg"),
            fit: BoxFit.cover,
            color: Colors.black87,
            colorBlendMode: BlendMode.darken,
          ),
          Column(
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(top: 220.0),
                child: Image(
                  image: AssetImage("assets/t-logo.png"),
                  height: 150.0,
                  width: 150.0,
                ),
              ),
              Form(
                  child: Theme(
                data: ThemeData(
                    brightness: Brightness.dark,
                    primarySwatch: Colors.orange,
                    inputDecorationTheme: InputDecorationTheme(
                        labelStyle:
                            TextStyle(color: Colors.white60, fontSize: 20.0))),
                child: Container(
                  padding: const EdgeInsets.all(40.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: "Enter Email",
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: "Password",
                        ),
                        keyboardType: TextInputType.text,
                        obscureText: true,
                      ),
                      Padding(padding: const EdgeInsets.only(top: 20.0)),
                      MaterialButton(
                        height: 40.0,
                        minWidth: 100.0,
                        color: Colors.blue,
                        textColor: Colors.white,
                        child: Text("Login"),
                        onPressed: () {
                          Navigator.pushNamed(context, '/landingPage');
                        },
                        splashColor: Colors.white60,
                      ),
                    ],
                  ),
                ),
              )),
            ],
          )
        ],
      ),
    );
  }
}

class landingPage extends StatefulWidget {
  
  @override
  _landingPageState createState() => _landingPageState();
}

class _landingPageState extends State<landingPage> {
  String barcode = '';
  Uint8List bytes = Uint8List(200);

  Future _scan() async {
    String barcode = await scanner.scan();
    setState(() => this.barcode = barcode);
  }

  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Welcome User")),
      body: Column(
        children: <Widget>[

           Center(
            child: Container(
              margin: EdgeInsets.only(top: 250.0),
              child: MaterialButton(
                color: Colors.blue,
                textColor: Colors.white,
                child: Text("Sign In"),
                onPressed: _scan,
              ),
            ),
          ),

          Center(
            child: Container(
              margin: EdgeInsets.all(10.0),
              child: MaterialButton(
                color: Colors.blue,
                textColor: Colors.white,
                child: Text("Attendance Logs"),
                onPressed: () {},
              ),
            ),
          ),

        ],
      ),
    );
  }
}

class atQRScanner extends StatefulWidget {
   
  @override
  _atQRScannerState createState() => _atQRScannerState();
}

class _atQRScannerState extends State<atQRScanner> {
  
  String barcode = '';
  Uint8List bytes = Uint8List(200);

  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text("QR Scanner"),
      ),
      body: Center(
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: Icon(Icons.camera_alt),
        label: Text("Scan"), 
        onPressed: _scan,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }


  Future _scan() async {
    String barcode = await scanner.scan();
    setState(() => this.barcode = barcode);
  }
}
