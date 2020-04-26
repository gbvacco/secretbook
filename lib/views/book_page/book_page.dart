import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class BookPage extends StatefulWidget {
  BookPage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _BookPageState createState() => _BookPageState();
}

enum _Actions { deleteAll }
enum _ItemActions { delete, edit }

class _BookPageState extends State<BookPage> {
  final _storage = FlutterSecureStorage();
  List<_SecItem> _items = [];

  // Map<String, String> allValues = await storage.readAll();

  @override
  void initState() {
    super.initState();
    _readAll();
  }

  Future<Null> _readAll() async {
    final all = await _storage.readAll();
    setState(() {
      return _items = all.keys
          .map((key) => _SecItem(key, all[key]))
          .toList(growable: false);
    });
  }

  void _deleteAll() async {
    await _storage.deleteAll();
    _readAll();
  }

  void _addNewItem() async {
    final String key = _randomValue();
    final String value = _randomValue();

    await _storage.write(key: key, value: value);
    _readAll();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CupertinoNavigationBar(
        backgroundColor: Colors.grey[900],
        leading: Icon(
          Icons.menu,
          color: Colors.white,
        ),
        middle: Text(
          widget.title,
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: ListView.separated(
        itemCount: _items.length,
        separatorBuilder: (context, index) {
          return Divider();
        },
        itemBuilder: (BuildContext context, int index) => ListTile(
          onTap: () => print(index),
          trailing: Icon(Icons.arrow_forward_ios),
          title: Text(
            _items[index].value,
            key: Key('title_row_$index'),
          ),
          subtitle: Text(
            _items[index].key,
            key: Key('subtitle_row_$index'),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.grey[900],
        onPressed: _addNewItem,
        tooltip: 'Increment',
        child: Icon(Icons.create),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Future<Null> _performAction(_ItemActions action, _SecItem item) async {
    switch (action) {
      case _ItemActions.delete:
        await _storage.delete(key: item.key);
        _readAll();

        break;
      case _ItemActions.edit:
        final result = await showDialog<String>(
            context: context,
            builder: (context) => _EditItemWidget(item.value));
        if (result != null) {
          _storage.write(key: item.key, value: result);
          _readAll();
        }
        break;
    }
  }

  String _randomValue() {
    final rand = Random();
    final codeUnits = List.generate(20, (index) {
      return rand.nextInt(26) + 65;
    });

    return String.fromCharCodes(codeUnits);
  }
}

class _EditItemWidget extends StatelessWidget {
  _EditItemWidget(String text)
      : _controller = TextEditingController(text: text);

  final TextEditingController _controller;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Edit item'),
      content: TextField(
        key: Key('title_field'),
        controller: _controller,
        autofocus: true,
      ),
      actions: <Widget>[
        FlatButton(
            key: Key('cancel'),
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel')),
        FlatButton(
            key: Key('save'),
            onPressed: () => Navigator.of(context).pop(_controller.text),
            child: Text('Save')),
      ],
    );
  }
}

class _SecItem {
  _SecItem(this.key, this.value);

  final String key;
  final String value;
}
