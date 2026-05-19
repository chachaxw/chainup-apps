
import 'package:chainup_flutter_ex/ext/decimal_ext.dart';
import 'package:decimal/decimal.dart';
import 'package:decimal/intl.dart';
import 'package:intl/intl.dart';


void main(){

  Decimal value = Decimal.parse('123450.123');
  var formatter = NumberFormat.decimalPatternDigits(locale: "en-US", decimalDigits: 5);
  print(formatter.format(DecimalIntl(value)));

   String s = value.formatWithThousSymbol(digits: 7);
   print(s);

   print(value.formatWithThousSymbol());

   print(value.toString());


}