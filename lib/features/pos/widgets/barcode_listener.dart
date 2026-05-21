import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// Listens for keystroke bursts characteristic of USB/Bluetooth HID barcode
/// scanners (rapid sequence of printable chars terminated by Enter).
///
/// Mirrors the React `useBarcodeScanner` heuristic: gather chars where each
/// key arrives within [interKeyTimeout]; on Enter, if total length > 3 and the
/// whole burst arrived within [maxBurstDuration], fire [onScan].
class BarcodeListener extends StatefulWidget {
  const BarcodeListener({
    super.key,
    required this.child,
    required this.onScan,
    this.paused = false,
    this.interKeyTimeout = const Duration(milliseconds: 70),
    this.maxBurstDuration = const Duration(milliseconds: 500),
    this.minLength = 4,
  });

  final Widget child;
  final ValueChanged<String> onScan;
  final bool paused;
  final Duration interKeyTimeout;
  final Duration maxBurstDuration;
  final int minLength;

  @override
  State<BarcodeListener> createState() => _BarcodeListenerState();
}

class _BarcodeListenerState extends State<BarcodeListener> {
  final _focusNode = FocusNode(debugLabel: 'barcode-listener', skipTraversal: true);
  final StringBuffer _buffer = StringBuffer();
  DateTime? _firstKeyAt;
  DateTime? _lastKeyAt;

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (widget.paused) {
      _reset();
      return KeyEventResult.ignored;
    }
    if (event is! KeyDownEvent) return KeyEventResult.ignored;

    // Skip when an editable text field has focus — let it handle typing normally.
    final primary = FocusManager.instance.primaryFocus;
    if (primary != null && primary != _focusNode && _isTextInput(primary.context)) {
      _reset();
      return KeyEventResult.ignored;
    }

    final now = DateTime.now();
    if (_lastKeyAt != null && now.difference(_lastKeyAt!) > widget.interKeyTimeout) {
      _reset();
    }
    _firstKeyAt ??= now;
    _lastKeyAt = now;

    if (event.logicalKey == LogicalKeyboardKey.enter ||
        event.logicalKey == LogicalKeyboardKey.numpadEnter) {
      final code = _buffer.toString();
      final burst = (_firstKeyAt != null && _lastKeyAt != null)
          ? _lastKeyAt!.difference(_firstKeyAt!)
          : Duration.zero;
      _reset();
      if (code.length >= widget.minLength && burst <= widget.maxBurstDuration) {
        widget.onScan(code);
        return KeyEventResult.handled;
      }
      return KeyEventResult.ignored;
    }

    final ch = event.character;
    if (ch != null && ch.length == 1 && ch.codeUnitAt(0) >= 0x20) {
      _buffer.write(ch);
    }
    return KeyEventResult.ignored;
  }

  void _reset() {
    _buffer.clear();
    _firstKeyAt = null;
    _lastKeyAt = null;
  }

  bool _isTextInput(BuildContext? ctx) {
    if (ctx == null) return false;
    final editable = ctx.findAncestorWidgetOfExactType<EditableText>();
    return editable != null;
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: _onKey,
      child: widget.child,
    );
  }
}
