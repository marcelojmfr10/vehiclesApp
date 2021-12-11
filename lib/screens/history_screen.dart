import 'package:flutter/material.dart';
import 'package:vehicles_app/models/token.dart';
import 'package:vehicles_app/models/user.dart';
import 'package:vehicles_app/models/vehicle.dart';

class HistoryScreen extends StatefulWidget {
  final Token token;
  final User user;
  final Vehicle vehicle;

  HistoryScreen(
      {required this.token, required this.user, required this.vehicle});

  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('History'),
      ),
      body: Center(
        child: Text('History'),
      ),
    );
  }
}
