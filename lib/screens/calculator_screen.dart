import 'package:flutter/material.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String output = "0";
  double firstNum = 0;
  String operator = "";
  String expression = "";

  void onButtonPress(String value) {
    setState(() {
      if (value == "AC") {
        expression = "";
        output = "0";
        firstNum = 0;
        operator = "";
      } else if (value == "⌫") {
        if (expression.isNotEmpty) {
          expression = expression.substring(0, expression.length - 1);
          output = expression.isEmpty ? "0" : expression;
        }
      } else if (["+", "-", "×", "÷", "%"].contains(value)) {
        firstNum = double.tryParse(expression) ?? 0;
        operator = value;
        expression += value;
        output = expression;
      } else if (value == "=") {
        List<String> parts = expression.split(operator);

        if (parts.length == 2) {
          double num1 = double.tryParse(parts[0]) ?? 0;
          double num2 = double.tryParse(parts[1]) ?? 0;
          double result = 0;

          switch (operator) {
            case "+":
              result = num1 + num2;
              break;
            case "-":
              result = num1 - num2;
              break;
            case "×":
              result = num1 * num2;
              break;
            case "÷":
              result = num2 != 0 ? num1 / num2 : 0;
              break;
            case "%":
              result = num1 % num2;
              break;
          }

          output = result.toString();
          expression = output;
        }
      } else {
        expression += value;
        output = expression;
      }
    });
  }

  Widget calcButton(
    BuildContext context,
    String text, {
    bool isOperator = false,
    bool isEqual = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color bgColor;
    Color textColor;

    if (isEqual) {
      bgColor = Colors.blue;
      textColor = Colors.white;
    } else if (isOperator) {
      bgColor = isDark ? Colors.blue.shade900 : Colors.blue.shade200;
      textColor = Colors.white;
    } else {
      bgColor = isDark ? const Color(0xFF121212) : Colors.grey.shade300;
      textColor = isDark ? Colors.white : Colors.black;
    }

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: SizedBox(
          height: 75,
          child: ElevatedButton(
            onPressed: () => onButtonPress(text),
            style: ElevatedButton.styleFrom(
              backgroundColor: bgColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(40),
              ),
            ),
            child: FittedBox(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 28,
                  color: textColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildRow(List<Widget> buttons) {
    return Row(children: buttons);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Calculator"),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              alignment: Alignment.bottomRight,
              padding: const EdgeInsets.all(24),
              child: Text(
                output,
                style: TextStyle(
                  fontSize: 52,
                  color: isDark ? Colors.white : Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          buildRow([
            calcButton(context, "AC", isOperator: true),
            calcButton(context, "⌫", isOperator: true),
            calcButton(context, "%", isOperator: true),
            calcButton(context, "÷", isOperator: true),
          ]),

          buildRow([
            calcButton(context, "7"),
            calcButton(context, "8"),
            calcButton(context, "9"),
            calcButton(context, "×", isOperator: true),
          ]),

          buildRow([
            calcButton(context, "4"),
            calcButton(context, "5"),
            calcButton(context, "6"),
            calcButton(context, "-", isOperator: true),
          ]),

          buildRow([
            calcButton(context, "1"),
            calcButton(context, "2"),
            calcButton(context, "3"),
            calcButton(context, "+", isOperator: true),
          ]),

          buildRow([
            calcButton(context, "."),
            calcButton(context, "0"),
            calcButton(context, "00"),
            calcButton(context, "=", isEqual: true),
          ]),

          const SizedBox(height: 10),
        ],
      ),
    );
  }
}