import 'package:flutter/material.dart';

/// Text field + search button. Stateless about *what* searching means —
/// it just reports the entered city via [onSearch] (separation of concerns:
/// this widget never touches the cubit directly).
class CitySearchField extends StatefulWidget {
  const CitySearchField({super.key, required this.onSearch, this.enabled = true});

  final ValueChanged<String> onSearch;

  /// Disabled while a request is in flight.
  final bool enabled;

  @override
  State<CitySearchField> createState() => _CitySearchFieldState();
}

class _CitySearchFieldState extends State<CitySearchField> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    if (widget.enabled) widget.onSearch(_controller.text);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            enabled: widget.enabled,
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => _submit(),
            decoration: const InputDecoration(
              hintText: 'Enter a city name',
              prefixIcon: Icon(Icons.location_city),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          height: 56,
          child: FilledButton.icon(
            onPressed: widget.enabled ? _submit : null,
            icon: const Icon(Icons.search),
            label: const Text('Search'),
          ),
        ),
      ],
    );
  }
}
