import 'package:advanced_calculator/calculator/operand.dart';
import 'package:advanced_calculator/calculator/operand_group_sqrt.dart';

import 'operand_group.dart';
import 'operation_token.dart';

class OperationParser {

  static num calculate(String operation, {verbose = false}) {
    try {
      var g  = parse(operation);
      if (verbose) print(g);
      return g.operate().value;
    } on Exception catch(e) {
      //print('Exception: $e');
    } on Error catch(e) {
      //print('Error: $e');
    }
    return null;
  }

  static OperandGroup parse(String operation) {
    var parser = OperationParser();
    return OperationParser().parseGroups(parser.parseTokens(operation));
  }

  OperandGroup parseGroups(List<OperationToken> tokens) {

    OperandGroup mainGroup = OperandGroup(0);

    List<OperandGroup> groups = List<OperandGroup>();
    groups.add(mainGroup);

    String remOperator;

    OperationToken lastToken;
    Operand lastOperand;

    bool openGroup = false;

    var addOp = ({String value, num numVal, Function function}) {
      var op = Operand(parent: groups.last, value: value == null ? numVal : num.tryParse(value), function: function);

      groups.last.addOperand(op);

      lastOperand = op;

      return op;
    };

    for (OperationToken token in tokens) {
      switch (token.type) {
        case OperationTokenType.T_NUMBER:
          String val = token.value;


          if (val[0] == '.') val = '0$val';
          if (remOperator != null) {
            val = '$remOperator$val';
            remOperator = null;
          }

          // If last token is a function
          if (lastToken != null && lastToken.type == OperationTokenType.T_WORD) {
              lastOperand.value = num.tryParse(val);
          } else {
            addOp(value: val);
          }
          break;
        case OperationTokenType.T_ADDITION_SUBTRACTION:
          if (lastToken == null || lastToken.type != OperationTokenType.T_NUMBER && lastToken.type != OperationTokenType.T_RIGHT_PARENTHESES && lastToken.type != OperationTokenType.T_RIGHT_BRACKETS) {
            remOperator = token.value;
          } else {
            if (openGroup) {
              openGroup = false;
              lastOperand = groups.last;
              groups.removeLast();
            }
            lastOperand.type = token.value == '+' ? Operand.ADDITION: Operand.SUBTRACTION;
          }
        break;
        case OperationTokenType.T_MULTIPLICATION_DIVISION:
          if (lastOperand != null) {
            if (lastOperand.function != null && !(lastOperand is OperandGroup)) {
              Operand o = groups.last.operands.removeLast();
              Operand fop = Operand(value: o.value, parent: groups.last);
              OperandGroup g = OperandGroup(groups.length, parent: groups.last, function: o.function);

              groups.last.addOperand(g);
              groups.add(g);
              g.addOperand(fop);

              lastOperand = fop;

              openGroup = true;
            }
          }
          lastOperand.type = token.value == '*' ? Operand.MULTIPLICATION: Operand.DIVISION;
        break;
        case OperationTokenType.T_LEFT_PARENTHESES:
          var g;
          if (lastToken != null && lastToken.type == OperationTokenType.T_WORD) {
            Function function = groups.last.lastOperand(remove: true).function;
            g = OperandGroup(groups.length, parent: groups.last);
            g.function = function;
          } else {
            g = OperandGroup(groups.length, parent: groups.last);
          }
          var last = groups.last;

          last.addOperand(g); // Create a new group and add it to the last group as an operand
          if (last.operands.length > 0)
            groups.add(last.lastOperand()); // Add the previous group to the groups' list
        break;
        case OperationTokenType.T_RIGHT_PARENTHESES:
          lastOperand = groups.last;
          groups.removeLast();
        break;
        case OperationTokenType.T_WORD:
          // Functions
          Function f = Operand.getFunctionByName(token.value);

          if (f == null) {
            num c = Operand.getConstantByName(token.value);

            if (c != null) {
              if (lastToken != null && lastToken.type == OperationTokenType.T_WORD) {
                lastOperand.value = c;
              } else {
                addOp(numVal: c);
              }
              token.type = OperationTokenType.T_NUMBER;
            } else {
              throw OperationParsingException("Could not find any function or constant with name '${token.value}'");
            }

          } else {
            if (lastToken != null && lastToken.type == OperationTokenType.T_WORD) {
              var g;

              // remove the waiting operand and get it's function
              Function function = groups.last.lastOperand(remove: true).function;

              // create a new group with the given function
              g = OperandGroup(groups.length, parent: groups.last);
              g.function = function;

              // add the group to the last group
              groups.last.addOperand(g);
              groups.add(groups.last.lastOperand());

            }

            addOp(value: '', function: f);
            remOperator = '';
          }
        break;
        case OperationTokenType.T_LEFT_BRACKETS:
          var g;
          if (lastToken != null && lastToken.type == OperationTokenType.T_WORD) {
            if (lastToken.value == 'sqrt' || lastToken.value == 'sqr') {
              groups.last.lastOperand(remove: true);
              g = OperandGroupSqrt(groups.length, parent: groups.last);

              lastOperand = g;

              g.exp = true;
              
              openGroup = true;
            } else {
              print('Other functions');
            }
            
          } else {
            throw('No function found before brackets');
          }

          groups.last.addOperand(g); // Create a new group and add it to the last group as an operand
          groups.add(groups.last.lastOperand()); // Add the previous group to the groups' list

        break;
        case OperationTokenType.T_RIGHT_BRACKETS:
          if (lastOperand.parent is OperandGroupSqrt) {
            (lastOperand.parent as OperandGroupSqrt).exp = false;
            
            lastOperand = null;
          }

        break;
        case OperationTokenType.T_EXPONENT:
          if (lastOperand != null) {
            if (lastOperand.function != null && !(lastOperand is OperandGroup)) {
              Operand o = groups.last.operands.removeLast();
              Operand fop = Operand(value: o.value, parent: groups.last);
              OperandGroup g = OperandGroup(groups.length, parent: groups.last, function: o.function);

              groups.last.addOperand(g);
              groups.add(g);
              g.addOperand(fop);

              lastOperand = fop;

              openGroup = true;
            }
          }
          lastOperand.type = Operand.EXPONENTIATION;
        break;
        default:
        break;
      }
      
      lastToken = token;
    }

    return mainGroup;
  }

  List<OperationToken> parseTokens(String operation) {

    List<OperationToken> tokens = List<OperationToken>();

    OperationToken lastToken;

    String op = "$operation";

    int col = 0;
    
    var isDigit = (char) {
      return "0123456789".contains(char);
    };

    var isDot = (char) {
      return char == '.';
    };

    var isParentheses = (char) {
      return "()".contains(char);
    };

    var isAddSubsOperator = (char) {
      return "+-".contains(char);
    };

    var isMulDivOperator = (char) {
      return "*/".contains(char);
    };

    var isExponent = (char) => char == '^';

    var isWord = (char) {
      return RegExp(r"[A-z]").hasMatch(char);
    };

    var isSquareParentheses = (char) {
      return "[]".contains(char);
    };

    var firstToken = () {
      return tokens.length == 0;
    };

    var hasNext = (int index) {
      return index >= 0 && index < op.length;
    };

    var newToken = (type, value) {
      var token = OperationToken(type, value);
      lastToken = token;
      tokens.add(token);
    };
    
    int parenthesesCount = 0;
    int bracketsCount = 0;

    while(hasNext(col)) {

      String char = op[col];

      if (isDigit(char)) {

        if (tokens.length > 0 && tokens.last.type == OperationTokenType.T_RIGHT_PARENTHESES) newToken(OperationTokenType.T_MULTIPLICATION_DIVISION, '*');

        if (lastToken == null) {
          newToken(OperationTokenType.T_NUMBER, char);
        } else if (lastToken.type == OperationTokenType.T_NUMBER) {
          lastToken.value = lastToken.value + char;
        } else {
          if (tokens.last.type == OperationTokenType.T_RIGHT_PARENTHESES) newToken(OperationTokenType.T_MULTIPLICATION_DIVISION, '*');

          newToken(OperationTokenType.T_NUMBER, char);
        }

      } else if (char == ' ') {

        lastToken = null;

        col++;

        continue;

      } else if (isDot(char)) {

        if (lastToken != null && lastToken.type == OperationTokenType.T_NUMBER) {

          if (lastToken.value.contains('.')) {
            throw OperationParsingException("unexpected '.' at col $col: '${lastToken.value}.'");
          } else {
            lastToken.value += char;
          }

        } else if (col == op.length - 1) {
            throw OperationParsingException("expected a number for last value '.'");
        } else {
          newToken(OperationTokenType.T_NUMBER, char);
        }

      } else if (isParentheses(char)) {

        if (char == '(') {
          if (tokens.length > 0 && tokens.last.type == OperationTokenType.T_NUMBER)
          newToken(OperationTokenType.T_MULTIPLICATION_DIVISION, '*');
          newToken(OperationTokenType.T_LEFT_PARENTHESES, char);
          parenthesesCount++;
        } else {
          if (parenthesesCount == 0) throw OperationParsingException("unexpected parentheses '$char' at col $col");
          newToken(OperationTokenType.T_RIGHT_PARENTHESES, char);
          parenthesesCount--;
        }
      } else if (isAddSubsOperator(char)) {

        if (lastToken == null) {
          newToken(OperationTokenType.T_ADDITION_SUBTRACTION, char);

        } else if (lastToken.type == OperationTokenType.T_ADDITION_SUBTRACTION || lastToken.type == OperationTokenType.T_NUMBER && isAddSubsOperator(lastToken.value)) {

          lastToken.value = (lastToken.value == char) ? '+' : '-' ;

        } else {
          newToken(OperationTokenType.T_ADDITION_SUBTRACTION, char);
        }

      } else if (isMulDivOperator(char)) {
        
        if (firstToken()) {
          throw OperationParsingException("unexpected operator '$char' at col $col");
        } if (lastToken == null) {
          newToken(OperationTokenType.T_MULTIPLICATION_DIVISION, char);
        } else if (lastToken.type == OperationTokenType.T_NUMBER || lastToken.type == OperationTokenType.T_RIGHT_PARENTHESES) {
          newToken(OperationTokenType.T_MULTIPLICATION_DIVISION, char);
        } else {
          throw OperationParsingException("unexpected operator '$char' at col $col");
        }

      } else if (isExponent(char)) {
        
        newToken(OperationTokenType.T_EXPONENT, char);

      } else if (isSquareParentheses(char)) {
        if (char == '[') {
          newToken(OperationTokenType.T_LEFT_BRACKETS, char);
          bracketsCount++;
        } else {
          if (bracketsCount == 0) throw OperationParsingException("unexpected bracket '$char' at col $col");
          newToken(OperationTokenType.T_RIGHT_BRACKETS, char);
          bracketsCount--;
        }
      } else if (isWord(char)) {

        if (tokens.length > 0 && tokens.last.type == OperationTokenType.T_NUMBER)
          newToken(OperationTokenType.T_MULTIPLICATION_DIVISION, '*');

        if (lastToken != null && lastToken.type == OperationTokenType.T_WORD) {
          lastToken.value += char;
        } else {
          newToken(OperationTokenType.T_WORD, char);
        }

      } else {
        throw OperationParsingException("unexpected value '$char' at col $col");
      }

      if (tokens.length > 1 && tokens[tokens.length - 2].value.endsWith('.')) {
        throw OperationParsingException("unexpected value '$char' at col $col: expected a number");
      }

      col++;
    }

    if (parenthesesCount > 0) {
      throw OperationParsingException('unclosed parentheses');
    } else if (bracketsCount > 0) {
      throw OperationParsingException('unclosed brackets');
    }

    return tokens;
  }

}

class OperationParsingException implements Exception {

  final String message;

  const OperationParsingException([this.message = ""]);

  @override
  String toString() {
    return "OperationParsingException: $message";
  }

}