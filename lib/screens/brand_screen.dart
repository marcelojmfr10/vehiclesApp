import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';

import 'package:vehicles_app/components/loader_component.dart';
import 'package:vehicles_app/helpers/api_helper.dart';
import 'package:vehicles_app/models/brand.dart';
import 'package:vehicles_app/models/response.dart';
import 'package:vehicles_app/models/token.dart';

class BrandScreen extends StatefulWidget {
  final Token token;
  final Brand brand;

  BrandScreen({required this.token, required this.brand});

  @override
  _BrandScreenState createState() => _BrandScreenState();
}

class _BrandScreenState extends State<BrandScreen> {
  bool _showLoader = false;

  String _description = '';
  String _descriptionError = '';
  bool _descriptionShowError = false;
  TextEditingController _descriptionController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _description = widget.brand.description;
    _descriptionController.text = _description;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            widget.brand.id == 0 ? 'Nueva marca' : widget.brand.description),
      ),
      body: Stack(
        children: [
          Column(children: <Widget>[
            _showDescription(),
            _showButtons(),
          ]),
          _showLoader
              ? LoaderComponent(text: 'Por favor espere...')
              : Container(),
        ],
      ),
    );
  }

  Widget _showDescription() {
    return Container(
      padding: EdgeInsets.all(10),
      child: TextField(
        autofocus: true,
        controller: _descriptionController,
        decoration: InputDecoration(
            hintText: 'Ingresa una descripción',
            labelText: 'Descripción',
            errorText: _descriptionShowError ? _descriptionError : null,
            suffixIcon: Icon(Icons.description),
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
        onChanged: (value) {
          _description = value;
        },
      ),
    );
  }

  Widget _showButtons() {
    return Container(
      margin: EdgeInsets.only(left: 10, right: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Expanded(
              child: ElevatedButton(
                  onPressed: () => _save(),
                  style: ButtonStyle(backgroundColor:
                      MaterialStateProperty.resolveWith<Color>(
                          (Set<MaterialState> states) {
                    return Color(0xFF120E43);
                  })),
                  child: Text('Guardar'))),
          widget.brand.id == 0
              ? Container()
              : SizedBox(
                  width: 20,
                ),
          widget.brand.id == 0
              ? Container()
              : Expanded(
                  child: ElevatedButton(
                      onPressed: () => _confirmDelete(),
                      style: ButtonStyle(backgroundColor:
                          MaterialStateProperty.resolveWith<Color>(
                              (Set<MaterialState> states) {
                        return Color(0xFFB4161B);
                      })),
                      child: Text('Borrar')),
                ),
        ],
      ),
    );
  }

  void _save() {
    if (!_validateFields()) {
      return;
    }

    widget.brand.id == 0 ? _addRecord() : _saveRecord();
  }

  bool _validateFields() {
    bool isValid = true;
    if (_description.isEmpty) {
      isValid = false;
      _descriptionShowError = true;
      _descriptionError = 'Debes ingresar una marca.';
    } else {
      _descriptionShowError = false;
    }

    setState(() {});
    return isValid;
  }

  _addRecord() async {
    setState(() {
      _showLoader = true;
    });

    Map<String, dynamic> request = {'description': _description};

    Response response =
        await ApiHelper.post('/api/Brands/', request, widget.token);

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

    Navigator.pop(context, 'yes');
  }

  _saveRecord() async {
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

    Map<String, dynamic> request = {
      'id': widget.brand.id,
      'description': _description
    };

    Response response = await ApiHelper.put(
        '/api/Brands/', widget.brand.id.toString(), request, widget.token);

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

    Navigator.pop(context, 'yes');
  }

  void _confirmDelete() async {
    var response = await showAlertDialog(
        context: context,
        title: 'Confirmación',
        message: '¿Estás seguro de querer borrar el registro?',
        actions: <AlertDialogAction>[
          AlertDialogAction(key: 'no', label: 'No'),
          AlertDialogAction(key: 'yes', label: 'Sí')
        ]);

    if (response == 'yes') {
      _deleteRecord();
    }
  }

  void _deleteRecord() async {
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

    Response response = await ApiHelper.delete(
        '/api/Brands/', widget.brand.id.toString(), widget.token);

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

    Navigator.pop(context, 'yes');
  }
}
