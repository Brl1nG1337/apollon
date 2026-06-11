import 'package:flutter/material.dart';

class DashboardExpansionProvider extends ChangeNotifier {
  Widget? _activeWidget;
  Widget? _activeDetail;
  Rect? _sourceRect;
  EdgeInsets? _sourcePadding;

  Widget? get activeWidget => _activeWidget;
  Widget? get activeDetail => _activeDetail;
  Rect? get sourceRect => _sourceRect;
  EdgeInsets? get sourcePadding => _sourcePadding;

  bool get isExpanded => _activeWidget != null;

  void expand({
    required Widget child,
    required Widget detailChild,
    required Rect rect,
    required EdgeInsets padding,
  }) {
    _activeWidget = child;
    _activeDetail = detailChild;
    _sourceRect = rect;
    _sourcePadding = padding;
    notifyListeners();
  }

  void close() {
    _activeWidget = null;
    _activeDetail = null;
    _sourceRect = null;
    notifyListeners();
  }
}
