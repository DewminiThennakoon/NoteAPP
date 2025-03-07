import 'package:flutter/material.dart';
import '../database/db_helper.dart';

class FirstScreen extends StatefulWidget {
  @override
  State<FirstScreen> createState() => _FirstScreenState();
}

class _FirstScreenState extends State<FirstScreen> {
  List<Map<String, dynamic>> _allData = [];

  bool _isLoading = true;
//GET DATA FROM DATABASE
  void _refreshData() async{
    final data = await SQLHelper.getAllData();
    setState(() {
      _allData = data;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  final TextEditingController _taskController   = TextEditingController();
  final TextEditingController _detailController = TextEditingController();


  //ADD DATA
  Future<void> _addData() async {
    await SQLHelper.createData(_taskController.text, _detailController.text);
    _refreshData();
  }
  //UPDATE DATA
  Future<void> _updateData(int id) async{
    await SQLHelper.updateData(id, _taskController.text, _detailController.text);
    _refreshData();
}
//DELETE DATA
  void _deleteData(int id) async{
    await SQLHelper.deleteData(id);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      backgroundColor: Colors.redAccent,
        content: Text("Data Deleted"),));
    _refreshData();
}
  void showBottomSheet(int? id) async{
    //if id is not null, it will update other wise it will add as new data
    if(id!=null) {
      final existingData = _allData.firstWhere((element) => element['id']==id);
      _taskController.text = existingData['task'];
      _detailController.text = existingData['detail'];

    }
    showModalBottomSheet(
      elevation: 5,
      isScrollControlled:true,
      context:context,
      builder: (_) => Container(
        padding: EdgeInsets.only(
          top: 30,
          left:15,
          right: 15,
          bottom: MediaQuery.of(context).viewInsets.bottom + 50,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            TextField(
              controller: _taskController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Task",
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _detailController,
              maxLines: 3,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Description",
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                  onPressed: () async{
                    if (id == null) {
                    await _addData();
                    }
                    if (id !=null) {
                    await _updateData(id);
                    }
                    _taskController.text = "";
                    _detailController.text = "";

                    Navigator.of(context).pop();
                    print("Data Added");
                  },
                  child: Padding(
                    padding: EdgeInsets.all(18),
                    child: Text(id == null? "Add Data" : "Update",
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
                   ),
                 ),
                ),
              ),
            ],
          ),
        ),
      );
    }
  
  @override
  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: Color(0xFF3B19C2),
      appBar: AppBar(
        title: Text("MY SIMPLE NOTES"),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
            :ListView.builder(
             itemCount: _allData.length,
                itemBuilder: (context, index) => Card(
                  margin: EdgeInsets.all(15),
                  child: ListTile(
                    title: Padding(
                      padding: EdgeInsets.symmetric(vertical: 5),
                        child: Text(
                          _allData[index]['title'],
                          style:TextStyle(
                            fontSize: 20,
                          ),
                        ),
                      ),
                    subtitle:Text(_allData[index]['detail']),
                    trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                            onPressed: () {
                              showBottomSheet(_allData[index]['id']);
                            },
                            icon:Icon(
                              Icons.edit,
                              color: Colors.blue,
                            ),
                        ),
                        IconButton(
                            onPressed: () {
                              _deleteData(_allData[index]['id']);
                            },
                            icon:Icon(
                              Icons.delete,
                              color: Colors.red,
                            ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
        floatingActionButton: FloatingActionButton(
          onPressed:() => showBottomSheet(null),
          child: Icon(Icons.add),
               )

              );
  }
}