import 'package:flutter/material.dart';
import '../services/location_service.dart';

class LocationSearchField extends StatefulWidget {
  final String label;
  final String hint;
  final Function(PlaceSuggestion)? onSelected;
  final TextEditingController? controller;

  const LocationSearchField({
    Key? key,
    this.label = 'Search Location',
    this.hint = 'Enter town or city...',
    this.onSelected,
    this.controller,
  }) : super(key: key);

  @override
  State<LocationSearchField> createState() => _LocationSearchFieldState();
}

class _LocationSearchFieldState extends State<LocationSearchField> {
  late final TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  List<PlaceSuggestion> _suggestions = [];

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    if (widget.controller == null) {
      _controller.dispose();
    }
    _removeOverlay();
    super.dispose();
  }

  void _onFocusChange() {
    // Only hide overlay on focus loss.
    // NEVER auto-show suggestions on focus gain — that would show results
    // for whatever is already in the field (e.g. "My Location") without
    // the user intending to search.
    if (!_focusNode.hasFocus) {
      _removeOverlay();
    }
  }

  void _updateSuggestions(String query) {
    if (query.isEmpty) {
      _suggestions = [];
      _removeOverlay();
      return;
    }

    setState(() {
      _suggestions = LocationService().search(query);
    });

    if (_suggestions.isNotEmpty) {
      _showOverlay();
    } else {
      _removeOverlay();
    }
  }

  void _showOverlay() {
    _removeOverlay();

    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0, size.height + 8),
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
            clipBehavior: Clip.antiAlias,
            child: Container(
              constraints: const BoxConstraints(maxHeight: 300),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListView.separated(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: _suggestions.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final suggestion = _suggestions[index];
                  return ListTile(
                    leading: const Icon(Icons.location_on_outlined, color: Colors.blue),
                    title: Text(
                      suggestion.place,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('${suggestion.district}, ${suggestion.state}'),
                    onTap: () {
                      _controller.text = suggestion.place;
                      widget.onSelected?.call(suggestion);
                      _focusNode.unfocus();
                      _removeOverlay();
                    },
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.label.isNotEmpty) ...[
            Text(
              widget.label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
          ],
          TextField(
            controller: _controller,
            focusNode: _focusNode,
            onChanged: _updateSuggestions,
            decoration: InputDecoration(
              hintText: widget.hint,
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              suffixIcon: _controller.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 20),
                      onPressed: () {
                        _controller.clear();
                        _updateSuggestions('');
                      },
                    )
                  : null,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              filled: true,
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.blue, width: 1.5),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
