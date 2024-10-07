import 'package:flutter/material.dart';
import 'package:my_schedule/model/user_model.dart';
import 'package:my_schedule/shared/button.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({super.key});

  @override
  State<TestScreen> createState() => TestScreenState();
}

class TestScreenState extends State<TestScreen> {


  final userStream = Supabase.instance.client.from('tbl_users').stream(primaryKey: ['user_id']);
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();

  getUser() async {
    
    try{
      
      List<UserModel> allUsers = [];
      final selectAllquery = await 
      Supabase.instance.client
      .from('tbl_users')
      .select();

      for(var eachUser in selectAllquery) {

        var user = UserModel(
          firstName: eachUser['first_name'], 
          lastName: eachUser['last_name'], 
          email: eachUser['email'],
          section: eachUser['section'], 
          birthday: eachUser['birthday'], 
          userType: eachUser['user_type'], 
        );

        allUsers.add(user);
      }
      for(var user in allUsers) {
        print("USER ::: ${user.lastName}");
      }
      
    } catch (e) {
      print("ERROR ::: $e");
    }

  }

  createUser(firstName, lastName) async {
    await Supabase.instance.client
    .from('tbl_users')
    .insert({
      'first_name': firstName.toString(),
      'last_name' : lastName.toString(),
      'email' : "test@gmail.com"
    });

    print("submitted successfully");
  }

  updateUser(int userId, updatedFirstName, updatedLastName) async {
    await Supabase.instance.client
    .from('tbl_users')
    .upsert({
      'user_id' : userId,
      'first_name': updatedFirstName.toString(),
      'last_name' : updatedLastName.toString(),
      'email' : "test@gmail.com"
    });

    print("submitted successfully");
  }

  deleteUser(userId) async {
    await Supabase.instance.client
    .from('tbl_users')
    .delete()
    .eq('user_id', userId);
    print("deleted successfully");
  }

  @override
  Widget build(BuildContext context) {

    getUser(); 

    return Scaffold(
      appBar: AppBar(
        title: const Text("Users"),
      ),
      
      body: StreamBuilder<List<Map<String,dynamic>>>(
        stream: userStream,
        builder: (context, snapshot) {
          if(!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final users = snapshot.data!;
          
          // print("USERS ::: $users");

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];

              return ListTile(
                title: Text(user['first_name']),
                subtitle: Text(user['last_name']),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: (){
                        deleteUser(user['user_id']);
                      },
                      icon: const Icon(Icons.delete, color: Colors.red)
                    ),

                    IconButton(
                      onPressed: (){
                        firstNameController.text = user['first_name'];
                        lastNameController.text = user['first_name'];

                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return  AlertDialog(
                              title: const Text("Edit Users"),
                              content: SingleChildScrollView(
                                child: ListBody(
                                  children: [

                                    TextFormField(
                                      controller: firstNameController,
                                      decoration: const InputDecoration(
                                        
                                        hintText: "First Name",
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color: Colors.black)
                                        )
                                      ),
                                    ),
                                    
                                    const SizedBox(height: 20),

                                    TextFormField(
                                      controller: lastNameController,
                                      decoration: const InputDecoration(
                                        hintText: "Last Name",
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color: Colors.black)
                                        )
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    
                                    MyButton(
                                      onTap: ()async{
                              
                                        await updateUser(
                                          user['user_id'],
                                          firstNameController.text, 
                                          lastNameController.text
                                        );
                                        firstNameController.clear();
                                        lastNameController.clear();
                                        Navigator.pop(context);
                                      },
                                      buttonName: "Submit"
                                    )

                                  ],
                                ),
                              ),
                            );
                          }
                        ).then((context) {
                          firstNameController.clear();
                          lastNameController.clear();
                        });
                      },
                      icon: const Icon(Icons.edit, color: Colors.black)
                    ),


                  ],
                ),
              );
            }, 
          );

        }
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: (){
          
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return  AlertDialog(
                title: const Text("Add Users"),
                content: SingleChildScrollView(
                  child: ListBody(
                    children: [

                      TextField(
                        controller: firstNameController,
                        decoration: const InputDecoration(
                          
                          hintText: "First Name",
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black)
                          )
                        ),
                      ),
                      
                      const SizedBox(height: 20),

                      TextField(
                        controller: lastNameController,
                        decoration: const InputDecoration(
                          hintText: "Last Name",
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black)
                          )
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      MyButton(
                        onTap: (){
                          createUser(
                            firstNameController.text, 
                            lastNameController.text
                          );
                          Navigator.pop(context);
                          
                        },
                        buttonName: "Submit"
                      )

                    ],
                  ),
                ),
              );
            }
          );

        },
        child: const Icon(Icons.add),
      ),
      
    );
  }
}