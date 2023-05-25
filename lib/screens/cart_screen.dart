import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart.dart' show Cart;
import '../widgets/cart_items.dart';
import '../providers/orders.dart';

class CartScreen extends StatelessWidget {
  static const routeName = '\cartScreen';

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Your Cart'),
      ),
      body: Column(
        children: [
          Card(
            elevation: 3,
            margin: EdgeInsets.all(15),
            child: Padding(
              padding: EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total',
                    style: TextStyle(fontSize: 20),
                  ),
                  Spacer(),
                  Chip(
                    label: Text(
                      '\$${cart.totalPrice.toStringAsFixed(2)}',
                      style: TextStyle(
                          color: Theme.of(context)
                              .primaryTextTheme
                              .titleLarge
                              .color),
                    ),
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                  SizedBox(width: 20),
                  OrderButton(cart: cart)
                ],
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Expanded(
            child: ListView.builder(
                itemCount: cart.productCount,
                itemBuilder: (ctx, i) {
                  return CartItem(
                    id: cart.cartItems.values.toList()[i].id,
                    price: cart.cartItems.values.toList()[i].price,
                    quantity: cart.cartItems.values.toList()[i].quantity,
                    title: cart.cartItems.values.toList()[i].title,
                    productId: cart.cartItems.keys.toList()[i],
                  );
                }),
          ),
        ],
      ),
    );
  }
}

class OrderButton extends StatefulWidget {
  const OrderButton({
    Key key,
    @required this.cart,
  }) : super(key: key);

  final Cart cart;

  @override
  State<OrderButton> createState() => _OrderButtonState();
}

class _OrderButtonState extends State<OrderButton> {
  var _isLoading = false;
  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? CircularProgressIndicator(
            strokeWidth: 5,
          )
        : TextButton(
            onPressed: widget.cart.totalPrice <= 0
                ? null
                : () async {
                    setState(() {
                      _isLoading = true;
                    });
                    await Provider.of<Orders>(context, listen: false).addOrder(
                      widget.cart.cartItems.values.toList(),
                      widget.cart.totalPrice,
                    );
                    setState(() {
                      _isLoading = false;
                    });
                    widget.cart.clearCart();
                  },
            child: Text('ORDER NOW'),
          );
  }
}
