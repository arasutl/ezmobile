import 'dart:convert';
import 'dart:ffi';

String NullAwareString(var vtemp) {
  if (vtemp == null)
    return '';
  else
    return jsonEncode(vtemp).toString();
}

int NullAwareIntRetZero(var vtemp) {
  if (vtemp == null || vtemp == '') //if (vtemp == null)
    return 0;
  else
    return int.parse(vtemp);
}

int NullAwareIntRetOne(var vtemp) {
  if (vtemp == null)
    return 1;
  else
    return int.parse(vtemp);
}
