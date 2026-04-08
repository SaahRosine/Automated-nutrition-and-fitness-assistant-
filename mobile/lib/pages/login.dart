import 'package:mobile/pages/sign_up.dart';
import 'package:mobile/pages/menu.dart';
import 'package:mobile/widgets/big_button.dart';
import 'package:mobile/widgets/text_form.dart';
import 'package:flutter/material.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.blueGrey,
        title: Text(
          "Fitness & Nutrition Assistant",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            height: 50
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(15.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center, // vertically centered
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Connection",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 27,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 15),

                // Email input
                TextFormGlobal(
                  controller: emailController,
                  text: 'Email',
                  obscure: false,
                  textInputType: TextInputType.emailAddress,
                ),

                const SizedBox(height: 10),

                // Password input
                TextFormGlobal(
                  controller: passwordController,
                  text: 'Password',
                  textInputType: TextInputType.text,
                  obscure: true,
                ),

                const SizedBox(height: 10),

                Column(
                  children: [
                    BigButton(
                      text: 'Login',
                      color: Colors.lightBlueAccent,
                      isLoading: _isLoading,
                      onTap: (){}
                    ),

                    const SizedBox(height: 10),
                    const Center(
                      child: Text(
                        "Or",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),

                    const SizedBox(height: 20),
                    BigButton(
                      text: "Connect anonymously",
                      color: Colors.black,
                      isLoading: _isLoading,
                      onTap: (){
                        Navigator.push(
                          context, 
                          MaterialPageRoute(
                            builder:(context)=>Menu()
                            ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        height: 50,
        color: Colors.blueGrey,
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Don't have an account ?",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            InkWell(
              onTap: (){
                Navigator.push(
                  context, 
                  MaterialPageRoute(
                    builder:(context)=>SignUpScreen()
                    ),
                );
              },
              child: Text(
                "Create one !",
                style: TextStyle(
                  color: const Color.fromARGB(255, 2, 236, 244),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
