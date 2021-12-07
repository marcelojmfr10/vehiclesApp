import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';

import 'package:vehicles_app/components/loader_component.dart';
import 'package:vehicles_app/helpers/api_helper.dart';
import 'package:vehicles_app/models/document_type.dart';
import 'package:vehicles_app/models/response.dart';
import 'package:vehicles_app/models/token.dart';
import 'package:vehicles_app/models/user.dart';
import 'package:vehicles_app/screens/user_info_screen.dart';
import 'package:vehicles_app/screens/user_screen.dart';

class UsersScreen extends StatefulWidget {
  final Token token;

  UsersScreen({required this.token});

  @override
  _UsersScreenState createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  List<User> _users = [];
  bool _showLoader = false;

  bool _isFiltered = false;
  String _search = '';

  @override
  void initState() {
    // TODO: implement initState
    // se llama cuando la pantalla cambia (cada que la página cargue)
    super.initState();
    _getUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Usuarios'),
        actions: <Widget>[
          _isFiltered
              ? IconButton(
                  onPressed: _removeFilter, icon: Icon(Icons.filter_none))
              : IconButton(
                  onPressed: _showFilter, icon: Icon(Icons.filter_alt)),
        ],
      ),
      body: Center(
        child: _showLoader
            ? LoaderComponent(text: 'Por favor espere...')
            : _getContent(),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => _goAdd(),
        // {
        // Navigator.push(
        //     context,
        //     MaterialPageRoute(
        //         builder: (context) => ProcedureScreen(
        //             token: widget.token,
        //             procedure: Procedure(id: 0, description: '', price: 0))));
        // },
      ),
    );
  }

  Future<Null> _getUsers() async {
    setState(() {
      _showLoader = true;
    });

    // validar la conexión a internet
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      setState(() {
        _showLoader = false;
      });

      await showAlertDialog(
          context: context,
          title: 'Error',
          message: 'Verifica que estés conectado a internet.',
          actions: <AlertDialogAction>[
            AlertDialogAction(key: null, label: 'Aceptar')
          ]);

      return;
    }

    Response response = await ApiHelper.getUsers(widget.token.token);

    // var url = Uri.parse('${Constants.apiUrl}/api/Procedures');
    // var response = await http.get(
    //   url,
    //   headers: {
    //     'content-type': 'application/json',
    //     'accept': 'application/json',
    //     'authorization': 'bearer ${widget.token.token}',
    //   },
    // );

    setState(() {
      _showLoader = false;
    });

    // var body = response.body;
    // var decodedJson = jsonDecode(body);
    // if (decodedJson != null) {
    //   for (var item in decodedJson) {
    //     _procedures.add(Procedure.fromJson(item));
    //   }
    // }

    if (!response.isSuccess) {
      await showAlertDialog(
          context: context,
          title: 'Error',
          message: response.message,
          actions: <AlertDialogAction>[
            AlertDialogAction(key: null, label: 'Aceptar')
          ]);
      return;
    }

    setState(() {
      _users = response.result;
    });
  }

  Widget _getContent() {
    return _users.length == 0 ? _noContent() : _getListView();
  }

  Widget _noContent() {
    return Center(
      child: Container(
        margin: EdgeInsets.all(20),
        child: Text(
            _isFiltered
                ? 'No hay usuarios con ese criterio de búsqueda.'
                : 'No hay usuarios registrados.',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            )),
      ),
    );
  }

  Widget _getListView() {
    return RefreshIndicator(
      onRefresh: _getUsers,
      child: ListView(
        children: _users.map((e) {
          return Card(
            child: InkWell(
              onTap: () => _goInfoUser(e),
              child: Container(
                margin: EdgeInsets.all(10),
                padding: EdgeInsets.all(5),
                child: Row(
                  // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(40),
                      child: FadeInImage(
                        placeholder: AssetImage('assets/vehicles_logo.jpg'),
                        image: NetworkImage(e.imageFullPath),
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Column(
                              children: [
                                Text(e.fullName,
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    )),
                                SizedBox(height: 5),
                                Text(e.email,
                                    style: TextStyle(
                                      fontSize: 14,
                                    )),
                                Text(e.phoneNumber,
                                    style: TextStyle(
                                      fontSize: 14,
                                    )),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  void _showFilter() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            title: Text('Filtrar Usuarios'),
            content: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
              Text(
                  'Escriba las primeras letras del nombre o apellidos del usuario'),
              SizedBox(
                height: 10,
              ),
              TextField(
                autofocus: true,
                decoration: InputDecoration(
                    hintText: 'Criterio de búsqueda...',
                    labelText: 'Buscar',
                    suffixIcon: Icon(Icons.search)),
                onChanged: (value) {
                  _search = value;
                },
              ),
            ]),
            actions: <Widget>[
              TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Cancelar')),
              TextButton(onPressed: () => _filter(), child: Text('Filtrar'))
            ],
          );
        });
  }

  void _removeFilter() {
    setState(() {
      _isFiltered = false;
    });

    _getUsers();
  }

  void _filter() {
    if (_search.isEmpty) {
      return;
    }

    List<User> filteredList = [];
    for (var user in _users) {
      if (user.fullName.toLowerCase().contains(_search.toLowerCase())) {
        filteredList.add(user);
      }
    }

    setState(() {
      _users = filteredList;
      _isFiltered = true;
    });

    Navigator.of(context).pop();
  }

  void _goAdd() async {
    String? result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => UserScreen(
                token: widget.token,
                user: User(
                    firstName: '',
                    lastName: '',
                    documentType: DocumentType(id: 0, description: ''),
                    document: '',
                    address: '',
                    imageId: '',
                    imageFullPath: '',
                    userType: 1,
                    fullName: '',
                    vehicles: [],
                    vehiclesCount: 0,
                    id: '',
                    userName: '',
                    email: '',
                    phoneNumber: ''))));

    if (result == 'yes') {
      _getUsers();
    }
  }

  void _goInfoUser(User user) async {
    String? result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                UserInfoScreen(token: widget.token, user: user)));

    if (result == 'yes') {
      _getUsers();
    }
  }
}
