import 'package:flutter/material.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String _display = '0';
  String _expression = '';
  double _operand1 = 0;
  String _operator = '';
  bool _newInput = false;

  void _onDigit(String digit) {
    setState(() {
      if (_newInput || _display == '0') {
        _display = digit;
        _newInput = false;
      } else {
        if (_display.length < 15) _display += digit;
      }
    });
  }

  void _onDecimal() {
    setState(() {
      if (_newInput) {
        _display = '0.';
        _newInput = false;
      } else if (!_display.contains('.')) {
        _display += '.';
      }
    });
  }

  void _onOperator(String op) {
    setState(() {
      _operand1 = double.tryParse(_display) ?? 0;
      _operator = op;
      _expression = '${_fmt(_operand1)} $op';
      _newInput = true;
    });
  }

  void _onEquals() {
    if (_operator.isEmpty) return;
    final op2 = double.tryParse(_display) ?? 0;
    double result = 0;
    switch (_operator) {
      case '+': result = _operand1 + op2; break;
      case '-': result = _operand1 - op2; break;
      case '×': result = _operand1 * op2; break;
      case '÷': result = op2 != 0 ? _operand1 / op2 : 0; break;
      case '%': result = _operand1 * op2 / 100; break;
    }
    setState(() {
      _expression = '$_expression ${_fmt(op2)} =';
      _display = _fmt(result);
      _operator = '';
      _newInput = true;
    });
  }

  void _onClear() => setState(() {
    _display = '0';
    _expression = '';
    _operator = '';
    _operand1 = 0;
    _newInput = false;
  });

  void _onBackspace() {
    setState(() {
      if (_display.length > 1) {
        _display = _display.substring(0, _display.length - 1);
      } else {
        _display = '0';
      }
    });
  }

  void _onToggleSign() {
    setState(() {
      final val = double.tryParse(_display) ?? 0;
      _display = _fmt(-val);
    });
  }

  String _fmt(double val) {
    if (val == val.roundToDouble() && val.abs() < 1e10) {
      return val.toInt().toString();
    }
    return val.toStringAsFixed(8).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculator', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    _expression,
                    style: TextStyle(fontSize: 16, color: Colors.grey[500]),
                  ),
                  const SizedBox(height: 8),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      _display,
                      style: const TextStyle(fontSize: 52, fontWeight: FontWeight.w300),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _row([
                  _btn('AC', _onClear, type: _BtnType.func),
                  _btn('+/-', _onToggleSign, type: _BtnType.func),
                  _btn('%', () => _onOperator('%'), type: _BtnType.func),
                  _btn('÷', () => _onOperator('÷'), type: _BtnType.op),
                ]),
                _row([
                  _btn('7', () => _onDigit('7')),
                  _btn('8', () => _onDigit('8')),
                  _btn('9', () => _onDigit('9')),
                  _btn('×', () => _onOperator('×'), type: _BtnType.op),
                ]),
                _row([
                  _btn('4', () => _onDigit('4')),
                  _btn('5', () => _onDigit('5')),
                  _btn('6', () => _onDigit('6')),
                  _btn('-', () => _onOperator('-'), type: _BtnType.op),
                ]),
                _row([
                  _btn('1', () => _onDigit('1')),
                  _btn('2', () => _onDigit('2')),
                  _btn('3', () => _onDigit('3')),
                  _btn('+', () => _onOperator('+'), type: _BtnType.op),
                ]),
                _row([
                  _btn('⌫', _onBackspace, type: _BtnType.func),
                  _btn('0', () => _onDigit('0')),
                  _btn('.', _onDecimal),
                  _btn('=', _onEquals, type: _BtnType.eq),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(List<Widget> children) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(children: children.map((w) => Expanded(child: Padding(padding: const EdgeInsets.all(4), child: w))).toList()),
  );

  Widget _btn(String label, VoidCallback onTap, {_BtnType type = _BtnType.num}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;

    Color bg;
    Color fg;
    switch (type) {
      case _BtnType.op:
        bg = cs.primary;
        fg = cs.onPrimary;
        break;
      case _BtnType.func:
        bg = isDark ? const Color(0xFF2C2F3E) : const Color(0xFFE8EAF0);
        fg = cs.onSurface;
        break;
      case _BtnType.eq:
        bg = cs.secondary;
        fg = cs.onSecondary;
        break;
      default:
        bg = isDark ? const Color(0xFF1C1F2A) : Colors.white;
        fg = cs.onSurface;
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        height: 68,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 4, offset: const Offset(0, 2)),
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500, color: fg),
          ),
        ),
      ),
    );
  }
}

enum _BtnType { num, op, func, eq }
