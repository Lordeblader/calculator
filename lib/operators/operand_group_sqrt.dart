import 'operand.dart';
import 'operand_group.dart';

class OperandGroupSqrt extends OperandGroup {

  Operand exponent;
  bool exp;

  OperandGroupSqrt(int index, {Operand parent, Function function}) : super(index, parent: parent, function: function) {
    this.type = Operand.EXPONENTIATION;
  }

  Operand operate() {
   
    var expo = Operand(value: 1, type: Operand.DIVISION).operateWith(exponent.operate());
    var base = super.operate();

    var type = this.type;
    base.type = Operand.EXPONENTIATION;

    var e =  base.operateWith(expo);

    e.type = type;

    return e;
  }

  @override
  addOperand(Operand operand) {
    if (exp)
      if (exponent == null) {
        exponent = operand;
      } else {
        if (!(exponent is OperandGroup)) {
          var e = exponent;
          exponent = OperandGroup(index + 1, parent: e.parent, function: e.function);
          (exponent as OperandGroup).addOperand(e);
        }
        return (exponent as OperandGroup).addOperand(operand);
      }
    else return super.addOperand(operand);
  }

  @override
  String toString() {
    String ops = 
    "sqrt function" +
    (exponent != null ? ' with argument [\n   $exponent\n   ],' : '') +
    (type > 0 ? ' operating as ${Operand.getOperationName(type)}' : '');

    for (int i = 0; i < operands.length; i++) {
      ops += '\n';

      String lines = '';

      if (i < operands.length) {
        
        OperandGroup group = this;

        while (group.parent != null) {

          if (group == group.parent.lastOperand()) {
            lines = '    $lines';
          } else {
            lines = '│   $lines';
          }

          group = group.parent;
        }

        ops+=lines;

      }
      
      ops += "${i == operands.length - 1 ? '└─ ':'├─ '}${operands[i].toString()}";
    }

    return ops;
  }

}