import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/products_provider.dart';
import '../providers/product.dart';

class EditProductScreen extends StatefulWidget {
  static const routeName = '/editProductScreen';

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _priceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _imageUrlController = TextEditingController();
  final _imageUrlFocusNode = FocusNode();
  final _form = GlobalKey<FormState>();

  bool _isInit = true;
  bool _isLoading = false;

  var _editedProduct = Product(
    id: null,
    title: '',
    description: '',
    price: 0,
    imageUrl: '',
  );

  var _initValue = {
    'title': '',
    'price': '',
    'description': '',
    'imageUrl': '',
  };

  @override
  void initState() {
    super.initState();
    _imageUrlFocusNode.addListener(() {
      _updateImageUrl();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      final productId = ModalRoute.of(context).settings.arguments as String;
      if (productId != null) {
        _editedProduct = Provider.of<Products>(context).findById(productId);
        _initValue = {
          'title': _editedProduct.title,
          'price': _editedProduct.price.toString(),
          'description': _editedProduct.description,
          'imageUrl': '',
        };
        _imageUrlController.text = _editedProduct.imageUrl;
      }
    }
    _isInit = false;
  }

  @override
  void dispose() {
    super.dispose();
    _imageUrlFocusNode.removeListener(() {});
    _priceFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _imageUrlController.dispose();
    _imageUrlFocusNode.dispose();
  }

  void _updateImageUrl() {
    if (_imageUrlFocusNode.hasFocus) {
      if ((!_imageUrlController.text.startsWith('http') &&
              !_imageUrlController.text.startsWith('https') ||
          !_imageUrlController.text.endsWith('.jpg') &&
              !_imageUrlController.text.endsWith('.jpeg') &&
              !_imageUrlController.text.endsWith('.png'))) {
        return;
      }
    }
    setState(() {});
  }

  Future<void> _saveForm() async {
    final isvalid = _form.currentState.validate();
    if (!isvalid) {
      return;
    }
    _form.currentState.save();
    setState(() {
      _isLoading = true;
    });
    if (_editedProduct.id != null) {
      await Provider.of<Products>(context, listen: false)
          .updateItems(_editedProduct.id, _editedProduct);
      Navigator.of(context).pop();
      setState(() {
        _isLoading = false;
      });
    } else {
      try {
        await Provider.of<Products>(context, listen: false)
            .addItem(_editedProduct);
      } catch (error) {
        await showDialog(
          context: context,
          builder: ((ctx) {
            return AlertDialog(
              title: Text('An error occurred!'),
              content: Text('Something went wrong.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                  },
                  child: Text('Okay'),
                )
              ],
            );
          }),
        );
      } finally {
        Navigator.of(context).pop();
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Products'),
        actions: [
          IconButton(onPressed: _saveForm, icon: Icon(Icons.save)),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: EdgeInsets.all(16),
              child: Form(
                key: _form,
                child: ListView(
                  children: [
                    TextFormField(
                      initialValue: _initValue['title'],
                      decoration: InputDecoration(labelText: 'Title'),
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(_priceFocusNode);
                      },
                      onSaved: (newValue) {
                        _editedProduct = Product(
                          title: newValue,
                          description: '',
                          price: 0,
                          imageUrl: '',
                          id: _editedProduct.id,
                          isFavorite: _editedProduct.isFavorite,
                        );
                      },
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please Enter Some Value!';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      initialValue: _initValue['price'],
                      decoration: InputDecoration(labelText: 'Price'),
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.number,
                      focusNode: _priceFocusNode,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context)
                            .requestFocus(_descriptionFocusNode);
                      },
                      onSaved: (newValue) {
                        _editedProduct = Product(
                          title: _editedProduct.title,
                          description: '',
                          price: double.parse(newValue),
                          imageUrl: '',
                          id: _editedProduct.id,
                          isFavorite: _editedProduct.isFavorite,
                        );
                      },
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please enter a price!';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter valid price!';
                        }
                        if (double.parse(value) <= 0) {
                          return 'Please enter a price greater than zero!';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      initialValue: _initValue['description'],
                      decoration: InputDecoration(labelText: 'Description'),
                      keyboardType: TextInputType.multiline,
                      maxLines: 3,
                      focusNode: _descriptionFocusNode,
                      onSaved: (newValue) {
                        _editedProduct = Product(
                          title: _editedProduct.title,
                          description: newValue,
                          price: _editedProduct.price,
                          imageUrl: '',
                          id: _editedProduct.id,
                          isFavorite: _editedProduct.isFavorite,
                        );
                      },
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please enter a description!';
                        }
                        if (value.length <= 10) {
                          return 'Description should be atleast 10 characters long!';
                        }
                        return null;
                      },
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          margin: EdgeInsets.only(top: 20, right: 10),
                          height: 100,
                          width: 100,
                          decoration: BoxDecoration(
                            border: Border.all(width: 1, color: Colors.grey),
                          ),
                          child: _imageUrlController.text.isEmpty
                              ? Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text('Enter image url'),
                                )
                              : FittedBox(
                                  child: Image.network(
                                    _imageUrlController.text,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                        ),
                        Expanded(
                          child: TextFormField(
                            decoration: InputDecoration(labelText: 'Image URL'),
                            textInputAction: TextInputAction.done,
                            keyboardType: TextInputType.url,
                            controller: _imageUrlController,
                            focusNode: _imageUrlFocusNode,
                            onEditingComplete: () {
                              setState(() {});
                            },
                            onFieldSubmitted: (value) {
                              _saveForm();
                            },
                            onSaved: (newValue) {
                              _editedProduct = Product(
                                title: _editedProduct.title,
                                description: _editedProduct.description,
                                price: _editedProduct.price,
                                imageUrl: newValue,
                                id: _editedProduct.id,
                                isFavorite: _editedProduct.isFavorite,
                              );
                            },
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Please enter a image url.';
                              }
                              if (!value.startsWith('http') &&
                                  !value.startsWith('https')) {
                                return 'Please enter valid url.';
                              }
                              if (!value.endsWith('.jpg') &&
                                  !value.endsWith('.jpeg') &&
                                  !value.endsWith('.png')) {
                                return 'Please enter valid url.';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    Divider(
                      height: 30,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        _saveForm();
                      },
                      child: Text('Save'),
                    )
                  ],
                ),
              ),
            ),
    );
  }
}
