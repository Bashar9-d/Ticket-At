import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ticket_at/my_widget/my_colors.dart';
import '../my_widget/my_routes.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;

  Future<void> signIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await Supabase.instance.client.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Login Successful!")));
        Navigator.pushReplacementNamed(context, AppRoutes.main);
      }
    } on AuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("An error occurred"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: SafeArea(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20),
                  Center(
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: MyColors.aquaLight,
                      child: Center(child: SvgPicture.asset("assets/Logo.svg")),
                    ),
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: Text(
                      "Welcome",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 30,
                        color: MyColors.black,
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      "Sign In your account",
                      style: TextStyle(fontSize: 15, color: MyColors.grayText),
                    ),
                  ),
                  SizedBox(height: 30),
                  Text("Email Address"),
                  _myTextFormfield(
                    _emailController,
                    "Email Address",
                    false,
                    Icon(Icons.email),
                  ),
                  SizedBox(height: 10),
                  Text("Password"),
                  _myTextFormfield(
                    _passwordController,
                    "Password",
                    true,
                    Icon(Icons.lock),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      child: Text("Forgot Password?"),
                    ),
                  ),
                  SizedBox(height: 10),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: MyColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: _isLoading ? null : signIn,
                      child: _isLoading
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text(
                              "Sign In",
                              style: TextStyle(color: MyColors.white),
                            ),
                    ),
                  ),

                  SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(child: Divider(endIndent: 10)),
                      Text("Or Sign In With"),
                      Expanded(child: Divider(indent: 10)),
                    ],
                  ),
                  SizedBox(height: 50),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 25,
                        backgroundColor: MyColors.white,
                        child: SvgPicture.asset(
                          "assets/google_icon.svg",
                          fit: BoxFit.fill,
                        ),
                      ),
                      SizedBox(width: 20),
                      CircleAvatar(
                        radius: 25,
                        child: SvgPicture.asset(
                          "assets/Facebook_icon.svg",
                          fit: BoxFit.fill,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 50),
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don’t have an account? ",
                          style: TextStyle(color: MyColors.grayText),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushReplacementNamed(
                              context,
                              AppRoutes.signup,
                            );
                          },
                          child: Text(
                            "Sign Up",
                            style: TextStyle(
                              color: MyColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  _myTextFormfield(
    TextEditingController controller,
    String label,
    bool obscureText,
    Icon icon,
  ) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $label';
        }
        return null;
      },
      decoration: InputDecoration(
        prefixIcon: icon,
        filled: true,
        fillColor: MyColors.grayField,
        labelText: label,
        labelStyle: TextStyle(color: MyColors.grayText),
        border: OutlineInputBorder(
          borderSide: BorderSide(style: BorderStyle.none),
          borderRadius: BorderRadius.circular(30),
        ),
        disabledBorder: OutlineInputBorder(
          borderSide: BorderSide(style: BorderStyle.none),
          borderRadius: BorderRadius.circular(30),
        ),
      ),
    );
  }
}
