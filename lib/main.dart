import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'aboutGrade.dart' as aboutGrade;
import 'examRegister.dart' as examRegister;
import 'dart:convert';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'globals.dart' as globals;
import 'widgets/navDrawer.dart' as navDrawer;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SAS',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const MyHomePage(title: 'Sistema de acompanhamento sintomático - USP'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool formVisible = false;
  var user = {};
  ValueNotifier<bool> isDialOpen = ValueNotifier(true);

  final nameController = TextEditingController();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final cpfController = TextEditingController();


  @override
  void dispose() {
    nameController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    cpfController.dispose();
    super.dispose();
  }

  void _login() async {
    var url = Uri.parse(globals.api + '/login');
    var response = await http.post(
        url,
        headers: {
          "Accept": "application/json",
          "Access-Control_Allow_Origin": "*"
        },
        body: {
          "username": usernameController.text,
          "password": passwordController.text
        }
    );

    if (response.statusCode == 200) {
      Navigator.of(context, rootNavigator: true).pop();
      Map<String, dynamic> user_json = jsonDecode(response.body);
      setState(() {
        user["token"] = user_json["token"];
        user["nome"] = user_json["nome"];
        user["cpf"] = user_json["cpf"];
        globals.cpf = user["cpf"];
        globals.token = user["token"];
        globals.usuarioLogado = true;
        _calculateRisk();
      });
      final snackBar = SnackBar(
        content: Text('Bem vindo(a), ${user["nome"]}!'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else {
      final snackBar = SnackBar(
        content: Text(response.body),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  void _register() async {
    var url = Uri.parse(globals.api + '/register');
    var response = await http.post(
        url,
        headers: {
          "Accept": "application/json",
          "Access-Control_Allow_Origin": "*"
        },
        body: {
          "username": usernameController.text,
          "name": nameController.text,
          "password": passwordController.text,
          "cpf": cpfController.text
        }
    );

    if (response.statusCode == 200) {
      Navigator.of(context, rootNavigator: true).pop();
      Map<String, dynamic> user_json = jsonDecode(response.body);
      setState(() {
        user["token"] = user_json["token"];
        user["nome"] = user_json["nome"];
        globals.usuarioLogado = true;
      });
      final snackBar = SnackBar(
        content: Text('Bem vindo(a), ${user["nome"]}!'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else {
      final snackBar = SnackBar(
        content: Text(response.body),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  void _calculateRisk() async {
    user["nota_seguranca"] = 5;
  }

  void _onGoToAboutGradePage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const aboutGrade.SecondRoute()),
    );
  }

  void _onGoToExamRegister() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const examRegister.ExamPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: globals.usuarioLogado ? navDrawer.NavDrawer() : null,
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
          child:
          globals.usuarioLogado ?
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                  'Bom dia, ${user["nome"]}!',
                  style: Theme
                      .of(context)
                      .textTheme
                      .headline6
              ),
              const SizedBox(height: 25),
              Image.asset('assets/images/coronavirus.webp', width: 100),
              const SizedBox(height: 25),

              Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      height: 45,
                      alignment: Alignment.center,
                      child: Row(
                        children: [
                          const Text('Sua'),
                          TextButton(
                              onPressed: _onGoToAboutGradePage,
                              child: Text('nota de segurança')
                          ),
                          const Text('hoje é:')
                        ],
                      ),
                    ),
                  ]
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                      user["nota_seguranca"].toString(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black54,
                        fontSize: 26
                      ),
                  ),
                  Padding(
                      padding: EdgeInsets.only(top: 8),
                      child:
                        Text(
                          " /10",
                          style: TextStyle(
                              color: Colors.black54,
                              fontSize: 14
                          ),
                        )
                  )
                ]
              )
            ],
          )
              :
          Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        height: 40,
                        alignment: Alignment.center,
                        child: Row(
                          children: [
                            TextButton(
                              child: Text('Faça login'),
                              onPressed: () {
                                Navigator.of(context).restorablePush(
                                    _loginDialogBuilder);
                              },
                            ),
                            const Text('ou'),
                            TextButton(
                              child: Text('cadastre-se'),
                              onPressed: () {
                                Navigator.of(context).restorablePush(
                                    _registerDialogBuilder);
                              },
                            ),
                            const Text('para acessar a plataforma!')
                          ],
                        ),
                      ),
                    ]
                )
              ]
          )
      ),
      floatingActionButton: globals.usuarioLogado ? SpeedDial(
        animatedIcon: AnimatedIcons.add_event,
        openCloseDial: isDialOpen,
        backgroundColor: Colors.redAccent,
        overlayColor: Colors.grey,
        overlayOpacity: 0.5,
        spacing: 15,
        spaceBetweenChildren: 15,
        closeManually: false,
        children: [
          SpeedDialChild(
              child: Icon(Icons.picture_as_pdf_rounded),
              label: 'Atestado/Exame',
              backgroundColor: Colors.blue,
              onTap: (){
                setState(() {
                  isDialOpen = ValueNotifier(false);
                  _onGoToExamRegister();
                });
              }
          ),
          SpeedDialChild(
              child: Icon(Icons.wash),
              label: 'Observação/Reclamação',
              backgroundColor: Colors.blue,
              onTap: (){
                setState(() {
                  isDialOpen = ValueNotifier(false);
                  _onGoToExamRegister();
                });
              }
          ),
          SpeedDialChild(
              child: Icon(Icons.waving_hand),
              label: 'Presença',
              backgroundColor: Colors.blue,
              onTap: (){
                setState(() {
                  isDialOpen = ValueNotifier(false);
                  _onGoToExamRegister();
                });
              }
          )

        ],
      ) : null
    );
  }

  Route<Object?> _loginDialogBuilder(BuildContext context, Object? arguments) {
    return RawDialogRoute<void>(
      pageBuilder: (BuildContext context,
          Animation<double> animation,
          Animation<double> secondaryAnimation,) {
        return SimpleDialog(
            titleTextStyle: TextStyle(
                color: Colors.green,
                fontSize: 20
            ),
            titlePadding: EdgeInsets.fromLTRB(12.0, 12.0, 0.0, 5.0),
            contentPadding: EdgeInsets.fromLTRB(10.0, 12.0, 10.0, 16.0),
            title: Text('Login'),
            children: <Widget>[
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    TextField(
                      controller: usernameController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'CPF ou e-mail',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      obscureText: true,
                      enableSuggestions: false,
                      autocorrect: false,
                      controller: passwordController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Senha',
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      child: Align(
                          alignment: Alignment.topRight,
                          child: ElevatedButton(
                              onPressed: _login,
                              child: Text("Entrar")
                          )
                      ),
                    ),
                  ],
                ),
              ),
            ]
        );
      },
    );
  }

  Route<Object?> _registerDialogBuilder(BuildContext context, Object? arguments) {
    return RawDialogRoute<void>(
      pageBuilder: (BuildContext context,
          Animation<double> animation,
          Animation<double> secondaryAnimation,) {
        return SimpleDialog(
            titleTextStyle: TextStyle(
                color: Colors.green,
                fontSize: 20
            ),
            titlePadding: EdgeInsets.fromLTRB(12.0, 12.0, 0.0, 5.0),
            contentPadding: EdgeInsets.fromLTRB(10.0, 12.0, 10.0, 16.0),
            title: Text('Cadastro'),
            children: <Widget>[
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Nome ou apelido',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: usernameController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'E-mail',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: cpfController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'CPF',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      obscureText: true,
                      enableSuggestions: false,
                      autocorrect: false,
                      controller: passwordController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Senha',
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      child: Align(
                          alignment: Alignment.topRight,
                          child: ElevatedButton(
                              onPressed: _register,
                              child: Text("Registrar")
                          )
                      ),
                    ),
                  ],
                ),
              ),
            ]
        );
      },
    );
  }
}
