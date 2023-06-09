import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:fitnessapp/components/loader_widget.dart';
import 'package:fitnessapp/main.dart';
import 'package:fitnessapp/network/RestApis.dart';
import 'package:fitnessapp/utils/Constants.dart';
import 'package:fitnessapp/utils/resources/Colors.dart';

class ChangePasswordScreen extends StatefulWidget {
  static String tag = '/ChangePasswordScreen';

  @override
  ChangePasswordScreenState createState() => ChangePasswordScreenState();
}

class ChangePasswordScreenState extends State<ChangePasswordScreen> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  TextEditingController oldPassCont = TextEditingController();
  TextEditingController newPassCont = TextEditingController();
  TextEditingController confNewPassCont = TextEditingController();

  FocusNode newPassFocus = FocusNode();
  FocusNode confPassFocus = FocusNode();

  bool oldPasswordVisible = false;
  bool newPasswordVisible = false;
  bool confPasswordVisible = false;

  bool mIsLoading = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    //
  }

  submit() async {
    hideKeyboard(context);

    if (formKey.currentState!.validate()) {
      Map req = {
        'old_password': oldPassCont.text,
        'new_password': newPassCont.text,
      };

      mIsLoading = true;
      setState(() {});

      await changePassword(req).then((value) {
        mIsLoading = false;
        setState(() {});

        toast(value.message.validate());

        finish(context);
      }).catchError((e) {
        mIsLoading = false;
        setState(() {});

        toast(e.toString());
      });
    }
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(
        language!.changePassword,
        elevation: 0,
        color: Theme.of(context).cardColor,
        textColor: Colors.white,
        textSize: 22,
      ),
      body: Container(
        padding: EdgeInsets.all(16),
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Form(
                key: formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  children: [
                    TextFormField(
                      controller: oldPassCont,
                      decoration: InputDecoration(
                        labelText: language!.password,
                        labelStyle: primaryTextStyle(color: Colors.white),
                        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: colorPrimary)),
                        errorBorder: OutlineInputBorder(borderSide: BorderSide(color: colorPrimary)),
                        border: OutlineInputBorder(borderSide: BorderSide(color: colorPrimary)),
                        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade500)),
                        suffixIcon: Icon(oldPasswordVisible ? Icons.visibility : Icons.visibility_off, color: colorPrimary).onTap(() {
                          oldPasswordVisible = !oldPasswordVisible;
                          setState(() {});
                        }),
                      ),
                      obscureText: oldPasswordVisible,
                      validator: (value) {
                        if (value!.isEmpty) return language!.pleaseEnterPassword;
                        if (value.length < passwordLength) return language!.passwordLengthShouldBeMoreThan6;
                        return null;
                      },
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (s) {
                        FocusScope.of(context).requestFocus(newPassFocus);
                      },
                    ),
                    16.height,
                    TextFormField(
                      controller: newPassCont,
                      decoration: InputDecoration(
                        labelText: language!.newPassword,
                        labelStyle: primaryTextStyle(color: Colors.white),
                        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: colorPrimary)),
                        errorBorder: OutlineInputBorder(borderSide: BorderSide(color: colorPrimary)),
                        border: OutlineInputBorder(borderSide: BorderSide(color: colorPrimary)),
                        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade500)),
                        suffixIcon: Icon(newPasswordVisible ? Icons.visibility : Icons.visibility_off, color: colorPrimary).onTap(() {
                          newPasswordVisible = !newPasswordVisible;
                          setState(() {});
                        }),
                      ),
                      obscureText: newPasswordVisible,
                      validator: (value) {
                        if (value!.isEmpty) return language!.pleaseEnterNewPassword;
                        if (value.length < passwordLength) return language!.passwordLengthShouldBeMoreThan6;
                        return null;
                      },
                      textInputAction: TextInputAction.next,
                      focusNode: newPassFocus,
                      onFieldSubmitted: (s) {
                        FocusScope.of(context).requestFocus(confPassFocus);
                      },
                    ),
                    16.height,
                    TextFormField(
                      controller: confNewPassCont,
                      decoration: InputDecoration(
                        labelText: language!.confirmPassword,
                        labelStyle: primaryTextStyle(color: Colors.white),
                        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: colorPrimary)),
                        errorBorder: OutlineInputBorder(borderSide: BorderSide(color: colorPrimary)),
                        border: OutlineInputBorder(borderSide: BorderSide(color: colorPrimary)),
                        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade500)),
                        suffixIcon: Icon(confPasswordVisible ? Icons.visibility : Icons.visibility_off, color: colorPrimary).onTap(() {
                          confPasswordVisible = !confPasswordVisible;
                          setState(() {});
                        }),
                      ),
                      obscureText: confPasswordVisible,
                      validator: (value) {
                        if (value!.isEmpty) return language!.pleaseEnterConfirmPassword;
                        if (value.length < passwordLength) return language!.passwordLengthShouldBeMoreThan6;
                        if (value.trim() != newPassCont.text.trim()) return language!.bothPasswordShouldBeMatched;
                        return null;
                      },
                      textInputAction: TextInputAction.done,
                      focusNode: confPassFocus,
                      onFieldSubmitted: (s) {
                        submit();
                      },
                    ),
                    20.height,
                    AppButton(
                      text: language!.submit,
                      width: context.width(),
                      color: colorPrimary,
                      onTap: () {
                        submit();
                      },
                    )
                  ],
                ),
              ),
            ),
            LoaderWidget().visible(mIsLoading),
          ],
        ),
      ),
    );
  }
}
