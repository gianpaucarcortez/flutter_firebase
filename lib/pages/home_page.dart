import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_codigo3_firebase_1/models/band_model.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<BandModel> myBands = [];
  CollectionReference bandCollection =
      FirebaseFirestore.instance.collection('bandas');

  TextEditingController _bandController = TextEditingController();
  TextEditingController _imageBandController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getAllDataFirebase();
  }

  getAllDataFirebase() {
    myBands.clear();
    bandCollection.orderBy('band', descending: true).get().then((value) {
      value.docs.forEach((element) {
        Map<String, dynamic> myMap = element.data() as Map<String, dynamic>;
        myMap["pk"] = element.id;
        myBands.add(BandModel.fromJson(myMap));

        setState(() {});
      });
    });
  }

  getDocumentFirebase() {
    bandCollection.doc("mVCbEnqjZ8rShpQIGlB4").get().then((value) {
      if (value.exists) {
        print("Band::::::${value.data()}");
      } else {
        print("La banda no existe");
      }
    });
  }

  addDocumentFirebase() {
    bandCollection.add({
      'id': myBands.length + 1,
      'band': _bandController.text,
      'image': _imageBandController.text,
      'status': true,
    }).then((value) {
      print("Banda agregada");
    }).catchError((error) {
      print("Hubo un error");
    });
  }

  addDocumentIdFirebase() {
    bandCollection.doc("MandarinaQW323").set({
      'id': 5,
      'band': 'Disturbed',
      'image':
          'https://www.todorock.com/wp-content/uploads/2019/09/disturbed-1200x900.jpeg',
      'status': true,
    }).then((value) {
      print("Banda agregada");
    }).catchError((error) {
      print("Hubo un error");
    });
  }

  updateDocumentFirebase() {
    bandCollection.doc("kqh8x0XMqjEbhCHsoi5g").update({
      'id': 6,
      'band': 'Belle and Sebastian',
      'image':
          'https://upload.wikimedia.org/wikipedia/commons/1/19/Belle_and_Sebastian_British_Band.jpeg',
      'status': true,
    }).then((value) {
      print("Banda actualizada");
    }).catchError((error) {
      print("Hubo un error");
    });
  }

  deleteDocumentFirebase(String pk) {
    bandCollection.doc(pk).delete().then((value) {
      print("Banda eliminada");
    }).catchError((error) {
      print("Hubo un error al eliminar");
    });
  }

  addShowDialog() {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text("Add band"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _bandController,
                decoration: InputDecoration(hintText: "Band"),
              ),
              SizedBox(
                height: 8.0,
              ),
              TextField(
                controller: _imageBandController,
                decoration: InputDecoration(hintText: "Image"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                addDocumentFirebase();
                _bandController.clear();
                _imageBandController.clear();
                Navigator.pop(context);
              },
              child: Text("Add"),
            ),
          ],
        );
      },
    );
  }

  deleteShowDialog({required String band, required String pk}) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Delete band"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [Text("Are you sure you want to delete...$band?")],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                "Cancel",
              ),
            ),
            TextButton(
              onPressed: () {
                deleteDocumentFirebase(pk);
                getAllDataFirebase();
                Navigator.pop(context);
                setState(() {});
              },
              child: Text(
                "Delete",
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          addShowDialog();
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.black87,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            getAllDataFirebase();
          },
          child: ListView.builder(
            itemCount: myBands.length,
            itemBuilder: (BuildContext context, int index) {
              return GestureDetector(
                onLongPress: () {
                  print(myBands[index].setlist);
                  deleteShowDialog(
                    band: myBands[index].band,
                    pk: myBands[index].pk,
                  );
                },
                child: Container(
                  height: 370,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: NetworkImage(
                        myBands[index].image,
                      ),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        myBands[index].band,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 40.0,
                          letterSpacing: 10,
                        ),
                      ),
                      Column(
                        children: myBands[index]
                            .setlist!
                            .map<Widget>(
                              (e) => Container(
                                margin: EdgeInsets.symmetric(vertical: 4.0),
                                child: Text(
                                  e.name,
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    letterSpacing: 1.5,
                                    color: Colors.white70,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      )
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
