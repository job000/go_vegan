import 'package:flutter/material.dart';

class ListOfAllAdditives extends StatefulWidget {

  final List additivesFromImage;

  ListOfAllAdditives({@required this.additivesFromImage});
  @override
  _ListOfAllAdditivesState createState() => _ListOfAllAdditivesState(this.additivesFromImage);
}

class _ListOfAllAdditivesState extends State<ListOfAllAdditives> {

  List additivesFromImage;
  _ListOfAllAdditivesState(this.additivesFromImage);

  @override
  Widget build(BuildContext context) {

    Color listTileColor;
    return Center(
      child: Column(
        children: <Widget>[
          Expanded(
            flex: 2,
            child: Container(
              color: listTileColor,
              child: ListView.builder(
                itemCount: additivesFromImage.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: ListTile(
                      leading: Icon(Icons.info),
                      title: Text(
                        additivesFromImage[index],
                        style: TextStyle(
                            fontSize: 18.0,
                            color: Colors.black54,
                            fontWeight: FontWeight.bold),
                      ),
                      trailing: Icon(Icons.arrow_forward_ios),

                      onTap: (){
                        setState(() {
                          //navigateToDetail(additivesFromImage[index]);
                        });
                      },
                    ),
                  );

                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
