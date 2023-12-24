
import 'package:atelier4/login_ecran.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

import 'dart:io';
import 'package:path/path.dart' as path;


class AddProduit extends StatefulWidget {
  const AddProduit({Key? key}) : super(key: key);

  @override
  _AddProduitState createState() => _AddProduitState();
}

class _AddProduitState extends State<AddProduit> {
  final CollectionReference _produits = FirebaseFirestore.instance.collection(
      'produits');

  FirebaseFirestore db = FirebaseFirestore.instance;
  final TextEditingController _marqueController = TextEditingController();
  final TextEditingController _designationController = TextEditingController();
  final TextEditingController _categorieController = TextEditingController();
  final TextEditingController _prixController = TextEditingController();
  final TextEditingController _quantiteController = TextEditingController();
  final TextEditingController _photoUrlController = TextEditingController();
  String imageUrl = '';
  File? _selectedImage;
  bool img = false;
  late User _user;
  String? userRole;


  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser!;
    _fetchUserRole();
  }

  Future<String?> getUserRole() async {
    final DocumentSnapshot userRoleSnapshot =
    await FirebaseFirestore.instance.collection('roles').doc(_user.uid).get();
    return userRoleSnapshot.exists ? userRoleSnapshot['role'] : null;
  }
  Future<void> _fetchUserRole() async {
    final role = await getUserRole();
    setState(() {
      userRole = role;
    });
  }


  Future<void> _update([DocumentSnapshot? documentSnapshot]) async {
    if (documentSnapshot != null) {
      _marqueController.text = documentSnapshot['marque'];
      _categorieController.text = documentSnapshot['categorie'];
      _designationController.text = documentSnapshot['designation'];
      _photoUrlController.text = documentSnapshot['photoUrl'];
      _quantiteController.text = documentSnapshot['quantite'].toString();
      _prixController.text = documentSnapshot['prix'].toString();
    }
    await showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext ctx) {
          return Padding(
            padding: EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                bottom: MediaQuery
                    .of(ctx)
                    .viewInsets
                    .bottom + 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _marqueController,
                  decoration: const InputDecoration(labelText: 'marque'),
                ),
                TextField(
                  controller: _categorieController,
                  decoration: const InputDecoration(labelText: 'categorie'),
                ),
                TextField(
                  controller: _designationController,
                  decoration: const InputDecoration(labelText: 'designation'),
                ),
                TextField(
                  keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
                  controller: _prixController,
                  decoration: const InputDecoration(
                    labelText: 'prix',
                  ),
                ),
                TextField(
                  keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
                  controller: _quantiteController,
                  decoration: const InputDecoration(
                    labelText: 'quantite',
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                  child: const Text('Update'),
                  onPressed: () async {
                    final String marque = _marqueController.text;
                    final String categorie = _categorieController.text;
                    final String designation = _designationController.text;
                    final double? prix = double.tryParse(_prixController.text);
                    final int? quantite = int.tryParse(
                        _quantiteController.text);
                    if (prix != null && quantite != 0) {
                      await _produits
                          .doc(documentSnapshot!.id)
                          .update({
                        "marque": marque,
                        "categorie": categorie,
                        "designation": designation,
                        "quantite": quantite,
                        "prix": prix
                      });
                      _marqueController.text = '';
                      _prixController.text = '';
                      _categorieController.text = '';
                      _quantiteController.text = '';
                      _designationController.text = '';
                      Navigator.of(context).pop();
                    }
                  },
                )
              ],
            ),
          );
        });
  }


  Future<void> createProduit() async {
    await showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (BuildContext ctx) {
        return SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
              top: 20,
              left: 20,
              right: 20,
              bottom: MediaQuery
                  .of(ctx)
                  .viewInsets
                  .bottom + 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _marqueController,
                  decoration: const InputDecoration(labelText: 'marque'),
                ),
                TextField(
                  controller: _categorieController,
                  decoration: const InputDecoration(labelText: 'categorie'),
                ),
                TextField(
                  controller: _designationController,
                  decoration: const InputDecoration(labelText: 'designation'),
                ),
                TextField(
                  keyboardType: const TextInputType.numberWithOptions(
                      decimal: true),
                  controller: _prixController,
                  decoration: const InputDecoration(
                    labelText: 'prix',
                  ),
                ),
                TextField(
                  keyboardType: const TextInputType.numberWithOptions(
                      decimal: true),
                  controller: _quantiteController,
                  decoration: const InputDecoration(
                    labelText: 'quantite',
                  ),
                ),
                Container(
                  height: 50,
                  width: 50,
                  child: _selectedImage != null
                      ? Image.file(
                    _selectedImage!,
                    fit: BoxFit.cover,
                  )
                      : Container(),
                ),
                IconButton(
                  onPressed: ajouteImage,
                  icon: Icon(Icons.camera_alt),
                ),
                const SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                  child: const Text('Create'),
                  onPressed: () async {
                    if (imageUrl != null) {
                      final storageRef = FirebaseStorage.instance.ref();
                      File imageFile = File(imageUrl!);
                      String imageName = path.basename(imageFile.path);
                      Reference storageReference =
                      storageRef.child('images/$imageName');

                      try {
                        UploadTask uploadTask =
                        storageReference.putFile(imageFile);
                        await uploadTask.whenComplete(() async {
                          String downloadUrl =
                          await storageReference.getDownloadURL();
                          print("Download URL: $downloadUrl");

                          double prix =
                              double.tryParse(_prixController.text) ?? 0.0;
                          int quantite =
                              int.tryParse(_quantiteController.text) ?? 0;
                          print('Categorie: ${_categorieController.text}');
                          print('Designation: ${_designationController.text}');
                          print('Marque: ${_marqueController.text}');
                          print('Prix: $prix');
                          print('Quantite: $quantite');

                          await db.collection('produits').add({
                            'categorie': _categorieController.text,
                            'designation': _designationController.text,
                            'marque': _marqueController.text,
                            'photoUrl': downloadUrl,
                            'prix': prix,
                            'quantite': quantite,
                          });

                          _marqueController.clear();
                          _prixController.clear();
                          _categorieController.clear();
                          _quantiteController.clear();
                          _designationController.clear();
                          _selectedImage = null;

                          Navigator.of(context).pop();

                      
                        });
                      } catch (e) {
                        print("Error uploading image to Firebase Storage: $e");
                      
                      }
                    } else {
                  
                    }
                  },
                )
              ],
            ),
          ),
        );
      },
    );
  }


  Future<void> ajouteImage() async {
    final ImagePicker imagePicker = ImagePicker();
    final XFile? image =
    await imagePicker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final imageExtension = path.extension(image.path).toLowerCase();

      if (imageExtension == '.png' ||
          imageExtension == '.jpeg' ||
          imageExtension == '.jpg') {
        setState(() {
          imageUrl = image.path;
          img = true;
        });
      } else {
        print(
            "Échec de la mise à jour de l'image, essayez avec une autre image");
      }
    } else {
      print("Le fichier n'est pas une image");

    }
  }

  Future<void> _delete(String productId) async {
    await _produits.doc(productId).delete();
  
  }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Liste des produits - ${_user.email}'),
//         actions: [
//           ElevatedButton(
//             onPressed: () async {
//               await FirebaseAuth.instance.signOut();
//               Navigator.of(context).pushReplacement(MaterialPageRoute(
//                 builder: (context) => LoginEcran(),
//               ));
//             },
//             child: const Text('Logout'),
//           ),
//         ],
//       ),
//       body: StreamBuilder(
//         stream: _produits.snapshots(),
//         builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
//           if (streamSnapshot.connectionState == ConnectionState.waiting) {
//             return const Center(
//               child: CircularProgressIndicator(),
//             );
//           } else if (streamSnapshot.hasError) {
//             return Center(
//               child: Text('Error: ${streamSnapshot.error}'),
//             );
//           } else if (!streamSnapshot.hasData ||
//               streamSnapshot.data!.docs.isEmpty) {
//             return const Text('No data available');
//           } else {
//             return ListView.builder(
//               itemCount: streamSnapshot.data!.docs.length,
//               itemBuilder: (context, index) {
//                 final DocumentSnapshot documentSnapshot =
//                 streamSnapshot.data!.docs[index];
//                 return Card(
//                   margin: const EdgeInsets.all(10),
//                   elevation: 2,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(15),
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       ClipRRect(
//                         borderRadius: BorderRadius.vertical(
//                             top: Radius.circular(15)),
//                         child: AspectRatio(
//                           aspectRatio: 18 / 10,
//                           child: documentSnapshot['photoUrl'] != null
//                               ? Image.network(
//                             documentSnapshot['photoUrl'],
//                             fit: BoxFit.cover,
//                           )
//                               : Container(
//                             color: Colors.grey,
//                             child: const Center(
//                               child: Icon(
//                                 Icons.image,
//                                 color: Colors.white,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                       Padding(
//                         padding: const EdgeInsets.all(16),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               documentSnapshot['marque'],
//                               style: const TextStyle(
//                                 fontSize: 34,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                             SizedBox(height: 8),
//
//                             Text(
//                               'Designation: ${documentSnapshot['designation'] ?? 'N/A'}',
//                               style: TextStyle(fontSize: 16),
//                             ),
//                             Text(
//                               'Categorie: ${documentSnapshot['categorie'] ?? 'N/A'}',
//                               style: TextStyle(fontSize: 16),
//                             ),
//                             Text(
//                               'Stock: ${documentSnapshot['quantite'] ?? 'N/A'}',
//                               style: TextStyle(fontSize: 16),
//                             ),
//                           ],
//                         ),
//                       ),
//                       Padding(
//                         padding: const EdgeInsets.all(8),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Row(
//                               mainAxisSize: MainAxisSize.min,
//                               children: [
//                                 ElevatedButton.icon(
//                                   onPressed: () =>
//                                       _update(documentSnapshot),
//                                   icon: Icon(Icons.edit),
//                                   label: Text('Edit'),
//                                   style: ElevatedButton.styleFrom(
//                                     foregroundColor: Colors.white, backgroundColor: Colors.blue,
//                                   ),
//                                 ),
//                                 SizedBox(width: 8),
//                                 ElevatedButton.icon(
//                                   onPressed: () =>
//                                       _delete(documentSnapshot.id),
//                                   icon: Icon(Icons.delete),
//                                   label: Text('Delete'),
//                                   style: ElevatedButton.styleFrom(
//                                     foregroundColor: Colors.white, backgroundColor: Colors.pink,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             Text(
//                               'Prix: ${documentSnapshot['prix'] ?? 'N/A'}',
//                               style: TextStyle(fontSize: 16),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 );
//               },
//             );
//           }
//         },
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () => createProduit(),
//         child: const Icon(Icons.add),
//       ),
//       floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
//     );
//   }
// }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Liste des produits - ${_user.email}'),
        actions: [
          ElevatedButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (context) => login_ecran(),
              ));
            },
            child: const Text('Logout'),
          ),
        ],
      ),
      body: StreamBuilder(
        stream: _produits.snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
          if (streamSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (streamSnapshot.hasError) {
            return Center(
              child: Text('Error: ${streamSnapshot.error}'),
            );
          } else if (!streamSnapshot.hasData ||
              streamSnapshot.data!.docs.isEmpty) {
            return const Text('No data available');
          } else {
            return ListView.builder(

              itemCount: streamSnapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final DocumentSnapshot documentSnapshot =
                streamSnapshot.data!.docs[index];
                return Card(
                  margin: const EdgeInsets.all(10),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.vertical(
                            top: Radius.circular(15)),
                        child: AspectRatio(
                          aspectRatio: 18 / 10,
                          child: documentSnapshot['photoUrl'] != null
                              ? Image.network(
                            documentSnapshot['photoUrl'],
                            fit: BoxFit.cover,
                          )
                              : Container(
                            color: Colors.grey,
                            child: const Center(
                              child: Icon(
                                Icons.image,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              documentSnapshot['marque'],
                              style: const TextStyle(
                                fontSize: 34,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),

                            Text(
                              'Designation: ${documentSnapshot['designation'] ?? 'N/A'}',
                              style: TextStyle(fontSize: 16),
                            ),
                            Text(
                              'Categorie: ${documentSnapshot['categorie'] ?? 'N/A'}',
                              style: TextStyle(fontSize: 16),
                            ),
                            Text(
                              'Stock: ${documentSnapshot['quantite'] ?? 'N/A'}',
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [

                            if (userRole == 'admin') ...[
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ElevatedButton.icon(
                                    onPressed: () => _update(documentSnapshot),
                                    icon: Icon(Icons.edit),
                                    label: Text('Edit'),
                                    style: ElevatedButton.styleFrom(
                                      foregroundColor: Colors.white,
                                      backgroundColor: Colors.blue,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  ElevatedButton.icon(
                                    onPressed: () => _delete(documentSnapshot.id),
                                    icon: Icon(Icons.delete),
                                    label: Text('Delete'),
                                    style: ElevatedButton.styleFrom(
                                      foregroundColor: Colors.white,
                                      backgroundColor: Colors.pink,
                                    ),
                                  ),
                                ],
                              ),
                            ] else ...[
                              // Show the "Add to Favorite" button for users without admin role
                              ElevatedButton.icon(
                                onPressed: () {
                                  // Handle favorite button press
                                  // You can add your logic here
                                },
                                icon: Icon(Icons.favorite),
                                label: Text('Add to Favorite'),
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: Colors.red,
                                ),
                              ),
                            ],
                            Text(
                              'Prix: ${documentSnapshot['prix'] ?? 'N/A'}',
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FutureBuilder<String?>(
        future: getUserRole(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Return a loading indicator if the role is still being fetched
            return CircularProgressIndicator();
          } else if (snapshot.hasError || snapshot.data == null) {
            // Handle errors or if the user has no role
            return Container();
          } else {
            // User role is available
            String userRole = snapshot.data!;
            return userRole == 'admin'
                ? FloatingActionButton(
              onPressed: () => createProduit(),
              child: const Icon(Icons.add),
            )
                : Container();
          }
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}