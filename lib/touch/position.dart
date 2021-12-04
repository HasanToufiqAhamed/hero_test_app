import 'dart:ffi';

import 'package:flutter/cupertino.dart';



class Position {
  Offset? leftT;
  Offset? leftB;
  Offset? rightT;
  Offset? rightB;

  Position(this.leftT, this.leftB, this.rightT, this.rightB);
}