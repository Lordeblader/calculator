import 'dart:math';

import 'operand_group.dart';

class Operand {

  static const Map<String, Function> functions = {
    'sin': sin,
    'sine': sin,
    'sen' : sin,
    'seno': sin,

    'cos': cos,
    'cosine': cos,
    'coseno' : cos,

    'tan': tan,
    'tg': tan,
    'tangent': tan,
    'tangente': tan,

    'asin': asin,
    'aseno': asin,
    'arcsine': asin,
    'arcoseno': asin,

    'acos': acos,
    'arccos': acos,
    'arcocoseno': asin,

    'atan': atan,
    'atg': atan,
    'arctan': atan,
    'arctangent': atan,

    'sqrt': sqrt,
    'sqr': sqrt,

    'log': log,
    'logarithm' : log,
    'logaritmo': log,
  };
  
  static const Map<String, num> constants = {
    'e': e,
    'pi': pi
  };

  static const 
              ADDITION = 2,
              SUBTRACTION = 3,
              MULTIPLICATION = 4,
              DIVISION = 5,
              EXPONENTIATION = 6;

  int type;
  int index;
  num value;

  OperandGroup parent;
  Function function;

  Operand({this.parent, this.value = 0, this.index = 0, this.type = 0, this.function});

  Operand operate() {
    if (value == null && function == null) value = 0;
    if (function != null) {
      value = (Function.apply(function, [value]));
      function = null;
    }
    return this;
  }

  Operand operateWith(Operand that) {
    Function operation = getOperationFunction();
    if (operation == null) {
      throw new Exception("Operand '$value' doesn't have an operation type");
    }
    value = Function.apply(operation, [value, that.value]);
    this.type = that.type;
    return this;
  }

  num add(num a, num b) {
    return a + b;
  }

  num subtract(num a, num b) {
    return a - b;
  }

  num multiply(num a, num b) {
    return a * b;
  }

  num divide(num a, num b) {
    return a / b;
  }

  Function getOperationFunction([int type]) {
    int operation = type ?? this.type;
    switch (operation) {
      case ADDITION: return add;
      case SUBTRACTION: return subtract;
      case MULTIPLICATION: return multiply;
      case DIVISION: return divide;
      case EXPONENTIATION: return pow;
      default:
      return null;
    }
  }

  static String getOperationName(int operation) {
    switch (operation) {
      case ADDITION: return 'an ADDEND';
      case SUBTRACTION: return 'a MINUEND/SUBTRAHEND';
      case MULTIPLICATION: return 'a FACTOR';
      case DIVISION: return 'a DIVIDEND/DIVISOR';
      case EXPONENTIATION: return 'BASE';
      default:
      return '';
    }
  }

  static String getFunctionName(Function function) {
    var k = functions.entries.firstWhere((e) => e.value == function);
    return k == null ? null : k.key;
  }

  static Function getFunctionByName(String function) {
    return functions[function];
  }

  static String getConstantName(num constant) {
    var k = constants.entries.firstWhere((e) => e.value == constant);
    return k == null ? null : k.key;
  }

  static num getConstantByName(String constant) {
    return constants[constant];
  }

  @override
  String toString() {
    return "Operand with value '$value'" +
    (type > 0 ? ' operating as ${getOperationName(type)}' : '') +
    (function != null ? " with function '${getFunctionName(function)}'" : '' );
  }

}