import 'package:api_practice/Provider/user.dart';
import 'package:api_practice/models/user.dart';
import 'package:api_practice/services/auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  TextEditingController emailcontroller = TextEditingController();
  TextEditingController pwdcontroller = TextEditingController();
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    var userProvider = Provider.of<UserProvider>(context);
    return Scaffold (
      appBar: AppBar(
        title: Text("Login Screen"),
      ),
      body: Column(
        children: [
          TextField(controller:emailcontroller),
          TextField(controller: pwdcontroller,),
          SizedBox(height:30,),
          isLoading ? Center(child:CircularProgressIndicator(),)
          :ElevatedButton(onPressed: ()async{
            if(emailcontroller.text.isEmpty){
              ScaffoldMessenger.of(context).
              showSnackBar(SnackBar(content:Text('Please Enter a Email') ));
              return;
            }
            if(emailcontroller.text.isEmpty){
              ScaffoldMessenger.of(context).
              showSnackBar(SnackBar(content:Text('Please Enter Password'),));
              return;
            }
           try{
              isLoading =true;
              setState(() {
              });
              await AuthServices().loginUser(email: emailcontroller.text,
                  password: pwdcontroller.text).
              then((value)async{
                UserModel model = await AuthServices().getProfile(value.token.toString());
          userProvider.setUser(model);
                showDialog(context: context, builder: (context){
                  return AlertDialog(
                    title: Text("Message"),
                    content: Text("${model.user!.toString()} has been logged In Successfully"),
                    actions: [
                      TextButton(onPressed: (){}, child: Text("Okay"))
                    ],
                  );
                });
              });
           }
            catch(e){
              isLoading=false;
              setState(() {
              });
              ScaffoldMessenger.of(context).
              showSnackBar(SnackBar(content: Text(e.toString())));
            }
          }, child: Text("Login")),

        ],
      ),
    );
  }
}
