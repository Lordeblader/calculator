class OperationToken {

  OperationTokenType type;

  String value;

  OperationToken(this.type, this.value);

  @override
  String toString() {
    return "Token of type '$type' with value '$value'";
  }

}

enum OperationTokenType {

  T_NUMBER,

  T_ADDITION_SUBTRACTION,

  T_MULTIPLICATION_DIVISION,

  T_LEFT_PARENTHESES,

  T_RIGHT_PARENTHESES,

  T_LEFT_BRACKETS,
  
  T_RIGHT_BRACKETS,

  T_EXPONENT,

  T_WORD,

  T_FUNCTION

}