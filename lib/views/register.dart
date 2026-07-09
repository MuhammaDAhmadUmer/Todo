import 'package:api_practice/services/auth.dart';
import 'package:api_practice/views/login.dart';
import 'package:flutter/material.dart';
class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  TextEditingController namecontroller = TextEditingController();
  TextEditingController emailcontroller = TextEditingController();
  TextEditingController pwdcontroller = TextEditingController();
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Register"),
      ),
       body: Column(
         children: [
           TextField(controller: namecontroller,),
           TextField(controller:emailcontroller,),
           TextField(controller:pwdcontroller,),
           SizedBox(
             height: 30,),
           ElevatedButton(onPressed: ()async{
             if(namecontroller.text.isEmpty){
               ScaffoldMessenger.of(context)
                   .showSnackBar(SnackBar(content: Text("Plaese enter a name")));
               return;
             }
             if(emailcontroller.text.isEmpty){
               ScaffoldMessenger.of(context)
                   .showSnackBar(SnackBar(content: Text("Plaese enter a name")));
               return;
             }
             if(pwdcontroller.text.isEmpty){
               ScaffoldMessenger.of(context)
                   .showSnackBar(SnackBar(content: Text("Plaese enter a name")));
               return;
             }
             try{
               isLoading =true;
               setState(() {
               });
               await AuthServices().registerUSer(
                   name: namecontroller.text,
                   email: emailcontroller.text,
                   password: pwdcontroller.text)
               .then((value){
                 showDialog(context: context, builder:(context){
                   return AlertDialog(
                     title: Text('Message'),
                     content: Text("User has been registered successfully"),
                     actions: [
                       TextButton(onPressed: (){
                         Navigator.push(context,MaterialPageRoute(builder: (context)=>LoginView()),);
                       }, child: Text("Okay"))
                     ],
                   );
                 });
               });
             } catch(e){
               ScaffoldMessenger.of(context).showSnackBar
                 (SnackBar(content: Text(e.toString())));
             }
           }, child:Text("Register")),
         ],
       ),
    );
  }
}
