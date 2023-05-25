// import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class CartItem {
  final String id;
  final String title;
  final double price;
  final int quantity;

  CartItem({
    @required this.id,
    @required this.price,
    @required this.quantity,
    @required this.title,
  });
}

class Cart with ChangeNotifier {
  Map<String, CartItem> _cartItems = {};
  List arr = [];

  Map<String, CartItem> get cartItems {
    return {..._cartItems};
  }

  int get productCount {
    return _cartItems.length;
  }

  double get totalPrice {
    var total = 0.0;
    _cartItems.forEach((key, item) {
      total += item.quantity * item.price;
    });
    return total;
  }

  void addItem(String productId, String title, double price) {
    // final url = Uri.parse(
    //     'https://flutter-update-1f17b-default-rtdb.firebaseio.com/products/$productId.json');
    if (_cartItems.containsKey(productId)) {
      _cartItems.update(
        productId,
        (existingCartItem) {
          // final response = http.patch(url,
          //     body: json.encode({
          //       'quantity': existingCartItem.quantity + 1,
          //     }));
          return CartItem(
              id: existingCartItem.id,
              price: existingCartItem.price,
              quantity: existingCartItem.quantity + 1,
              title: existingCartItem.title);
        },
      );
    } else {
      _cartItems.putIfAbsent(
          productId,
          () => CartItem(
                id: DateTime.now().toString(),
                price: price,
                quantity: 1,
                title: title,
              ));
    }
    notifyListeners();
  }

  void removeItem(String productId) {
    _cartItems.remove(productId);
    notifyListeners();
  }

  void clearCart() {
    _cartItems.clear();
    notifyListeners();
  }

  void removSingleProduct(String productId) {
    if (!_cartItems.containsKey(productId)) return;
    if (_cartItems[productId].quantity > 1) {
      _cartItems.update(
        productId,
        (existingCartItem) => CartItem(
            id: existingCartItem.id,
            price: existingCartItem.price,
            quantity: existingCartItem.quantity - 1,
            title: existingCartItem.title),
      );
    } else {
      _cartItems.remove(productId);
    }
    notifyListeners();
  }

  void decreaseItem(String productId) {
    _cartItems.update(
        productId,
        (existingCartItem) => CartItem(
            id: existingCartItem.id,
            price: existingCartItem.price,
            quantity: existingCartItem.quantity > 1
                ? existingCartItem.quantity - 1
                : existingCartItem.quantity,
            title: existingCartItem.title));
    notifyListeners();
  }
}
