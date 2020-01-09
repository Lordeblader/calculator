import 'package:advanced_calculator/calculator/operation_parser.dart';

void main(List<String> args) {

  if (args.length == 0) return;

  List<String> arguments = List.from(args);

  bool verbose = false;

  if (args[0] == '-v' || args[0] == '--verbose')  {
    verbose = true;
    arguments.removeAt(0);
  }

  if (arguments.length == 0) {
    print("Expression is required");
    return;
  }

  var expression = arguments.join(' ');

  var c = OperationParser.calculate(expression, verbose: verbose);

  if (c != null) print(c);

}