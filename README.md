# Calculator

**JUST A PERSONAL PROJECT FOR PRACTICE. MAY GIVE INCORRECT ANSWERS. ALWAYS VERIFY THE ANSWER!!**

Simple calculator made in Dart with some functions. Uses a custom parser.

## Overview

Just simple calculator which utilizes a custom parser. Calculates arithmetic operations, exponential operations, square roots, logarithms and trigonometric functions. Allows use of constants 'π' and '_e_'.

## Use

Run the application with dart and introduce the expression inside the double quotes, so the program can parse the expression correctly. However, it's not required.

```shell
$ dart path/lib/main.dart [-v | --verbose] "<expression>"
```

**-v / --verbose:** Prints the main group of the expression

### Syntax

It's syntax is similar to a common programming language mathematical expression, with some minor changes.

The expression
```java
2 - log(1 + e) / sin(pi) + sqrt[3](8)
```
is the equivalent expression of

![equation](https://latex.codecogs.com/svg.latex?2&space;-&space;\frac{log(1&space;&plus;&space;e)}{sin(\pi)}&plus;\sqrt[3]{8})

### Example

For example, we have the following mathematical expression:

![equation](https://latex.codecogs.com/svg.latex?\frac{2&space;\times&space;cos(5&space;&plus;&space;6)}{3})

So we introduce 

```shell
$ dart path/lib/main.dart -v "(2*cos(5+6))/3"
```
which prints the following:
```java
Group (index: 0)
├─ Group (index: 1) operating as a DIVIDEND/DIVISOR
│   ├─ Operand with value '2' operating as a FACTOR
│   └─ Group (index: 2) with function 'cos'
│       ├─ Operand with value '5' operating as an ADDEND
│       └─ Operand with value '6'
└─ Operand with value '3'
0.0029504653253671904
```
Remove the verbose argument to print just the result.

More examples:
```java
$ dart main.dart 1 +-- 6
7

$ dart main.dart logarithm(5)
1.6094379124341003

$ dart main.dart log.2
-1.6094379124341003

$ dart main.dart asin(2 - 1.5) + arcsine(0.5)
0.0
```

## TODO

- Print the operations step by step.
- Fix important issues with sqrt index argument, which can not parse correctly a gorup inside the sqrt index.
- Implement logarithm base argument.
- Implement custom functions and constants
