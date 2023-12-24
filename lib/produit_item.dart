import 'package:atelier4/model/produit.dart';
import 'package:flutter/material.dart';

class ProduitItem extends StatelessWidget {
  final Produit produit;

  const ProduitItem({Key? key, required this.produit}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16.0),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16.0),
        leading: CircleAvatar(
          backgroundImage: NetworkImage(produit.photo!),
          radius: 30,
        ),
        title: Text(
          produit.designation,
          style: Theme.of(context).textTheme.headline6,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8.0),
            Text(
              'Marque: ${produit.marque}',
              style: Theme.of(context).textTheme.subtitle1,
            ),
            const SizedBox(height: 4.0),
            Text(
              'Categorie: ${produit.categorie}',
              style: Theme.of(context).textTheme.subtitle1,
            ),
            const SizedBox(height: 4.0),
            Text(
              'Prix: ${produit.prix} DH',
              style: Theme.of(context).textTheme.subtitle1,
            ),
          ],
        ),
      ),
    );
  }
}
