import 'package:flutter/material.dart'; 

class GroupPage extends StatefulWidget { 
  const GroupPage({Key? key}) : super(key: key); 

  @override 
  State<GroupPage> createState() => _GroupPageState(); 
} 

class _GroupPageState extends State<GroupPage> { 
  int selectedTile = 0; 

  @override 
  Widget build(BuildContext context) { 
    return Scaffold( 
    backgroundColor: Color.fromARGB(255,150,180,254),
    body: Container( 
      child: Stack( 
        children: [ 
          bottomDetailsSheet(), 
        ], 
        ), 
      ), 
    ); 
  }


  Widget bottomDetailsSheet() {
    return DraggableScrollableSheet(
      initialChildSize: .63,
      minChildSize: .08,
      maxChildSize: .63,
      builder: (BuildContext context, ScrollController scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(50),
              topRight: Radius.circular(50),
            ),
          ),
          child: SingleChildScrollView( // Menggunakan SingleChildScrollView sebagai ganti ListView
            controller: scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 10), // Beri sedikit jarak di bagian atas
                Padding(
                  padding: EdgeInsets.fromLTRB(10, 4, 10, 30), // Atur padding dengan nilai berbeda untuk setiap sisi
                  child: Container(
                    width: 55, // Atur lebar kotak kecil
                    height: 6, // Atur tinggi kotak kecil
                    color: Colors.grey[200],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
} 
