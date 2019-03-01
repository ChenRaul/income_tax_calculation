import 'package:flutter/material.dart';
import 'package:income_tax_calculation/AppColors.dart';

class RentHouseSelectDialog extends Dialog{
  final bool clickOutCancel;
  final Function press;
  final List<String> listData = ['直辖/省会/计划单列市','市区人口百万以上城市','市区人口百万以下城市'];
  final List<double> listDataValue = [1500,1100,800];
  RentHouseSelectDialog({
    Key key,
    this.clickOutCancel,//点击对话框外部 是否消失
    this.press,
  }):super(key:key);


  Text _getText(String text){

    return Text(text,
      style: TextStyle(
        color: Color(AppColors.appThemeColor),
        decoration: TextDecoration.none,
        fontSize: 18,
      ),
    );
  }
  ///按钮
  List<Widget> _getData(BuildContext context){
    List<Widget> add = new List();
    for(int i=0;i<listData.length;i++){
      add.add(_getListItem(listData[i], listDataValue[i],context));
    }
//    add.add( _getBtn(context));
    return add;
  }
  Widget _getListItem(String data,double index,BuildContext context){
    return GestureDetector(
      child: Container(
        height: 60,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Colors.grey[800]
            )
          )
        ),
        child: Text('$data',textAlign:TextAlign.left,style: TextStyle(
          fontSize: 16,color: Colors.black87,decoration: TextDecoration.none,
        ),
        ),
      ),
      onTap: (){
        press(index);
        Navigator.pop(context);
      },
    );
  }
  @override
  Widget build(BuildContext context) {

    return  GestureDetector(
      child: Container(
        color: Color(0x00000000),     
        child:  Center(
          child: Container(
            width: MediaQuery.of(context).size.width*0.8,
            height: 180,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:BorderRadius.all( Radius.circular(3)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children:_getData(context),
            ),
          ),
        ),
      ),
      onTap: (){
        if(clickOutCancel){
          Navigator.pop(context);
        }
      },
    );
  }

}