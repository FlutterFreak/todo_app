import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_todo_app/model/element.dart';
import 'package:flutter_todo_app/utils/diamond_fab.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class DetailPage extends StatefulWidget {
  final FirebaseUser user;
  final int i;
  final Map<String, List<ElementTask>> currentList;
  final String color;

  DetailPage({Key key, this.user, this.i, this.currentList, this.color})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  TextEditingController itemController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //key: _scaffoldKey,
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: new Stack(
        children: <Widget>[
          _getToolbar(context),
          Container(
            child: NotificationListener<OverscrollIndicatorNotification>(
              onNotification: (overscroll) {
                overscroll.disallowGlow();
              },
              child: new StreamBuilder<QuerySnapshot>(
                  stream: Firestore.instance
                      .collection(widget.user.uid)
                      .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (!snapshot.hasData)
                      return new Center(
                          child: CircularProgressIndicator(
                        backgroundColor: currentColor,
                      ));
                    return new Container(
                      child: getExpenseItems(snapshot),
                    );
                  }),
            ),
          ),
        ],
      ),
      floatingActionButton: DiamondFab(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                content: Row(
                  children: <Widget>[
                    Expanded(
                      child: new TextField(
                        autofocus: true,
                        decoration: InputDecoration(
                            border: new OutlineInputBorder(
                                borderSide:
                                    new BorderSide(color: currentColor)),
                            labelText: "Item",
                            hintText: "Item",
                            contentPadding: EdgeInsets.only(
                                left: 16.0,
                                top: 20.0,
                                right: 16.0,
                                bottom: 5.0)),
                        controller: itemController,
                        style: TextStyle(
                          fontSize: 22.0,
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                        keyboardType: TextInputType.text,
                        textCapitalization: TextCapitalization.sentences,
                      ),
                    )
                  ],
                ),
                actions: <Widget>[
                  ButtonTheme(
                    //minWidth: double.infinity,
                    child: RaisedButton(
                      elevation: 3.0,
                      onPressed: () {
                        if (itemController.text.isNotEmpty &&
                            !widget.currentList.values
                                .contains(itemController.text.toString())) {
                          Firestore.instance
                              .collection(widget.user.uid)
                              .document(
                                  widget.currentList.keys.elementAt(widget.i))
                              .updateData(
                                  {itemController.text.toString(): false});

                          itemController.clear();
                          Navigator.of(context).pop();
                        }
                      },
                      child: Text('Add'),
                      color: Colors.deepPurple,
                      textColor: const Color(0xffffffff),
                    ),
                  )
                ],
              );
            },
          );
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.deepPurple,
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  getExpenseItems(AsyncSnapshot<QuerySnapshot> snapshot) {
    List<ElementTask> listElement = new List();
    int nbIsDone = 0;

    if (widget.user.uid.isNotEmpty) {
      snapshot.data.documents.map<Column>((f) {
        if (f.documentID == widget.currentList.keys.elementAt(widget.i)) {
          f.data.forEach((a, b) {
            if (b.runtimeType == bool) {
              listElement.add(new ElementTask(a, b));
            }
          });
        }
      }).toList();

      listElement.forEach((i) {
        if (i.isDone) {
          nbIsDone++;
        }
      });

      return Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(top: 150.0),
            child: new Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: 5.0, left: 50.0, right: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Flexible(
                        fit: FlexFit.loose,
                        child: Text(
                          widget.currentList.keys.elementAt(widget.i),
                          softWrap: true,
                          overflow: TextOverflow.fade,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 35.0),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return new AlertDialog(
                                title: Text("Delete: " +
                                    widget.currentList.keys
                                        .elementAt(widget.i)
                                        .toString()),
                                content: Text(
                                  "Are you sure you want to delete this list?",
                                  style: TextStyle(fontWeight: FontWeight.w400),
                                ),
                                actions: <Widget>[
                                  ButtonTheme(
                                    //minWidth: double.infinity,
                                    child: RaisedButton(
                                      elevation: 3.0,
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: Text('No'),
                                      color: Colors.deepPurple,
                                      textColor: const Color(0xffffffff),
                                    ),
                                  ),
                                  ButtonTheme(
                                    //minWidth: double.infinity,
                                    child: RaisedButton(
                                      elevation: 3.0,
                                      onPressed: () {
                                        Firestore.instance
                                            .collection(widget.user.uid)
                                            .document(widget.currentList.keys
                                                .elementAt(widget.i))
                                            .delete();
                                        Navigator.pop(context);
                                        Navigator.of(context).pop();
                                      },
                                      child: Text('YES'),
                                      color: Colors.deepPurple,
                                      textColor: const Color(0xffffffff),
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: Icon(
                          FontAwesomeIcons.trash,
                          size: 25.0,
                          color: Colors.deepPurple,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 5.0, left: 50.0),
                  child: Row(
                    children: <Widget>[
                      new Text(
                        nbIsDone.toString() +
                            " of " +
                            listElement.length.toString() +
                            " tasks",
                        style: TextStyle(fontSize: 18.0, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 5.0),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        flex: 2,
                        child: Container(
                          margin: EdgeInsets.only(left: 50.0),
                          color: Colors.grey,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 30.0),
                  child: Column(
                    children: <Widget>[
                      Container(
                        color: Color(0xFFFCFCFC),
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height - 350,
                          child: ListView.builder(
                              physics: const BouncingScrollPhysics(),
                              itemCount: listElement.length,
                              itemBuilder: (BuildContext ctxt, int i) {
                                return new Slidable(
                                  delegate: new SlidableBehindDelegate(),
                                  actionExtentRatio: 0.25,
                                  child: GestureDetector(
                                    onTap: () {
                                      Firestore.instance
                                          .collection(widget.user.uid)
                                          .document(widget.currentList.keys
                                              .elementAt(widget.i))
                                          .updateData({
                                        listElement.elementAt(i).name:
                                            !listElement.elementAt(i).isDone
                                      });
                                    },
                                    child: Container(
                                      height: 50.0,
                                      color: listElement.elementAt(i).isDone
                                          ? Color(0xFFF0F0F0)
                                          : Color(0xFFFCFCFC),
                                      child: Padding(
                                        padding: EdgeInsets.only(left: 50.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: <Widget>[
                                            Icon(
                                              listElement.elementAt(i).isDone
                                                  ? FontAwesomeIcons.checkSquare
                                                  : FontAwesomeIcons.square,
                                              color: Colors.black,
                                              size: 20.0,
                                            ),
                                            Padding(
                                              padding:
                                                  EdgeInsets.only(left: 30.0),
                                            ),
                                            Flexible(
                                              child: Text(
                                                listElement.elementAt(i).name,
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,
                                                style: listElement
                                                        .elementAt(i)
                                                        .isDone
                                                    ? TextStyle(
                                                        decoration:
                                                            TextDecoration
                                                                .lineThrough,
                                                        color: Colors.black,
                                                        fontSize: 27.0,
                                                      )
                                                    : TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 27.0,
                                                      ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  secondaryActions: <Widget>[
                                    new IconSlideAction(
                                      caption: 'Delete',
                                      color: Colors.red,
                                      icon: Icons.delete,
                                      onTap: () {
                                        Firestore.instance
                                            .collection(widget.user.uid)
                                            .document(widget.currentList.keys
                                                .elementAt(widget.i))
                                            .updateData({
                                          listElement.elementAt(i).name: ""
                                        });
                                      },
                                    ),
                                  ],
                                );
                              }),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }
  }

  @override
  void initState() {
    super.initState();

    currentColor = Color(int.parse(widget.color));
  }

  Color currentColor;

  ValueChanged<Color> onColorChanged;

  Padding _getToolbar(BuildContext context) {
    return new Padding(
      padding: EdgeInsets.only(top: 50.0, left: 45.0, right: 12.0),
      child:
          new Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        new Image(
            width: 35.0,
            height: 35.0,
            fit: BoxFit.cover,
            image: new AssetImage('assets/list.png')),
        GestureDetector(
          onTap: () {
            Navigator.of(context).pop();
          },
          child: new Icon(
            Icons.close,
            size: 40.0,
            color: Colors.deepPurple,
          ),
        ),
      ]),
    );
  }
}
