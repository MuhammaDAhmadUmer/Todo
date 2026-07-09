import 'dart:convert';

import 'package:api_practice/models/Task_Listing.dart';
import 'package:api_practice/models/task.dart';
import 'package:http/http.dart 'as http;
 class TaskServices {
   Future<TaskModel> createTask({
     required String token,
     required String description,
   }) async {
     try {
       http.Response response = await http.post(
         Uri.parse("{{TODO_URL}}/todos/add"),
         headers: {
           'Authorization': token,
           'Content-Type': 'application/json'
         },
         body: jsonEncode({"description": description}),
       );
       if (response.statusCode == 200 || response.statusCode == 201) {
         return TaskModel.fromJson(jsonDecode(response.body));
       }
       else {
         throw response.reasonPhrase.toString();
       }
     } catch (e) {
       rethrow;
     }
   }
Future<TaskLIstingModel>getAllTasks(String token )async{
     try{
       http.Response response = await http.get(
       Uri.parse("{{TODO_URL}}/todos/get"),
         headers: {'Authorization':token},
       );
       if (response.statusCode ==200 || response.statusCode==201){
         return TaskLIstingModel.fromJson(jsonDecode(response.body));
       }
       else{
       throw response.reasonPhrase.toString();
  }
     }catch(e){
       rethrow;
     }
}
   Future<TaskLIstingModel>getCompletedTasks(String token )async{
     try{
       http.Response response = await http.get(
         Uri.parse("{{TODO_URL}}/todos/completed"),
         headers: {'Authorization':token},
       );
       if (response.statusCode ==200 || response.statusCode==201){
         return TaskLIstingModel.fromJson(jsonDecode(response.body));
       }
       else{
         throw response.reasonPhrase.toString();
       }
     }catch(e){
       rethrow;
     }
   }
   Future<TaskLIstingModel>getInCompletedTasks(String token )async{
     try{
       http.Response response = await http.get(
         Uri.parse("{{TODO_URL}}/todos/incomplete"),
         headers: {'Authorization':token},
       );
       if (response.statusCode ==200 || response.statusCode==201){
         return TaskLIstingModel.fromJson(jsonDecode(response.body));
       }
       else{
         throw response.reasonPhrase.toString();
       }
     }catch(e){
       rethrow;
     }
   }

}
