import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qrscan/qrscan.dart' as scanner;
import 'dart:typed_data';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() => runApp(AttendanceTracker());

class AttendanceTracker extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: new ATLoginPage(),
        routes: <String, WidgetBuilder>{
          '/landingPage': (context) => landingPage(),
        },
        theme: new ThemeData(primarySwatch: Colors.blue));
  }
}

class ATLoginPage extends StatefulWidget {
  @override
  State createState() => ATLoginPageState();
}

class ATLoginPageState extends State<ATLoginPage> {
  bool _isLoading = false;
  AnimationController _logoAnimationController;
  Animation<double> _logoAnimation;

  TextEditingController emailController = new TextEditingController();
  TextEditingController passwordController = new TextEditingController();

  signIn(String email, password) async {
    var jsonData = null;
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString("email", email); 
    var response = await http.post(
        "https://attendance.page/api.php?type=0&student=" +
            email +
            "&password=" +
            password);
    if (response.body == "{\"status\":\"success\"}") {
      jsonData = json.decode(response.body);
      setState(() {
        _isLoading = false;
        sharedPreferences.setString("token", "a");
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (BuildContext context) => landingPage()),
            (Route<dynamic> route) => false);
      });
    } else {
      print(response.body);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false, 
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
                  height: 148.0,
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
                child: _isLoading ? Center(child: CircularProgressIndicator()) : Container(
                  padding: const EdgeInsets.all(40.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      TextFormField(
                        controller: emailController,
                        decoration: InputDecoration(
                          labelText: "Enter Email",
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),

                      TextFormField(
                        controller: passwordController,
                        decoration: InputDecoration(
                          labelText: "Password",
                        ),
                        keyboardType: TextInputType.text,
                        obscureText: true,
                      ),

                      Padding(padding: const EdgeInsets.only(top: 20.0)),
                      MaterialButton(
                        height: 38.0,
                        minWidth: 100.0,
                        color: Colors.blue,
                        textColor: Colors.white,
                        child: Text("Login"),
                        onPressed: () {
                          setState(() {
                            _isLoading = true;
                          }); 
                          signIn(emailController.text, passwordController.text);
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
  SharedPreferences sharedPreferences;

  Future _scan() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String email = sharedPreferences.getString("email");
    var now = DateTime.now();
    String dateTime = now.toString();  
    var barcode = await scanner.scan();
    setState(() => this.barcode = barcode);
    var response = await http.post("https://attendance.page/api.php?type=2&class=5dd19bd5c9ce7&student="+email+"&seat="+barcode+"&time="+dateTime); 
    print(dateTime); 
    if (response.body == "{\"status\":\"success\"}")
    {
      print("Success"); 
    }
    else{
      print("Error"); 
    }
  }

  @override
  initState() {
    super.initState();
    checkLoginStatus();
  }

  checkLoginStatus() async {
    sharedPreferences = await SharedPreferences.getInstance();
    if (sharedPreferences.getString("token") == null) {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (BuildContext context) => ATLoginPage()),
          (Route<dynamic> route) => false);
    }
  }

  @override
  Widget build(BuildContext context) { 
    return Scaffold(
      appBar: AppBar(
        title: Text("Welcome User"),
        actions: <Widget>[
          FlatButton(
            onPressed: () {
              sharedPreferences.clear();
              sharedPreferences.commit();
            },
            child: Text("Log Out", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
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

