import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:async';
import 'dart:convert';

void main() {
  runApp(ListaTarefas());
}

class ListaTarefas extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List _listaTarefas = [];
  Map<String, dynamic> _ultimaTarefaRemovida = Map();
  TextEditingController _controllerTarefa = TextEditingController();

  Future<File> _getFile() async {
    final diretorio = await getApplicationDocumentsDirectory();
    return File("${diretorio.path}/dados.json");
  }

  Future<String> _lerArquivo() async {
    try {
      final arquivo = await _getFile();
      return arquivo.readAsString();
    } catch (e) {
      return null;
    }
  }

  _salvarTarefa() {
    String textoDigitado = _controllerTarefa.text;
    Map<String, dynamic> tarefa = Map();
    tarefa["titulo"] = textoDigitado;
    tarefa["realizada"] = false;
    setState(() {
      _listaTarefas.add(tarefa);
    });

    _salvarArquivo();
    _controllerTarefa.text = "";
  }

  _salvarArquivo() async {
    var arquivo = await _getFile();

    String jsonData = json.encode(_listaTarefas);
    arquivo.writeAsString(jsonData);
  }

  @override
  void initState() {
    super.initState();
    _lerArquivo().then((dados) {
      setState(() {
        _listaTarefas = json.decode(dados);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.purple,
          title: Text("Lista de Tarefas"),
        ),
        //bottomNavigationBar: BottomNavigationBar(items: []),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Expanded(
                  child: ListView.builder(
                      itemCount: _listaTarefas.length,
                      itemBuilder: (context, index) {
                        return criarItemLista(context, index);
                      }
                      )
              )
            ],
          ),
        ),
        /* ----- Funde o botão a bottomNavigationBar: ---- */
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        /*--------------------------------*/
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: Colors.purple,
          elevation: 6.0,
          tooltip: 'Nova tarefa',
          icon: Icon(Icons.add),
          label: Text('Nova'),
          shape: BeveledRectangleBorder(borderRadius: BorderRadius.circular(5)),
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text('Adicionar Tarefas'),
                  content: TextField(
                    controller: _controllerTarefa,
                    decoration: InputDecoration(labelText: "Digite sua tarefa"),
                    onChanged: (value) {},
                  ),
                  actions: [
                    FlatButton(
                      child: Text("Cancelar"),
                      onPressed: () => Navigator.pop(context),
                    ),
                    FlatButton(
                      child: Text("Salvar"),
                      onPressed: () {
                        _salvarTarefa();
                        Navigator.pop(context);
                      },
                    )
                  ],
                );
              },
            );
          },
        ));
  }

  Widget criarItemLista(context, index) {

    return Dismissible(
      key: Key(DateTime.now().millisecondsSinceEpoch.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        padding: EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Icon(Icons.delete, color: Colors.white),

          ],
        ),
      ),
      onDismissed: (direction) {

        //recuperar último item excluído
        _ultimaTarefaRemovida = _listaTarefas[index];
        _listaTarefas.removeAt(index);
        _salvarArquivo();

        //snackbar
        final snackbar = SnackBar(
            duration: Duration(seconds: 5),
            backgroundColor: Colors.green,
            content: Text("Tarefa removida!!"),
            action: SnackBarAction(
              label: "Desfazer",
              onPressed: () {
                //Insere novamente na lista
                setState(() {
                  _listaTarefas.insert(index, _ultimaTarefaRemovida);
                  _salvarArquivo();
                });

              },
          ),
        );
        Scaffold.of(context).showSnackBar(snackbar);

      },
      child: CheckboxListTile(
        title: Text(_listaTarefas[index]['titulo']),
        value: _listaTarefas[index]['realizada'],
        onChanged: (value) {
          setState(() {
            _listaTarefas[index]['realizada'] = value;
          });
          _salvarArquivo();
        },
      ),
    );
  }
}
