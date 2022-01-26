import 'package:flutter/material.dart';

class InputUtils {
  InputUtils._();

  /// validate a form with it `key`, `next` is called if the form is valid
  static void validateForm(GlobalKey<FormState> formKey, {VoidCallback next}) {
    final formState = formKey.currentState;
    if (formState.validate()) {
      formState.save();
      next.call();
    }
  }
}
