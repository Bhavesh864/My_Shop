import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../helpers/custom_route.dart';
import '../screens/order_screen.dart';
import '../screens/user_products_screen.dart';
import '../screens/products_overview_screen.dart';
import '../providers/auth.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          AppBar(
            title: Text('My Shop'),
            automaticallyImplyLeading: false,
          ),
          SizedBox(height: 20),
          ListTile(
            leading: Icon(
              Icons.shop,
              size: 32,
            ),
            title: Text(
              'Shop',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            onTap: () {
              Navigator.pushReplacementNamed(context, ProductsOverviewScreen.routeName);
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(
              Icons.wallet,
              size: 32,
            ),
            title: Text(
              'Orders',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            onTap: () {
              // Navigator.pushReplacementNamed(context, OrderScreen.routeName);
              Navigator.of(context).pushReplacement(
                CustomRoute(
                  builder: (context) => OrderScreen(),
                ),
              );
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(
              Icons.edit,
              size: 32,
            ),
            title: Text(
              'Manage Products',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            onTap: () {
              Navigator.pushReplacementNamed(context, UserProductsScreen.routeName);
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(
              Icons.logout,
              size: 32,
            ),
            title: Text(
              'Logout',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            onTap: () {
              Navigator.of(context).pushReplacementNamed('/');
              Provider.of<Auth>(context, listen: false).logOut();
            },
          ),
        ],
      ),
    );
  }
}
