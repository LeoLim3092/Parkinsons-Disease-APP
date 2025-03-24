
import 'package:intl/intl.dart';

NumberFormat formatter = new NumberFormat("00");
String getTimeString(int time) {

  if (time == 0) {
    return "00:00";
  }
  int minute = time ~/ 60;
  int second = time % 60;
  return "${formatter.format(minute)}:${formatter.format(second)}";
}
