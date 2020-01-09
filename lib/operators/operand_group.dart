import 'package:advanced_calculator/calculator/operand.dart';

class OperandGroup extends Operand {

  List<Operand> operands;

  OperandGroup(int i, {Operand parent, Function function}) : super(parent: parent, index: i, function: function) {
    operands = List<Operand>();
  }
  
  Operand operate() {
    doOperation(Operand.EXPONENTIATION);
    doOperation(Operand.MULTIPLICATION);
    doOperation(Operand.ADDITION);

    return Operand(parent: this.parent, value: operands[0].value, type: this.type, index: this.index - 1, function: this.function).operate();
  }

  void doOperation(int type) {
    for (int i = 0; i < operands.length; i++) {
      if (i < operands.length - 1) {
        Operand op = operands[i];

        if (op.type ~/ 2 == type / 2) {
        
          Operand next = operands[i + 1];
          try {
            operands[i] = op.operate().operateWith(next.operate());
          } on Exception catch (e) {
            throw('$e \n\n1.$op \n\n2.$next \n\nindex: $index');
          }
          operands.removeAt(i + 1);
          i--;
        }
      } else {
        operands[i] = operands[i].operate();
      }
    }
  }

  addOperand(Operand operand) {
    operands.add(operand);
  }

  Operand lastOperand({bool remove = false}) {
    if (operands.length == 0) return null;
    if (remove) {
      return operands.removeLast();
    } else return operands.last;
  }

  @override
  String toString() {
    String ops = 
    "Group (index: $index)" +
    (type > 0 ? ' operating as ${Operand.getOperationName(type)}' : '') +
    (function != null ? " with function '${Operand.getFunctionName(function)}'" : '' );

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