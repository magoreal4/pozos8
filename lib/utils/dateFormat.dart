String formatDate({DateTime dateTime}) {
  var _now = dateTime;
  var _mes = _now.month.toString().padLeft(2, '0');
  var _dia = _now.day.toString().padLeft(2, '0');
  var _hora = (_now.hour < 10) ? "0${_now.hour}" : "${_now.hour}";
  var _minuto = (_now.minute < 10) ? "0${_now.minute}" : "${_now.minute}";
  var _segundo = (_now.second < 10) ? "0${_now.second}" : "${_now.second}";
  var _textNow = '${_now.year}-$_mes-$_dia $_hora:$_minuto:$_segundo';
  return _textNow;
}
