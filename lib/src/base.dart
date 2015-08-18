// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of playfair;

class ChartData {
  const ChartData({ this.startX, this.endX, this.startY, this.endY, this.dataSet, this.numScaleLabels });
  final double startX;
  final double endX;
  final double startY;
  final double endY;
  final int numScaleLabels;
  final List<Point> dataSet;
}

class Chart extends LeafRenderObjectWrapper {
  Chart({ Key key, this.data }) : super(key: key);

  final ChartData data;

  RenderChart createNode() => new RenderChart(data: data);
  RenderChart get root => super.root;

  void syncRenderObject(Widget old) {
    super.syncRenderObject(old);
    renderObject.textTheme = Theme.of(this).text;
    renderObject.data = data;
  }
}

class RenderChart extends RenderConstrainedBox {

  RenderChart({
    ChartData data
  }) : _painter = new ChartPainter(data),
       super(child: null, additionalConstraints: BoxConstraints.expand);

  final ChartPainter _painter;

  ChartData get data => _painter.data;
  void set data(ChartData value) {
    assert(value != null);
    if (value == _painter.data)
      return;
    _painter.data = value;
    markNeedsPaint();
  }

  TextTheme get textTheme => _painter.textTheme;
  void set textTheme(TextTheme value) {
    assert(value != null);
    if (value == _painter.textTheme)
      return;
    _painter.textTheme = value;
    markNeedsPaint();
  }

  void paint(PaintingContext context, Offset offset) {
    assert(size.width != null);
    assert(size.height != null);
    _painter.paint(context.canvas, offset & size);
    super.paint(context, offset);
  }
}

class ChartPainter {
  ChartPainter();

  ChartData _data;
  ChartData get data => _data;
  void set data(ChartData value) {
    assert(data != null);
    if (_data == value)
      return;
    _data = value;
    _labels = null;
  }

  TextTheme _textTheme;
  TextTheme get textTheme => _textTheme;
  void set textTheme(TextTheme value) {
    assert(value != null);
    if (_textTheme == value)
      return;
    _textTheme = value;
    _labels = null;
  }

  List<ParagraphPainter> _scale;
  double _scaleWidth;
  int _numScaleLabels = 5;  // TODO(jackson): Make this configurable
  void _buildScale() {
    _scaleWidth = 0;
    _scale = new List<ScaleLabel>();
    for(int i = 0; i < data.numScaleLabels; i++) {
      double value =
      TextSpan text = new StyledTextSpan(_textTheme.body1, ["${value}"]);
      ParagraphPainter painter = new ParagraphPainter(text);
      _scale.add(painter);
    }
      for(ParagraphPainter painter in labels) {
        painter.maxWidth = rect.width;
        painter.layout();
        _scaleWidth = math.max(_scaleWidth, painter.maxContentWidth);
      }
      labels[0].paint(canvas, rect.bottomRight.toOffset());
      labels[1].paint(canvas, rect.topRight.toOffset());
      Offset position = new Offset(rect.width - painter.maxContentWidth, )
      label.paint(canvas, )
      painter.maxWidth = rect.width;
      painter.layout();
      _scaleWidth = math.max(_scaleWidth, painter.maxContentWidth);
  }

  Point _convertPointToRectSpace(Point point, Rect rect) {
    double x = rect.left + ((point.x - data.startX) / (data.endX - data.startX)) * rect.width;
    double y = rect.bottom - ((point.y - data.startY) / (data.endY - data.startY)) * rect.height;
    return new Point(x, y);
  }

  void _paintChart(sky.Canvas canvas, Rect rect) {
    Paint paint = new Paint()
      ..strokeWidth = 2.0
      ..color = const Color(0xFF000000);
    List<Point> dataSet = data.dataSet;
    assert(dataSet != null);
    assert(dataSet.length > 0);
    Path path = new Path();
    Point start = _convertPointToRectSpace(data.dataSet[0], rect);
    path.moveTo(start.x, start.y);
    for(Point point in data.dataSet) {
      Point current = _convertPointToRectSpace(point, rect);
      canvas.drawCircle(current, 3.0, paint);
      path.lineTo(current.x, current.y);
    }
    paint.setStyle(sky.PaintingStyle.stroke);
    canvas.drawPath(path, paint);
  }

  void _paintScale(sky.Canvas canvas, Rect rect) {
    // TODO(jackson): Generalize this to draw the whole axis
    if (_scale == null)
      _buildScale();
    double yPosition = 0.0;
    assert(data.numScaleLabels > 1);
    double increment = rect.height / (data.numScaleLabels - 1);
    for(ParagraphPainter label in _scale) {
      Offset offset = new Offset(rect.width - label.maxContentWidth, yPosition);
      label.painter.paint(canvas, label.offset);
      yPosition += increment;
    }
  }

  void paint(sky.Canvas canvas, Rect rect) {
    _paintChart(canvas, rect);
    _paintScale(canvas, rect);
  }
}
