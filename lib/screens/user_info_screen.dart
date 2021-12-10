import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';

import 'package:vehicles_app/components/loader_component.dart';
import 'package:vehicles_app/helpers/api_helper.dart';
import 'package:vehicles_app/models/response.dart';
import 'package:vehicles_app/models/token.dart';
import 'package:vehicles_app/models/user.dart';
import 'package:vehicles_app/screens/user_screen.dart';

class UserInfoScreen extends StatefulWidget {
  final Token token;
  final User user;

  UserInfoScreen({required this.token, required this.user});

  @override
  _UserInfoScreenState createState() => _UserInfoScreenState();
}

class _UserInfoScreenState extends State<UserInfoScreen> {
  bool _showLoader = false;
  late User _user;

  @override
  void initState() {
    super.initState();
    _user = widget.user;
    _getUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_user.fullName)),
      body: Center(
        child:
            // _showButtons(),
            _showLoader
                ? LoaderComponent(text: 'Por favor espere...')
                : _getContent(),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => _goAdd(),
      ),
    );
  }

  Widget _showUserInfo() {
    return Container(
      margin: EdgeInsets.all(10),
      padding: EdgeInsets.all(5),
      child: Row(
        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Stack(
            children: <Widget>[
              ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: FadeInImage(
                  placeholder: AssetImage('assets/vehicles_logo.jpg'),
                  image: NetworkImage(_user.imageFullPath),
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                  bottom: 0,
                  left: 60,
                  child: InkWell(
                    onTap: () => _goEdit(),
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                            color: Colors.green[50],
                            height: 40,
                            width: 40,
                            child: Icon(Icons.edit,
                                size: 30, color: Colors.blue))),
                  )),
            ],
          ),
          Expanded(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Row(
                          children: <Widget>[
                            Text(
                              'Email: ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(_user.email,
                                style: TextStyle(
                                  fontSize: 14,
                                )),
                          ],
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Row(
                          children: <Widget>[
                            Text(
                              'Tipo documento: ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(_user.documentType.description,
                                style: TextStyle(
                                  fontSize: 14,
                                )),
                          ],
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Row(
                          children: <Widget>[
                            Text(
                              'Documento: ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(_user.document,
                                style: TextStyle(
                                  fontSize: 14,
                                )),
                          ],
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Row(
                          children: <Widget>[
                            Text(
                              'Dirección: ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(_user.address,
                                style: TextStyle(
                                  fontSize: 14,
                                )),
                          ],
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Row(
                          children: <Widget>[
                            Text(
                              'Teléfono: ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(_user.phoneNumber,
                                style: TextStyle(
                                  fontSize: 14,
                                )),
                          ],
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Row(
                          children: <Widget>[
                            Text(
                              '# Vehículos: ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(_user.vehiclesCount.toString(),
                                style: TextStyle(
                                  fontSize: 14,
                                )),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _showButtons() {
    return Container(
      margin: EdgeInsets.only(left: 10, right: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          _showEditUserButton(),
          SizedBox(
            width: 20,
          ),
          _showAddVehicleButton()
        ],
      ),
    );
  }

  Widget _showEditUserButton() {
    return Expanded(
        child: ElevatedButton(
            onPressed: () => _goEdit(),
            style: ButtonStyle(backgroundColor:
                MaterialStateProperty.resolveWith<Color>(
                    (Set<MaterialState> states) {
              return Color(0xFF120E43);
            })),
            child: Text('Editar Usuario')));
  }

  Widget _showAddVehicleButton() {
    return Expanded(
      child: ElevatedButton(
          onPressed: () {},
          style: ButtonStyle(backgroundColor:
              MaterialStateProperty.resolveWith<Color>(
                  (Set<MaterialState> states) {
            return Color(0xFFE03B8B);
          })),
          child: Text('Agregar Vehículo')),
    );
  }

  void _goEdit() async {
    String? result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                UserScreen(token: widget.token, user: _user)));

    if (result == 'yes') {
      // TODO: Pending refresh user info
    }
  }

  Future<Null> _getUser() async {
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

    Response response = await ApiHelper.getUser(widget.token, _user.id);

    setState(() {
      _showLoader = false;
    });

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
      _user = response.result;
    });
  }

  _goAdd() {}

  Widget _getContent() {
    return Column(
      children: <Widget>[
        _showUserInfo(),
        Expanded(
            child: _user.vehicles.length == 0 ? _noContent() : _getListView()),
      ],
    );
  }

  Widget _getListView() {
    return RefreshIndicator(
      child: ListView(
        children: _user.vehicles.map((e) {
          return Card(
              child: InkWell(
            child: Container(
                margin: EdgeInsets.all(10),
                padding: EdgeInsets.all(5),
                child: Row(
                  children: <Widget>[
                    FadeInImage(
                        placeholder: AssetImage('assets/vehicles_logo.jpg'),
                        image: NetworkImage(e.imageFullPath),
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover),
                    Expanded(
                        child: Container(
                            margin: EdgeInsets.symmetric(horizontal: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Column(
                                  children: <Widget>[
                                    Text(e.plaque,
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        )),
                                    Row(
                                      children: <Widget>[
                                        Text(e.vehicleType.description,
                                            style: TextStyle(
                                              fontSize: 14,
                                            )),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Text(e.brand.description,
                                            style: TextStyle(
                                              fontSize: 14,
                                            )),
                                      ],
                                    ),
                                    Row(
                                      children: <Widget>[
                                        Text(e.line,
                                            style: TextStyle(
                                              fontSize: 14,
                                            )),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Text(e.color,
                                            style: TextStyle(
                                              fontSize: 14,
                                            )),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ))),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 40,
                    ),
                  ],
                )),
            onTap: () => _goVehicle(),
          ));
        }).toList(),
      ),
      onRefresh: _getUser,
    );
  }

  Widget _noContent() {
    return Center(
      child: Container(
        margin: EdgeInsets.all(20),
        child: Text('El usuario no tiene vehículos registrados',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            )),
      ),
    );
  }

  void _goVehicle() {}
}
