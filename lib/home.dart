import 'package:flutter/material.dart';
import 'matrix.dart';

enum Op { add, sub, mul, detA, invA, resetAll }

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int n = 3;
  List<TextEditingController> a = [];
  List<TextEditingController> b = [];
  Matrix? result;
  String msg = '';

  @override
  void initState() {
    super.initState();
    _init(n);
  }

  void _init(int size) {
    for (final c in [...a, ...b]) {
      c.dispose();
    }
    n = size;
    a = List.generate(n * n, (_) => TextEditingController(text: '0'));
    b = List.generate(n * n, (_) => TextEditingController(text: '0'));
    result = null;
    msg = '';
    setState(() {});
  }

  Matrix _read(List<TextEditingController> cs) {
    final values = cs.map((e) => double.tryParse(e.text.trim()) ?? 0).toList();
    return Matrix.fromFlat(n, n, values);
  }

  void _resetMatrix(List<TextEditingController> cs) {
    for (final c in cs) {
      c.text = '0';
    }
    setState(() {
      result = null;
      msg = '';
    });
  }

  void _run(Op op) {
    final A = _read(a);
    final B = _read(b);
    try {
      switch (op) {
        case Op.add:
          setState(() {
            result = A + B;
            msg = 'A + B';
          });
          break;
        case Op.sub:
          setState(() {
            result = A - B;
            msg = 'A - B';
          });
          break;
        case Op.mul:
          setState(() {
            result = A * B;
            msg = 'A × B';
          });
          break;
        case Op.detA:
          final d = A.det();
          setState(() {
            result = null;
            msg = 'det(A) = ${_fmt(d)}';
          });
          break;
        case Op.invA:
          final inv = A.inverse();
          setState(() {
            result = inv;
            msg = 'inv(A)';
          });
          break;
        case Op.resetAll:
          _resetMatrix(a);
          _resetMatrix(b);
          break;
      }
    } catch (e) {
      setState(() {
        result = null;
        msg = 'Error: $e';
      });
    }
  }

  String _fmt(num v) {
    final s = v.toStringAsFixed(6);
    return s.replaceFirst(RegExp(r'\.?0+\$'), '');
  }

  @override
  void dispose() {
    for (final c in [...a, ...b]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Matrix Calculator'),
        backgroundColor: Colors.blue,
      ),
      backgroundColor: Colors.grey[200],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Size:', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(width: 12),
                DropdownMenu<int>(
                  initialSelection: n,
                  onSelected: (value) {
                    if (value != null) {
                      _init(value);
                    }
                  },
                  dropdownMenuEntries: const [
                    DropdownMenuEntry(value: 2, label: '2 × 2'),
                    DropdownMenuEntry(value: 3, label: '3 × 3'),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildMatrices(),
            const SizedBox(height: 16),
            DropdownMenu<Op>(
              label: const Text('Operation'),
              onSelected: (value) {
                if (value != null) {
                  _run(value);
                }
              },
              dropdownMenuEntries: const [
                DropdownMenuEntry(value: Op.add, label: 'A + B'),
                DropdownMenuEntry(value: Op.sub, label: 'A - B'),
                DropdownMenuEntry(value: Op.mul, label: 'A × B'),
                DropdownMenuEntry(value: Op.detA, label: 'det(A)'),
                DropdownMenuEntry(value: Op.invA, label: 'inv(A)'),
                DropdownMenuEntry(value: Op.resetAll, label: 'Reset All'),
              ],
            ),
            const SizedBox(height: 16),
            _buildResultCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildMatrices() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool twoAcross = constraints.maxWidth >= 600;
        final double spacing = 24;
        final double width = twoAcross
            ? (constraints.maxWidth - spacing) / 2
            : constraints.maxWidth;

        if (twoAcross) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(width: width, child: _buildMatrixPanel('A', a)),
              const SizedBox(width: 24),
              SizedBox(width: width, child: _buildMatrixPanel('B', b)),
            ],
          );
        } else {
          return Column(
            children: [
              _buildMatrixPanel('A', a),
              const SizedBox(height: 24),
              _buildMatrixPanel('B', b),
            ],
          );
        }
      },
    );
  }

  Widget _buildMatrixPanel(String title, List<TextEditingController> cs) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Matrix $title', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        _buildMatrixTable(cs),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: () => _resetMatrix(cs),
          child: Text('Reset $title'),
        ),
      ],
    );
  }

  Widget _buildMatrixTable(List<TextEditingController> cs) {
    return Table(
      defaultColumnWidth: const FixedColumnWidth(60),
      border: TableBorder.all(color: Colors.black12),
      children: List.generate(n, (row) {
        return TableRow(
          children: List.generate(n, (col) {
            final index = row * n + col;
            return Padding(
              padding: const EdgeInsets.all(4),
              child: TextField(
                controller: cs[index],
                textAlign: TextAlign.center,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                  signed: true,
                ),
                decoration: const InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 8),
                  border: OutlineInputBorder(),
                ),
              ),
            );
          }),
        );
      }),
    );
  }

  Widget _buildResultCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Result', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            if (msg.isNotEmpty) Text(msg),
            if (result != null) ...[
              const SizedBox(height: 8),
              _renderMatrix(result!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _renderMatrix(Matrix m) {
    return Table(
      defaultColumnWidth: const IntrinsicColumnWidth(),
      children: List.generate(m.rows, (r) {
        return TableRow(
          children: List.generate(m.cols, (c) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Text(_fmt(m[r][c])),
            );
          }),
        );
      }),
    );
  }
}