import 'package:flutter/material.dart';
import 'package:haryanaassociationofkenya/screens/register.dart';


import 'login.dart';

class LoginRegister extends StatefulWidget {
  const LoginRegister({Key? key}) : super(key: key);

  @override
  State<LoginRegister> createState() => _LoginRegisterState();
}

class _LoginRegisterState extends State<LoginRegister> {
  bool signIn=true;
  void switchPages(){
    setState(() {
      signIn=!signIn;
    });
  }
  @override
  Widget build(BuildContext context) {
    if(signIn){
      return loginPage(onTap: switchPages);
    }else{
      return RegisterPage(onTap: switchPages,);
    }
  }
}
