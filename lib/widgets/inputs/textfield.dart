import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tumiapesa/models/bills.dart';
import 'package:tumiapesa/storage/database_helper.dart';

import 'package:tumiapesa/styles.dart';
import 'package:tumiapesa/utils/resources.dart';
import 'package:tumiapesa/views/marketplace/electricity/electricity.dart';
import 'package:tumiapesa/widgets/flexibles/spacers.dart';
import 'package:tumiapesa/widgets/image.dart';
import 'package:tumiapesa/widgets/text.dart';

class BaseTextField extends StatelessWidget {
  final String labelText;
  final String hintText, helperText;
  final List<TextInputFormatter> inputFormatters;
  final FormFieldSetter<String> onSaved;
  final FormFieldValidator<String> validator;
  final TextEditingController controller;
  final Widget suffixIcon, prefixIcon;
  final String initialValue;
  final TextInputType keyboardType;
  final bool obscureText;
  final bool readOnly, isOnboardingField;
  final Function onTap;
  final InputDecoration decoration;
  final bool autocorrect;
  final bool enableSuggestions;

  BaseTextField({
    this.labelText,
    this.hintText,
    this.helperText,
    this.inputFormatters,
    this.readOnly,
    this.onTap,
    this.decoration,
    this.onSaved,
    this.validator,
    this.controller,
    this.initialValue,
    this.suffixIcon,
    this.prefixIcon,
    this.keyboardType,
    this.isOnboardingField,
    this.obscureText,
    this.enableSuggestions,
    this.autocorrect,
  }) : super();

  @override
  Widget build(BuildContext context) {
    final _border = OutlineInputBorder(
      borderRadius: isOnboardingField
          ? BorderRadius.circular(25)
          : BorderRadius.circular(14),
      borderSide: BorderSide(
        color: AppColors.lightGrey,
        width: 1.2,
      ),
    );

    return TextFormField(
      controller: controller,
      inputFormatters: inputFormatters,
      readOnly: readOnly ?? false,
      onSaved: onSaved,
      validator: validator,
      initialValue: initialValue,
      keyboardType: keyboardType,
      obscureText: obscureText ?? false,
      onTap: () => onTap(),
      style: TextStyles.body1
          .copyWith(color: Colors.black, fontSize: FontSizes.s16),
      decoration: InputDecoration(
        hintText: hintText,
        helperText: helperText,
        errorStyle: TextStyles.caption.copyWith(color: AppColors.errorColor),
        labelStyle: TextStyles.caption.copyWith(color: AppColors.greyColor),
        hintStyle: TextStyles.body1.copyWith(color: AppColors.greyColor),
        helperStyle: TextStyles.caption.copyWith(color: AppColors.primaryColor),
        isDense: true,
        prefixIcon: prefixIcon != null
            ? Padding(
                padding: const EdgeInsetsDirectional.only(start: 12.0),
                child: prefixIcon,
              )
            : null,
        suffixIcon: suffixIcon != null
            ? Padding(
                padding: const EdgeInsetsDirectional.only(end: 12.0),
                child: suffixIcon,
              )
            : null,
        border: _border,
        enabledBorder: _border,
        focusedBorder: _border.copyWith(
          borderSide: BorderSide(
            color: AppColors.primaryColor,
            width: 0.8,
          ),
        ),
        errorBorder: _border,
        focusedErrorBorder: _border,
      ),
    );
  }
}

class TextInputField extends BaseTextField {
  TextInputField({
    @required FormFieldSetter<String> onSaved,
    InputDecoration decoration,
    String labelText,
    String hintText,
    String helperText,
    TextEditingController controller,
    Function onTap,
    String Function(String) validator,
    String initialValue,
    bool isOnboardingField,
    bool readOnly,
    bool obscureText,
    bool enableSuggestions,
    bool autocorrect,
    Widget suffixIcon,
    TextInputType keyboardType,
  }) : super(
            decoration: decoration,
            obscureText: obscureText,
            enableSuggestions: enableSuggestions,
            autocorrect: autocorrect,
            labelText: labelText,
            hintText: hintText,
            controller: controller,
            helperText: helperText,
            onSaved: onSaved,
            onTap: onTap,
            readOnly: readOnly,
            isOnboardingField: isOnboardingField ?? false,
            initialValue: initialValue,
            suffixIcon: suffixIcon,
            validator: validator,
            keyboardType: keyboardType ?? TextInputType.text);
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (labelText != null)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SmallText(labelText),
          ),
        super.build(context)
      ],
    );
  }
}

class DropDownItem {
  final String title;
  final String value;
  final String imgUrl;
  const DropDownItem({this.title, this.value, this.imgUrl});

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is DropDownItem &&
        o.title == title &&
        o.value == value &&
        o.imgUrl == imgUrl;
  }

  @override
  int get hashCode => title.hashCode ^ value.hashCode ^ imgUrl.hashCode;
}

class DropDownTextInputField extends StatefulWidget {
  final String labelText;
  final String hintText, helperText;
  final FormFieldSetter<DropDownItem> onSaved;
  final Function onTap;
  final FormFieldValidator<DropDownItem> validator;
  final Widget suffixIcon, prefixIcon;
  final bool isOnboardingField;
  final List<DropDownItem> items;
  final DatabaseHandler handler;

  DropDownTextInputField({
    this.labelText,
    this.hintText,
    this.helperText,
    this.onSaved,
    this.onTap,
    this.validator,
    this.suffixIcon,
    this.prefixIcon,
    this.items,
    this.handler,
    this.isOnboardingField = false,
  }) : super();

  @override
  _DropDownTextInputFieldState createState() => _DropDownTextInputFieldState();
}

class _DropDownTextInputFieldState extends State<DropDownTextInputField> {
  DropDownItem item;

  @override
  Widget build(BuildContext context) {
    final _border = OutlineInputBorder(
      borderRadius: widget.isOnboardingField
          ? BorderRadius.circular(25)
          : BorderRadius.circular(14),
      borderSide: BorderSide(
        color: AppColors.lightGrey,
        width: 1.2,
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.labelText != null)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SmallText(widget.labelText),
          ),
        DropdownButtonFormField<DropDownItem>(
          items: widget.items
              .map(
                (e) => DropdownMenuItem<DropDownItem>(
                  value: e,
                  child: Row(
                    children: <Widget>[
                      Image.asset(
                        e.imgUrl,
                        width: 30,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      MediumText(e.title)
                    ],
                  ),
                ),
              )
              .toList(),
          itemHeight: 70,
          value: item ?? widget.items.first,
          onChanged: (value) => setState(() {
            item = value;
            print(item.title);
            if (item.title.contains('NWSC')) {
              _getBills(item.value);
              ElectricityPage.of(context).isNWSC = true;
            } else {
              ElectricityPage.of(context).isNWSC = false;
            }
          }),
          icon: ImageIcon(
            AssetImage(AppIcons.caretDown),
            color: AppColors.primaryColor,
          ),
          onSaved: widget.onSaved,
          validator: widget.validator,
          style: TextStyles.body1
              .copyWith(color: Colors.black, fontSize: FontSizes.s16),
          decoration: InputDecoration(
            hintText: widget.hintText,
            helperText: widget.helperText,
            errorStyle:
                TextStyles.caption.copyWith(color: AppColors.errorColor),
            labelStyle: TextStyles.caption.copyWith(color: AppColors.greyColor),
            hintStyle: TextStyles.body1.copyWith(color: AppColors.greyColor),
            helperStyle:
                TextStyles.caption.copyWith(color: AppColors.primaryColor),
            isDense: true,
            border: _border,
            enabledBorder: _border,
            focusedBorder: _border.copyWith(
              borderSide: BorderSide(
                color: AppColors.primaryColor,
                width: 0.8,
              ),
            ),
            errorBorder: _border,
            focusedErrorBorder: _border,
          ),
        ),
      ],
    );
  }

  _getBills(String code) async {
    await DatabaseHandler().activeBill(code).then((res) {
      setState(() {
        if (res.isNotEmpty) {
          ElectricityPage.of(context).waterBills = res;
        }
      });
    });
  }
}
