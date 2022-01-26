import 'package:flutter/material.dart';
import 'package:pinput/pin_put/pin_put.dart';
import 'package:tumiapesa/utils/resources.dart';

class PinInputField extends StatelessWidget {
  final int count;
  final ValueChanged<String> onSubmit;
  final FormFieldValidator<String> validator;
  final FormFieldSetter<String> onSaved;
  TextEditingController controller;
  PinInputField(
      {this.count = 4,
      this.controller,
      this.validator,
      this.onSaved,
      this.onSubmit,
      Key key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PinPut(
      key: key,
      fieldsCount: count,
      obscureText: "●",
      eachFieldHeight: 50,
      controller: controller,
      eachFieldWidth: 50,
      onSubmit: onSubmit,
      submittedFieldDecoration: buildBoxDecoration(),
      followingFieldDecoration: buildBoxDecoration(),
      selectedFieldDecoration: buildBoxDecoration()
          .copyWith(border: Border.all(color: AppColors.primaryColor)),
    );
  }

  BoxDecoration buildBoxDecoration() {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(15.0),
      border: Border.all(
        color: AppColors.lightGrey,
      ),
    );
  }
}
