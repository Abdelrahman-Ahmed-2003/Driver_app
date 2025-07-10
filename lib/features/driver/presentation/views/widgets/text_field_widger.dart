import 'package:dirver/core/utils/colors_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';

Widget buildTextFieldString({
  required String label,
  required Function(String?) onSaved,
  TextEditingController? controller,
}) {
  final effectiveController = controller ?? TextEditingController();
  return Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: TextFormField(
      controller: effectiveController,
      textInputAction: TextInputAction.next,
      keyboardType: TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: AppColors.darkGrey,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        labelStyle: const TextStyle(color: AppColors.primaryColor),
      ),
      style: const TextStyle(color: AppColors.whiteColor),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'This field is required';
        }
        return null;
      },
      onSaved: onSaved,
    ),
  );
}

Widget buildTextFieldNumber({
  required String label,
  required Function(String?) onSaved,
  TextEditingController? controller,
}) {
  final effectiveController = controller ?? MaskedTextController(mask: '0000 0000 0000 0000');
  return Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: TextFormField(
      controller: effectiveController,
      textInputAction: TextInputAction.next,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: AppColors.darkGrey,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        labelStyle: const TextStyle(color: AppColors.primaryColor),
      ),
      style: const TextStyle(color: AppColors.whiteColor),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'This field is required';
        }
        return null;
      },
      onSaved: onSaved,
    ),
  );
}

Widget buildDateField({
  required String label,
  required TextEditingController controller,
  required Function(String?) onSaved,
  required BuildContext context,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: TextFormField(
      controller: controller,
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: AppColors.darkGrey,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        labelStyle: const TextStyle(color: AppColors.primaryColor),
        suffixIcon: const Icon(Icons.calendar_today, color: AppColors.primaryColor),
      ),
      style: const TextStyle(color: AppColors.whiteColor),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'This field is required';
        }
        return null;
      },
      onTap: () async {
        FocusScope.of(context).requestFocus(FocusNode());
        DateTime? picked = await showDatePicker(
          context: context,
          initialDate: DateTime(2000, 1, 1),
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: ColorScheme.light(
                  primary: AppColors.primaryColor,
                  onPrimary: AppColors.whiteColor,
                  surface: AppColors.cardLight,
                  onSurface: AppColors.textColor,
                ),
                dialogBackgroundColor: AppColors.cardLight,
              ),
              child: child!,
            );
          },
        );
        if (picked != null) {
          controller.text = "${picked.year.toString().padLeft(4, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
        }
      },
      onSaved: onSaved,
    ),
  );
}