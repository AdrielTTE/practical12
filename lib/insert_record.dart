import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class InsertRecord extends StatefulWidget {
  const InsertRecord({super.key});

  @override
  State<InsertRecord> createState() => _InsertRecordState();


}

class _InsertRecordState extends State<InsertRecord> {

  User? _user;
  final firestore = FirebaseFirestore.instance;
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void initState(){
    super.initState();
    var user = FirebaseAuth.instance.currentUser;
    if(user !=null){
      _user = user;
    }
  }

  void _saveRecord() {
    try {
      firestore
          .collection("users")
          .doc(_user!.uid)
          .collection('contacts')
          .add({
        "name": _nameController.text,
        "phone": _phoneController.text,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Contact saved.')),
      );
    } catch (e) {
      print('Error : $e');
    }
  }



  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextField(
          controller: _nameController,
          keyboardType: TextInputType.name,
          decoration: const InputDecoration(
            labelText: 'Name',
          ),
        ),
        TextField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            labelText: 'Phone',
          ),
        ),
        TextButton(onPressed: _saveRecord, child: Text('Save')),

        Expanded(
          flex: 1,
          child: StreamBuilder(
            stream: firestore
                .collection('users')
                .doc(_user!.uid)
                .collection("contacts")
                .snapshots(),
            builder: (context, snapshots) {
              if (snapshots.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else if (snapshots.hasError) {
                return Text('Connection error');
              }
              if (!snapshots.hasData) {
                return Text('No contact');
              } else {
                return ListView.builder(
                  itemCount: snapshots.data!.docs.length,
                  itemBuilder: (context, index) {
                    var contact = snapshots.data!.docs[index];
                    return Card(
                      child: ListTile(
                        title: Text('Name : ${contact["name"]}'),
                        subtitle: Text('Phone : ${contact["phone"]}'),
                      ),
                    );
                  },
                );
              }
            },
          ),
        ),

      ],
    );
  }
}
