import 'package:vehicles_app/models/procedure.dart';

class Detail {
  int id = 0;
  Procedure procedure = Procedure(id: 0, description: '', price: 0);
  double laborPrice = 0;
  double sparePartsPrice = 0;
  double totalPrice = 0;
  String? remarks = '';

  Detail(
      {required this.id,
      required this.procedure,
      required this.laborPrice,
      required this.sparePartsPrice,
      required this.totalPrice,
      required this.remarks});

  Detail.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    procedure = Procedure.fromJson(json['procedure']);
    laborPrice = json['laborPrice'] + .0;
    sparePartsPrice = json['sparePartsPrice'] + .0;
    totalPrice = json['totalPrice'] + .0;
    remarks = json['remarks'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['procedure'] = this.procedure.toJson();
    data['laborPrice'] = this.laborPrice;
    data['sparePartsPrice'] = this.sparePartsPrice;
    data['totalPrice'] = this.totalPrice;
    data['remarks'] = this.remarks;
    return data;
  }
}
