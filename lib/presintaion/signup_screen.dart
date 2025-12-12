import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ticket_at/my_widget/my_colors.dart';
import '../my_widget/my_routes.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;

  Future<void> signUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final AuthResponse res = await Supabase.instance.client.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        data: {'username': _userNameController.text.trim()},
      );

      if (mounted) {
        if (res.session == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Please check your email to confirm signup')),
          );
          Navigator.pushReplacementNamed(context, AppRoutes.login);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Sign Up Successful!')),
          );

          Navigator.pushReplacementNamed(context, AppRoutes.login);
        }
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
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
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
                  const SizedBox(height: 20),
                  Center(
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: MyColors.aquaLight,
                      child: Center(
                          child: SvgPicture.asset("assets/Logo.svg")),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                      child: Text("Welcome",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 30,
                              color: MyColors.black))),
                  Center(
                      child: Text("Enter your account here",
                          style: TextStyle(
                              fontSize: 15, color: MyColors.grayText))),
                  const SizedBox(height: 30),
                  const Text("User Name"),
                  _myTextFormfield(_userNameController, "User Name", false,
                      const Icon(Icons.person)),
                  const SizedBox(height: 10),
                  const Text("Email Address"),
                  _myTextFormfield(_emailController, "Email Address", false,
                      const Icon(Icons.email)),
                  const SizedBox(height: 10),
                  const Text("Password"),
                  _myTextFormfield(_passwordController, "Password", true,
                      const Icon(Icons.lock)),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: MyColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: _isLoading ? null : signUp,
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text("Sign Up",
                          style: TextStyle(color: MyColors.white)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Row(children: [
                    Expanded(child: Divider(endIndent: 10)),
                    Text("Or Sign Up With"),
                    Expanded(child: Divider(indent: 10))
                  ]),
                  const SizedBox(height: 50),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    CircleAvatar(
                        radius: 25,
                        backgroundColor: MyColors.white,
                        child: SvgPicture.asset("assets/google_icon.svg",
                            fit: BoxFit.fill)),
                    const SizedBox(width: 20),
                    CircleAvatar(
                        radius: 25,
                        child: SvgPicture.asset("assets/Facebook_icon.svg",
                            fit: BoxFit.fill)),
                  ]),
                  const SizedBox(height: 50),
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Already have an account? ",
                            style: TextStyle(color: MyColors.grayText)),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushReplacementNamed(
                                context, AppRoutes.login);
                          },
                          child: Text("Sign In",
                              style: TextStyle(
                                  color: MyColors.primary,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  _myTextFormfield(TextEditingController controller, String label,
      bool obscureText, Icon icon) {
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
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(30)),
        disabledBorder: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(30)),
      ),
    );
  }
}