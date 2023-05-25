import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../providers/orders.dart' as ord;

class OrderItem extends StatefulWidget {
  final ord.OrderItem order;

  OrderItem(this.order);

  @override
  State<OrderItem> createState() => _OrderItemState();
}

class _OrderItemState extends State<OrderItem>
    with SingleTickerProviderStateMixin {
  var _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      height: _isExpanded
          ? min(widget.order.orderedProduct.length * 20.0 + 110, 200)
          : 95,
      child: Card(
        margin: EdgeInsets.all(10),
        child: Column(
          children: [
            ListTile(
              title: Text('\$${(widget.order.amount).toStringAsFixed(2)}'),
              subtitle: Text(DateFormat('dd/mm/yyyy  hh:mm')
                  .format(widget.order.dateTime)),
              trailing: IconButton(
                icon: Icon(_isExpanded ? Icons.expand_less : Icons.expand_more),
                onPressed: () {
                  setState(() {
                    _isExpanded = !_isExpanded;
                  });
                },
              ),
            ),
            AnimatedContainer(
              duration: Duration(milliseconds: 300),
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 4),
              height: _isExpanded
                  ? min(widget.order.orderedProduct.length * 20.0 + 10, 100)
                  : 0,
              child: AnimatedContainer(
                duration: Duration(milliseconds: 8000),
                curve: Curves.easeIn,
                child: ListView(
                  children: widget.order.orderedProduct
                      .map(
                        (prod) => Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              prod.title,
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '${prod.quantity}  x    \$${prod.price}',
                              style: TextStyle(fontSize: 16),
                            )
                          ],
                        ),
                      )
                      .toList(),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
