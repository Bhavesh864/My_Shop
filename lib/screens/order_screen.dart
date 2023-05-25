import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/app_drawer.dart';
import '../widgets/order_items.dart';
import '../providers/orders.dart' show Orders;

class OrderScreen extends StatefulWidget {
  static const routeName = '/order_screen';

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  Future _futureOrders;

  Future _obtainFutureOrder() {
    return Provider.of<Orders>(context, listen: false).fetchAndSetOrders();
  }

  @override
  void initState() {
    _futureOrders = _obtainFutureOrder();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Orders'),
      ),
      drawer: AppDrawer(),
      body: FutureBuilder(
        future: _futureOrders,
        builder: ((context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
                child: CircularProgressIndicator(
              color: Theme.of(context).secondaryHeaderColor,
            ));
          } else {
            if (snapshot.error != null) {
              return Center(
                child: Text('Error Occured'),
              );
            } else {
              return Consumer<Orders>(
                builder: ((context, orderData, child) =>
                    orderData.orders.length == 0
                        ? Center(
                            child: Text(
                              'No orders yet! Go and buy some.',
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.black54,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          )
                        : ListView.builder(
                            itemCount: orderData.orders.length,
                            itemBuilder: ((context, index) => OrderItem(
                                  orderData.orders[index],
                                )),
                          )),
              );
            }
          }
        }),
      ),
    );
  }
}
