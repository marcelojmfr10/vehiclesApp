import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:vehicles_app/models/response.dart';

class DisplayPictureScreen extends StatefulWidget {
  final XFile image;
  // const DisplayPictureScreen({Key? key}) : super(key: key);
  // final String imagePath;
  DisplayPictureScreen({required this.image});

  @override
  _DisplayPictureScreenState createState() => _DisplayPictureScreenState();
}

class _DisplayPictureScreenState extends State<DisplayPictureScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Vista previa de la foto'),
      ),
      body: Column(
        children: [
          Image.file(
            File(widget.image.path),
            width: MediaQuery.of(context).size.width,
          ),
          Container(
              margin: EdgeInsets.all(10),
              child: Row(
                children: <Widget>[
                  Expanded(
                      child: ElevatedButton(
                          onPressed: () {
                            Response response =
                                Response(isSuccess: true, result: widget.image);
                            Navigator.pop(context, response);
                          },
                          style: ButtonStyle(backgroundColor:
                              MaterialStateProperty.resolveWith<Color>(
                                  (Set<MaterialState> states) {
                            return Color(0xFF120E43);
                          })),
                          child: Text('Usar Foto'))),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                      child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          style: ButtonStyle(backgroundColor:
                              MaterialStateProperty.resolveWith<Color>(
                                  (Set<MaterialState> states) {
                            return Color(0xFFE03B8B);
                          })),
                          child: Text('Volver a tomar')))
                ],
              ))
        ],
      ),
    );
  }
}
