import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_quill/flutter_quill.dart';

class NoteTile extends StatefulWidget {
  final Document content;
  final DateTime? dateTime;
  final VoidCallback? onTap;
  final bool isPinned;
  final VoidCallback onSelectionToggle;
  final bool isSelecting;
  final bool isSelected;

  const NoteTile({
    super.key,
    required this.content,
    this.dateTime,
    required this.onTap,
    required this.isPinned,
    required this.onSelectionToggle,
    this.isSelecting = false,
    this.isSelected = false,
  });

  @override
  State<NoteTile> createState() => _NoteTileState();
}

class _NoteTileState extends State<NoteTile> {
  late final QuillController _controller;
  final GlobalKey _measureKey = GlobalKey();
  bool _isOverFlowing = false;
  bool _measured = false;
  final int maxHeight = 250;
  @override
  void initState() {
    super.initState();
    _controller = QuillController(
      document: widget.content,
      selection: const TextSelection.collapsed(offset: 0),
      readOnly: true,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _measureContent());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _measureContent() {
    final renderBox =
        _measureKey.currentContext?.findRenderObject() as RenderBox?;

    if (renderBox == null || !renderBox.hasSize) return;

    final overFlowing = renderBox.size.height >= maxHeight;
    if (overFlowing != _isOverFlowing || !_measured) {
      setState(() {
        _measured = true;
        _isOverFlowing = overFlowing;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool clip = _measured && _isOverFlowing;
    return GestureDetector(
      onTap: () {
        if (widget.isSelecting) {
          widget.onSelectionToggle();
        } else {
          widget.onTap?.call();
        }
      },
      onLongPress: () {
        widget.onSelectionToggle();
      },
      child: Stack(
        children: [
          Container(
            key: _measureKey,
            constraints: BoxConstraints(maxHeight: maxHeight.toDouble()),
            clipBehavior: clip ? Clip.hardEdge : Clip.none,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Theme.of(
                    context,
                  ).colorScheme.shadow.withValues(alpha: 0.3),
                  spreadRadius: 0,
                  blurRadius: 5,
                ),
              ],
              border: Border.all(
                color: Theme.of(
                  context,
                ).colorScheme.shadow.withValues(alpha: 0.3),
                width: 1,
              ),
              borderRadius: const BorderRadius.all(Radius.circular(10)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,

                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.dateTime != null)
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4.0),
                          child: Text(
                            DateFormat.yMMMd().format(widget.dateTime!),
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        if (widget.isPinned) Icon(Icons.push_pin, size: 15),
                      ],
                    ),

                  Flexible(
                    child: IgnorePointer(
                      child: QuillEditor.basic(controller: _controller),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (clip)
            Positioned(
              left: 0,
              right: 0,
              bottom: 7,
              height: 60,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Theme.of(context).colorScheme.surface.withAlpha(0),
                      Theme.of(context).colorScheme.surface,
                    ],
                  ),
                ),
              ),
            ),

          if (widget.isSelected)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(244, 114, 1, 0.25),
                  border: Border.all(color: Colors.orange, width: 2),
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
