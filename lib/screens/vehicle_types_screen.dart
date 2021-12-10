import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';

import 'package:vehicles_app/components/loader_component.dart';
import 'package:vehicles_app/helpers/api_helper.dart';
import 'package:vehicles_app/models/response.dart';
import 'package:vehicles_app/models/token.dart';
import 'package:vehicles_app/models/vehicle_type.dart';

import 'vehicle_type_screen.dart';

class VehicleTypesScreen extends StatefulWidget {
  final Token token;

  VehicleTypesScreen({required this.token});

  @override
  _VehicleTypesScreenState createState() => _VehicleTypesScreenState();
}

class _VehicleTypesScreenState extends State<VehicleTypesScreen> {
  List<VehicleType> _vehicleTypes = [];
  bool _showLoader = false;

  bool _isFiltered = false;
  String _search = '';

  @override
  void initState() {
    // TODO: implement initState
    // se llama cuando la pantalla cambia (cada que la página cargue)
    super.initState();
    _getVehicleTypes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tipos de Vehículo'),
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

  Future<Null> _getVehicleTypes() async {
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

    Response response = await ApiHelper.getVehicleTypes(widget.token);

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
      _vehicleTypes = response.result;
    });
  }

  Widget _getContent() {
    return _vehicleTypes.length == 0 ? _noContent() : _getListView();
  }

  Widget _noContent() {
    return Center(
      child: Container(
        margin: EdgeInsets.all(20),
        child: Text(
            _isFiltered
                ? 'No hay tipos de vehículo con ese criterio de búsqueda.'
                : 'No hay tipos de vehículo registradas.',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            )),
      ),
    );
  }

  Widget _getListView() {
    return RefreshIndicator(
      onRefresh: _getVehicleTypes,
      child: ListView(
        children: _vehicleTypes.map((e) {
          return Card(
            child: InkWell(
              onTap: () => _goEdit(e),
              child: Container(
                margin: EdgeInsets.all(10),
                padding: EdgeInsets.all(5),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(e.description,
                            style: TextStyle(
                              fontSize: 20,
                            )),
                        Icon(Icons.arrow_forward_ios),
                      ],
                    ),
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
            title: Text('Filtrar Tipos de Vehículo'),
            content: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
              Text('Escriba las primeras letras del tipo de vehículo'),
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

    _getVehicleTypes();
  }

  void _filter() {
    if (_search.isEmpty) {
      return;
    }

    List<VehicleType> filteredList = [];
    for (var vehicleType in _vehicleTypes) {
      if (vehicleType.description
          .toLowerCase()
          .contains(_search.toLowerCase())) {
        filteredList.add(vehicleType);
      }
    }

    setState(() {
      _vehicleTypes = filteredList;
      _isFiltered = true;
    });

    Navigator.of(context).pop();
  }

  void _goAdd() async {
    String? result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => VehicleTypeScreen(
                token: widget.token,
                vehicleType: VehicleType(id: 0, description: ''))));

    if (result == 'yes') {
      _getVehicleTypes();
    }
  }

  void _goEdit(VehicleType vehicleType) async {
    String? result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => VehicleTypeScreen(
                token: widget.token, vehicleType: vehicleType)));

    if (result == 'yes') {
      _getVehicleTypes();
    }
  }
}
