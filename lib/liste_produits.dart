import 'package:atelier4/model/produit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'produit_item.dart';

class ListeProduits extends StatefulWidget {
  const ListeProduits({super.key});

  @override
  State<ListeProduits> createState() => _ListeProduitsState();
}

class _ListeProduitsState extends State<ListeProduits> {
  FirebaseFirestore db = FirebaseFirestore.instance;
  @override
  void initState() {
    super.initState();
  }

  Future<void> init() async {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Liste des produits'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: db.collection('produits').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text('Error fetching data!'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          List<Produit> produits = snapshot.data!.docs.map((e) {
            return Produit.fromFirestore(e);
          }).toList();

          return ListView.builder(
            itemCount: produits.length,
            itemBuilder: (context, index) => ProduitItem(
              produit: produits[index],
            ),
          );
        },
      ),
    );
  }
}