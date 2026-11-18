import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_text.dart';
import '../../theme/app_tokens.dart';

class StickerTextField extends StatefulWidget {
  const StickerTextField({super.key, this.controller, required this.label, this.hint, this.helperText, this.errorText, this.validator, this.onChanged, this.onFieldSubmitted, this.keyboardType, this.textInputAction, this.autofillHints, this.obscureText = false, this.prefixIcon, this.enabled = true, this.maxLength, this.focusNode});

  final TextEditingController? controller;
  final String label;
  final String? hint;
  final String? helperText;
  final String? errorText;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onFieldSubmitted;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final bool obscureText;
  final Widget? prefixIcon;
  final bool enabled;
  final int? maxLength;
  final FocusNode? focusNode;

  @override
  State<StickerTextField> createState() => _StickerTextFieldState();
}

class _StickerTextFieldState extends State<StickerTextField> {
  late bool _hidden = widget.obscureText;

  @override
  Widget build(BuildContext context) {
    final extras = Theme.of(context).extension<AppThemeExtras>()!;
    final error = widget.errorText;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(widget.label, style: AppText.label.copyWith(color: Theme.of(context).colorScheme.onSurface)),
        const SizedBox(height: AppSpace.xxs),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.sm + 2),
            boxShadow: (error == null && (widget.focusNode?.hasFocus ?? false)) ? stickerShadow(extras.outline, offset: AppShadowOffset.sm) : null,
          ),
          child: TextFormField(
            controller: widget.controller,
            focusNode: widget.focusNode,
            enabled: widget.enabled,
            obscureText: _hidden,
            enableSuggestions: !widget.obscureText,
            autocorrect: !widget.obscureText,
            keyboardType: widget.keyboardType,
            textInputAction: widget.textInputAction,
            autofillHints: widget.autofillHints,
            maxLength: widget.maxLength,
            validator: widget.validator,
            onChanged: (value) { setState(() {}); widget.onChanged?.call(value); },
            onFieldSubmitted: widget.onFieldSubmitted,
            decoration: InputDecoration(
              hintText: widget.hint,
              helperText: widget.helperText,
              errorText: null,
              filled: true,
              fillColor: widget.enabled ? Theme.of(context).colorScheme.surface : Theme.of(context).disabledColor,
              prefixIcon: widget.prefixIcon,
              suffixIcon: widget.obscureText
                  ? IconButton(
                      tooltip: _hidden ? 'Mostra testo' : 'Nascondi testo',
                      onPressed: widget.enabled ? () => setState(() => _hidden = !_hidden) : null,
                      icon: Icon(_hidden ? Icons.visibility_off : Icons.visibility),
                    )
                  : null,
              contentPadding: const EdgeInsets.symmetric(horizontal: AppSpace.md, vertical: AppSpace.sm),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.sm + 2), borderSide: BorderSide(color: error != null ? AppColors.error : extras.divider, width: error != null ? AppStroke.base : 1.8)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.sm + 2), borderSide: BorderSide(color: error != null ? AppColors.error : extras.divider, width: error != null ? AppStroke.base : 1.8)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.sm + 2), borderSide: BorderSide(color: error != null ? AppColors.error : extras.outline, width: AppStroke.base)),
              disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.sm + 2), borderSide: BorderSide(color: extras.divider, width: 1.8)),
            ),
          ),
        ),
        if (error != null) ...[
          const SizedBox(height: AppSpace.xxs),
          Row(children: [const Icon(Icons.error_outline, color: AppColors.error), const SizedBox(width: AppSpace.xs), Expanded(child: Text(error, style: AppText.caption.copyWith(color: AppColors.error)))])
        ],
      ],
    );
  }
}
