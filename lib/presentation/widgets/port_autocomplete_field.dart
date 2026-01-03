import 'dart:async';
import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../core/services/port_airport_service.dart';

/// Autocomplete field for selecting ports or airports
/// Used in quote request forms for POL/POD selection
class PortAutocompleteField extends StatefulWidget {
  final String label;
  final String hint;
  final bool isAirport; // true for airports, false for ports
  final bool isDestination; // true for Ecuador destinations only
  final TextEditingController controller;
  final Color accentColor;
  final Color backgroundColor;
  final Function(Map<String, dynamic>)? onSelected;

  const PortAutocompleteField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    this.isAirport = false,
    this.isDestination = false,
    this.accentColor = AppColors.neonGreen,
    this.backgroundColor = const Color(0xFF0F1623),
    this.onSelected,
  });

  @override
  State<PortAutocompleteField> createState() => _PortAutocompleteFieldState();
}

class _PortAutocompleteFieldState extends State<PortAutocompleteField> {
  final PortAirportService _service = PortAirportService();
  final LayerLink _layerLink = LayerLink();
  final FocusNode _focusNode = FocusNode();

  OverlayEntry? _overlayEntry;
  List<Map<String, dynamic>> _suggestions = [];
  bool _isLoading = false;
  Timer? _debounce;
  bool _isSelecting = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
    widget.controller.addListener(_onTextChanged);

    // If destination, pre-load Ecuador options
    if (widget.isDestination) {
      _loadDestinationOptions();
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _removeOverlay();
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus) {
      if (widget.isDestination && _suggestions.isNotEmpty) {
        _showOverlay();
      }
    } else {
      // Delay removal to allow selection
      Future.delayed(const Duration(milliseconds: 200), () {
        if (!_isSelecting) {
          _removeOverlay();
        }
      });
    }
  }

  void _onTextChanged() {
    if (_isSelecting) return;

    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _search(widget.controller.text);
    });
  }

  Future<void> _loadDestinationOptions() async {
    setState(() => _isLoading = true);
    try {
      if (widget.isAirport) {
        _suggestions = await _service.getEcuadorAirports();
      } else {
        _suggestions = await _service.getEcuadorPorts();
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _search(String query) async {
    if (widget.isDestination) {
      // For destinations, filter pre-loaded Ecuador options
      if (query.isEmpty) {
        await _loadDestinationOptions();
      } else {
        final lowerQuery = query.toLowerCase();
        final allOptions = widget.isAirport
            ? await _service.getEcuadorAirports()
            : await _service.getEcuadorPorts();
        _suggestions = allOptions.where((item) {
          final name = (item['name'] ?? '').toString().toLowerCase();
          final code =
              (item[widget.isAirport ? 'iata_code' : 'un_locode'] ?? '')
                  .toString()
                  .toLowerCase();
          final city = (item['ciudad_exacta'] ?? item['country'] ?? '')
              .toString()
              .toLowerCase();
          return name.contains(lowerQuery) ||
              code.contains(lowerQuery) ||
              city.contains(lowerQuery);
        }).toList();
      }
    } else {
      // For origins, search worldwide
      if (query.length < 2) {
        _suggestions = [];
        _removeOverlay();
        return;
      }

      setState(() => _isLoading = true);
      try {
        if (widget.isAirport) {
          _suggestions = await _service.searchAirports(query);
        } else {
          _suggestions = await _service.searchPorts(query);
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }

    if (_suggestions.isNotEmpty && _focusNode.hasFocus) {
      _showOverlay();
    } else {
      _removeOverlay();
    }
  }

  void _showOverlay() {
    _removeOverlay();

    final overlay = Overlay.of(context);
    final renderBox = context.findRenderObject() as RenderBox?;
    final size = renderBox?.size ?? Size.zero;

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0, size.height + 4),
          child: Material(
            color: Colors.transparent,
            child: Container(
              constraints: const BoxConstraints(maxHeight: 250),
              decoration: BoxDecoration(
                color: const Color(0xFF0A101D),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: widget.accentColor.withValues(alpha: 0.3)),
                boxShadow: [
                  BoxShadow(
                    color: widget.accentColor.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: _isLoading
                  ? const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: _suggestions.length,
                      itemBuilder: (context, index) {
                        final item = _suggestions[index];
                        return _buildSuggestionItem(item);
                      },
                    ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(_overlayEntry!);
  }

  Widget _buildSuggestionItem(Map<String, dynamic> item) {
    final String code;
    final String name;
    final String location;
    final IconData icon;

    if (widget.isAirport) {
      code = item['iata_code'] ?? '';
      name = item['ciudad_exacta'] ?? item['name'] ?? '';
      location = item['country'] ?? '';
      icon = Icons.flight;
    } else {
      code = item['un_locode'] ?? '';
      name = item['name'] ?? '';
      location = '${item['country'] ?? ''} • ${item['region'] ?? ''}';
      icon = Icons.directions_boat;
    }

    return InkWell(
      onTap: () => _selectItem(item),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: widget.accentColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: widget.accentColor, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: widget.accentColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          code,
                          style: TextStyle(
                            color: widget.accentColor,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    location,
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _selectItem(Map<String, dynamic> item) {
    _isSelecting = true;

    String displayText;
    if (widget.isAirport) {
      displayText =
          '${item['ciudad_exacta'] ?? item['name']} (${item['iata_code']})';
    } else {
      displayText = '${item['name']} (${item['un_locode']})';
    }

    widget.controller.text = displayText;
    widget.controller.selection = TextSelection.fromPosition(
      TextPosition(offset: displayText.length),
    );

    widget.onSelected?.call(item);

    _removeOverlay();
    _focusNode.unfocus();

    Future.delayed(const Duration(milliseconds: 100), () {
      _isSelecting = false;
    });
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
          Text(
            widget.label,
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: widget.controller,
            focusNode: _focusNode,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: const TextStyle(color: Colors.grey),
              prefixIcon: Icon(
                widget.isAirport ? Icons.flight_takeoff : Icons.anchor,
                color: widget.accentColor,
                size: 20,
              ),
              suffixIcon: _isLoading
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : widget.controller.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          color: Colors.grey,
                          onPressed: () {
                            widget.controller.clear();
                            _suggestions = [];
                            if (widget.isDestination) {
                              _loadDestinationOptions();
                            }
                          },
                        )
                      : null,
              filled: true,
              fillColor: widget.backgroundColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: widget.accentColor, width: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
