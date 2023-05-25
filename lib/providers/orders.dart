import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import './cart.dart';

class OrderItem {
  final String id;
  final double amount;
  final DateTime dateTime;
  final List<CartItem> orderedProduct;

  OrderItem({this.amount, this.id, this.orderedProduct, this.dateTime});
}

class Orders with ChangeNotifier {
  final String token;
  final String userId;
  List<OrderItem> _orders = [];

  Orders(
    this.token,
    this.userId,
    this._orders,
  );

  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> fetchAndSetOrders() async {
    final url = Uri.parse('https://flutter-update-1f17b-default-rtdb.firebaseio.com/orders/$userId.json?auth=$token');

    final response = await http.get(url);
    final extractedOrders = json.decode(response.body) as Map<String, dynamic>;
    final List<OrderItem> loadedOrders = [];
    if (extractedOrders == null) return;
    extractedOrders.forEach(
      (orderId, orderData) {
        loadedOrders.add(
          OrderItem(
              id: orderId,
              amount: orderData['amount'],
              dateTime: DateTime.parse(orderData['dateTime']),
              orderedProduct: (orderData['orderedProduct'] as List<dynamic>)
                  .map((item) => CartItem(
                        id: item['id'],
                        price: item['price'],
                        quantity: item['quantity'],
                        title: item['title'],
                      ))
                  .toList()),
        );
      },
    );
    _orders = loadedOrders.reversed.toList();
    notifyListeners();
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    final url = Uri.parse('https://flutter-update-1f17b-default-rtdb.firebaseio.com/orders/$userId.json?auth=$token');
    final timeStamp = DateTime.now();

    final response = await http.post(url,
        body: json.encode({
          'amount': total,
          'dateTime': timeStamp.toIso8601String(),
          'orderedProduct': cartProducts
              .map((cp) => {
                    'title': cp.title,
                    'price': cp.price,
                    'quantity': cp.quantity,
                    'creatorId': userId,
                  })
              .toList(),
        }));

    _orders.insert(
      0,
      OrderItem(
        id: json.decode(response.body)['name'],
        amount: total,
        dateTime: timeStamp,
        orderedProduct: cartProducts,
      ),
    );
    notifyListeners();
  }
}
