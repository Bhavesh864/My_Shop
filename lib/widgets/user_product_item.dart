import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/products_provider.dart';
import '../screens/edit_product_screen.dart';

class UserProductItem extends StatelessWidget {
  final String title;
  final String id;
  final String imageUrl;

  UserProductItem(
    this.id,
    this.imageUrl,
    this.title,
  );

  @override
  Widget build(BuildContext context) {
    final scaffold = ScaffoldMessenger.of(context);
    return Card(
      elevation: 3,
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(imageUrl),
        ),
        title: Text(title),
        trailing: Container(
          width: 100,
          child: Row(
            children: [
              IconButton(
                onPressed: () {
                  Navigator.pushNamed(context, EditProductScreen.routeName,
                      arguments: id);
                },
                icon: Icon(
                  Icons.edit,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              IconButton(
                onPressed: () async {
                  try {
                    await Provider.of<Products>(context, listen: false)
                        .deleteItem(id);
                  } catch (error) {
                    scaffold.showSnackBar(
                      SnackBar(
                        action: SnackBarAction(
                            textColor: Colors.deepOrange,
                            label: 'Okay',
                            onPressed: () {
                              scaffold.removeCurrentSnackBar();
                            }),
                        content: Text(error.toString()),
                      ),
                    );
                  }
                },
                icon: Icon(
                  Icons.delete,
                  color: Theme.of(context).errorColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
