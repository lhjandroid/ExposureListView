class Position {

  Position(this._start, this._end);

  double _start;
  double _end;

  double get start => _start;

  set start(double value) {
    _start = value;
  }

  double get end => _end;

  set end(double value) {
    _end = value;
  }

  @override
  String toString() {
    return '$start,$end';
  }

}