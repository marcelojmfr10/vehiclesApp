import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vehicles_app/components/loader_component.dart';
import 'package:vehicles_app/helpers/api_helper.dart';
import 'package:vehicles_app/models/history.dart';
import 'package:vehicles_app/models/response.dart';
import 'package:vehicles_app/models/token.dart';
import 'package:vehicles_app/models/user.dart';
import 'package:vehicles_app/models/vehicle.dart';
import 'package:vehicles_app/screens/history_info_screen.dart';
import 'package:vehicles_app/screens/history_screen.dart';
import 'package:vehicles_app/screens/vehicle_screen.dart';

class VehicleInfoScreen extends StatefulWidget {
  final Token token;
  final User user;
  final Vehicle vehicle;

  VehicleInfoScreen(
      {required this.token, required this.user, required this.vehicle});

  @override
  _VehicleInfoScreenState createState() => _VehicleInfoScreenState();
}

class _VehicleInfoScreenState extends State<VehicleInfoScreen> {
  bool _showLoader = false;
  late Vehicle _vehicle;

  @override
  void initState() {
    super.initState();
    _vehicle = widget.vehicle;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            '${_vehicle.brand.description} ${_vehicle.line} ${_vehicle.plaque}'),
      ),
      body: Center(
        child: _showLoader
            ? LoaderComponent(text: 'Por favor espere...')
            : _getContent(),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => _goAddHistory(History(
            id: 0,
            date: '',
            dateLocal: '',
            mileage: 0,
            remarks: '',
            details: [],
            detailsCount: 0,
            totalLabor: 0,
            totalSpareParts: 0,
            total: 0)),
      ),
    );
  }

  void _goAddHistory(History history) async {
    String? result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => HistoryScreen(
                  token: widget.token,
                  user: widget.user,
                  vehicle: _vehicle,
                  history: history,
                )));

    if (result == 'yes') {
      await _getVehicle();
    }
  }

  void _goHistory(History history) async {
    String? result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => HistoryInfoScreen(
                  token: widget.token,
                  user: widget.user,
                  vehicle: _vehicle,
                  history: history,
                )));

    if (result == 'yes') {
      await _getVehicle();
    }
  }

  Widget _getContent() {
    return Column(
      children: <Widget>[
        _showVehicleInfo(),
        Expanded(
            child:
                _vehicle.histories.length == 0 ? _noContent() : _getListView()),
      ],
    );
  }

  Widget _showVehicleInfo() {
    return Container(
      margin: EdgeInsets.all(10),
      padding: EdgeInsets.all(5),
      child: Row(
        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Stack(
            children: <Widget>[
              ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: CachedNetworkImage(
                    imageUrl: _vehicle.imageFullPath,
                    errorWidget: (context, url, error) => Icon(Icons.error),
                    fit: BoxFit.cover,
                    height: 100,
                    width: 100,
                    placeholder: (context, url) => Image(
                      image: AssetImage('assets/vehicles_logo.jpg'),
                      fit: BoxFit.cover,
                      height: 100,
                      width: 100,
                    ),
                  )
                  // FadeInImage(
                  //   placeholder: AssetImage('assets/vehicles_logo.jpg'),
                  //   image: NetworkImage(_user.imageFullPath),
                  //   width: 100,
                  //   height: 100,
                  //   fit: BoxFit.cover,
                  // ),
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
                              'Tipo de vehículo: ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(_vehicle.vehicleType.description,
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
                              'Marca: ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(_vehicle.brand.description,
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
                              'Modelo: ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(_vehicle.model.toString(),
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
                              'Placa: ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(_vehicle.plaque,
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
                              'Línea: ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(_vehicle.line,
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
                              'Color: ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(_vehicle.color,
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
                              'Comentarios: ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                                _vehicle.remarks == null
                                    ? 'N/A'
                                    : _vehicle.remarks!,
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
                              '# Historias: ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(_vehicle.historiesCount.toString(),
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

  Widget _getListView() {
    return RefreshIndicator(
      child: ListView(
        children: _vehicle.histories.map((e) {
          return Card(
              child: InkWell(
            child: Container(
                margin: EdgeInsets.all(10),
                padding: EdgeInsets.all(5),
                child: Row(
                  children: <Widget>[
                    Expanded(
                        child: Container(
                            margin: EdgeInsets.symmetric(horizontal: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Column(
                                  children: <Widget>[
                                    Text(
                                        '${DateFormat('yyyy-MM-dd').format(DateTime.parse(e.dateLocal))}',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        )),
                                    Row(
                                      children: <Widget>[
                                        Text('${e.mileage} Kms.',
                                            style: TextStyle(
                                              fontSize: 14,
                                            )),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Text(
                                            e.remarks == null
                                                ? 'N/A'
                                                : e.remarks!,
                                            style: TextStyle(
                                              fontSize: 14,
                                            )),
                                      ],
                                    ),
                                    Row(
                                      children: <Widget>[
                                        Text(
                                            'Mano de obra: ${NumberFormat.currency(symbol: '\$').format(e.totalLabor)}',
                                            style: TextStyle(
                                              fontSize: 14,
                                            )),
                                      ],
                                    ),
                                    Row(
                                      children: <Widget>[
                                        Text(
                                            'Repuestos: ${NumberFormat.currency(symbol: '\$').format(e.totalSpareParts)}',
                                            style: TextStyle(
                                              fontSize: 14,
                                            )),
                                      ],
                                    ),
                                    Row(
                                      children: <Widget>[
                                        Text(
                                            'Total: ${NumberFormat.currency(symbol: '\$').format(e.total)}',
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
            onTap: () => _goHistory(e),
          ));
        }).toList(),
      ),
      onRefresh: _getVehicle,
    );
  }

  Future<Null> _getVehicle() async {
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

    Response response =
        await ApiHelper.getVehicle(widget.token, _vehicle.id.toString());

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
      _vehicle = response.result;
    });
  }

  Widget _noContent() {
    return Center(
      child: Container(
        margin: EdgeInsets.all(20),
        child: Text('El vehículo no tiene historias registradas',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            )),
      ),
    );
  }

  void _goEdit() async {
    String? result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => VehicleScreen(
                  token: widget.token,
                  user: widget.user,
                  vehicle: _vehicle,
                )));

    if (result == 'yes') {
      await _getVehicle();
    }
  }
}
