import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

const request = "https://api.hgbrasil.com/finance?key=216bd79d";
// parte 01 para desenvolver
void main() async {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Home(),
  ));
}
//parte 02 para desenvolver
class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  final realController = TextEditingController();
  final dolarController = TextEditingController();
  final euroController = TextEditingController();

  double dolar = 0.0;
  double euro = 0.0;

  void _clearAll(){
    realController.text = "";
    dolarController.text = "";
    euroController.text = "";
  }

  void _realchanged(String text){
    if(text.isEmpty) {
      _clearAll();
      return;
    }
    double real = double.parse(text);
    dolarController.text = (real/dolar).toStringAsFixed(2);
    euroController.text = (real/euro).toStringAsFixed(2);

  }

  void _dolarchanged(String text){
    if(text.isEmpty) {
      _clearAll();
      return;
    }

    double dolar = double.parse(text);
    realController.text = (dolar * this.dolar).toStringAsFixed(2);
    euroController.text = (dolar * this.dolar/euro).toStringAsFixed(2);
  }
  void _eurochanged(String text){
    if(text.isEmpty) {
      _clearAll();
      return;
    }
    double euro = double.parse(text);
    realController.text = (euro * this.euro).toStringAsFixed(2);
    dolarController.text = (euro * this.euro / dolar).toStringAsFixed(2);
  }


  late Future<Map> _dataFuture;

  @override
  void initState() {
    super.initState();
    _dataFuture = getData();
  }


  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "\$ Cambio.Net \$",
          style: TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.italic,
            color: Colors.yellowAccent,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.amber,
      ),
      backgroundColor: Colors.white,
      body: FutureBuilder<Map>(
        future: _dataFuture,
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Center(
                child: Text(
                  "Carregando Dados...",
                  style: TextStyle(color: Colors.amber, fontSize: 25.0),
                  textAlign: TextAlign.center,
                ),
              );
            default:
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    "Erro ao carregar dados :(",
                    style: TextStyle(color: Colors.amber, fontSize: 25.0),
                    textAlign: TextAlign.center,
                  ),
                );
              } else {
                dolar = snapshot.data ?["results"]["currencies"]["USD"]["buy"];
                euro = snapshot.data ?["results"]["currencies"]["EUR"]["buy"];
                return SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: 10),
                      Icon(Icons.monetization_on_outlined, size: 140.0,color: Colors.amber,),
                      Divider(),
                      buildtextfield("Reais", "R\$ 25.00", realController, _realchanged ),
                      Divider(),
                      buildtextfield("Dólares", "U\$ 25.00", dolarController,_dolarchanged ),
                      Divider(),
                      buildtextfield("Euros", "25.00 €", euroController,_eurochanged),
                    ],


                  )); // Aqui você pode adicionar o widget que precisa para mostrar os dados
              }
          }
        },
      ),
    );
  }
}

Widget buildtextfield(String label, String hint, TextEditingController c, void Function(String) funcao ){

  return  TextField(
    controller: c,
    keyboardType: TextInputType.number,
    decoration: InputDecoration(

      labelText: label,
      labelStyle: TextStyle(color: Colors.amber,fontSize: 30, fontWeight:FontWeight.w700),

      hintText: hint,
      border: OutlineInputBorder(),
      focusedBorder: OutlineInputBorder(

        borderSide: BorderSide(

          color: Colors.amber,
          width: 2,

        ),

      ),
      enabledBorder: OutlineInputBorder(

        borderSide: BorderSide(

            color: Colors.amber,
            width: 2

        ),

      ),
      floatingLabelBehavior: FloatingLabelBehavior.always,

    ),
    onChanged: funcao,
  );

}

Future<Map> getData() async {
  http.Response response = await http.get(Uri.parse(request));
  return json.decode(response.body);
}

