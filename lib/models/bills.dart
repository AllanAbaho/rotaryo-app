import 'package:intl/intl.dart';
 
class Bill{
  final String biller_code;
  final String biller_name;
  final String biller_category;
  final String biller_amount;
 
  Bill({
    this.biller_code, this.biller_name, this.biller_category, this.biller_amount
  }); 
 
 
 
  Bill.fromMap(Map<String, dynamic> res)
      : biller_code = res['biller_code'].toString(),
      biller_name = res['biller_name'].toString(),
      biller_category = res['biller_category'].toString(),
        biller_amount = res['biller_amount'].toString();
 
  Map<String, Object> toMap() {
    return {'biller_code':biller_code,'biller_name': biller_name, 'biller_category': biller_category, 'biller_amount': biller_amount};
  }
}
