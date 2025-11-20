class Matrix {
  final int rows, cols;
  final List<List<double>> _m;
  Matrix(this.rows, this.cols, List<List<double>> data)
    : _m = List.generate(rows, (r) => List<double>.from(data[r])) {
    if (data.length != rows || data.any((r) => r.length != cols)) {
      throw ArgumentError('Matrix dimensions do not match provided data.');
    }
  }
  factory Matrix.fromFlat(int rows, int cols, List<double> v) {
    if (v.length != rows * cols) {
      throw ArgumentError('Flat data length must be rows*cols.');
    }
    return Matrix(
      rows,
      cols,
      List.generate(rows, (r) {
        return List.generate(cols, (c) => v[r * cols + c]);
      }),
    );
  }

  List<double> operator [](int r) => _m[r];

  Matrix operator +(Matrix o) => _elementWise(o, (a, b) => a + b);
  Matrix operator -(Matrix o) => _elementWise(o, (a, b) => a - b);

  Matrix _elementWise(Matrix o, double Function(double, double) f) {
    _sameShape(o);
    return Matrix(
      rows,
      cols,
      List.generate(rows, (r) {
        return List.generate(cols, (c) => f(_m[r][c], o._m[r][c]));
      }),
    );
  }

  Matrix operator *(Matrix o) {
    if (cols != o.rows) {
      throw ArgumentError('A.cols must equal B.rows');
    }
    return Matrix(
      rows,
      o.cols,
      List.generate(rows, (r) {
        return List.generate(o.cols, (c) {
          double sum = 0;
          for (int k = 0; k < cols; k++) {
            sum += _m[r][k] * o._m[k][c];
          }
          return sum;
        });
      }),
    );
  }

  double det() {
    if (rows != cols) {
      throw ArgumentError('det() requires a square matrix');
    }
    if (rows == 2) {
      return _m[0][0] * _m[1][1] - _m[0][1] * _m[1][0];
    }
    if (rows == 3) {
      final a = _m;
      return a[0][0] * (a[1][1] * a[2][2] - a[1][2] * a[2][1]) -
          a[0][1] * (a[1][0] * a[2][2] - a[1][2] * a[2][0]) +
          a[0][2] * (a[1][0] * a[2][1] - a[1][1] * a[2][0]);
    }
    throw UnimplementedError('det() only implemented for 2x2 and 3x3');
  }

  Matrix inverse() {
    if (rows != cols) {
      throw ArgumentError('inverse() requires a square matrix');
    }
    if (rows == 2) {
      return _inverse2x2();
    }
    if (rows == 3) {
      final d = det();
      if (d == 0) {
        throw ArgumentError('Matrix is singular (det = 0)');
      }
      final a = _m;

      double minorDet(int r, int c) {
        final rowsIndex = [0, 1, 2]..remove(r);
        final colsIndex = [0, 1, 2]..remove(c);
        final m00 = a[rowsIndex[0]][colsIndex[0]];
        final m01 = a[rowsIndex[0]][colsIndex[1]];
        final m10 = a[rowsIndex[1]][colsIndex[0]];
        final m11 = a[rowsIndex[1]][colsIndex[1]];
        return m00 * m11 - m01 * m10;
      }

      final adj = List.generate(3, (r) {
        return List.generate(3, (c) {
          final sign = ((r + c) % 2 == 0) ? 1.0 : -1.0;
          return sign * minorDet(c, r);
        });
      });

      return Matrix(
        3,
        3,
        List.generate(3, (r) {
          return List.generate(3, (c) => adj[r][c] / d);
        }),
      );
    }
    throw UnimplementedError('inverse() only supported for 2x2 and 3x3');
  }

  Matrix _inverse2x2() {
    final d = det();
    if (d == 0) {
      throw ArgumentError('Matrix is singular (det = 0)');
    }
    final a = _m;
    return Matrix(2, 2, [
      [a[1][1] / d, -a[0][1] / d],
      [-a[1][0] / d, a[0][0] / d],
    ]);
  }

  void _sameShape(Matrix o) {
    if (rows != o.rows || cols != o.cols) {
      throw ArgumentError('Matrices must have the same shape');
    }
  }
}