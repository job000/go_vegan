import 'package:go_vegan/models/additives_data.dart';
class GetListOfAdditivesFromImage{

  List listResultQuery= new List();
  List tempListFromQuery = new List();
  Future<List> listOfQuery(List imageAdditives) async {
    listResultQuery.clear();
    for(int i =0;i<imageAdditives.length;i++) {

      tempListFromQuery = await query("additivesTable", imageAdditives[i]);

      listResultQuery.addAll(tempListFromQuery);
    }
    return listResultQuery;
  }

  String veganOrNot="";
  int vegan=0;
  int mightBeVegan=0;
  int notVegan=0;
  int notDefined=0;
  List queryList=[];
Future<String> veganAdditiveChecker(List imageAdditives) async {
    listResultQuery.clear();

    for (int i = 0; i < imageAdditives.length; i++) {
      tempListFromQuery = await query("additivesTable", imageAdditives[i]);
      queryList = tempListFromQuery.toList();
      if(queryList[3]=="Vegan"){
        vegan++;
      }else if(queryList[3]=="May or may not be vegan"){
        mightBeVegan++;
      }else if(queryList[3]=="Not vegan"){
        notVegan++;
      }else{
        notDefined++;
      }
      print("QUERY 3: ${queryList[3]}");
    }
    if(vegan>0 && notVegan<=0 && mightBeVegan<=0 && notDefined<=0){
      veganOrNot="Vegan";
    }else if(notVegan<=0 && mightBeVegan>0){
      veganOrNot="May or may not be vegan";
    }else if(notVegan>0){
      veganOrNot="Not vegan";
    }else{
      veganOrNot="Not defined";
    }
      return veganOrNot;
  }
  }