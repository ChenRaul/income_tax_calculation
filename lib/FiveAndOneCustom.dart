

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:income_tax_calculation/AppColors.dart';
import 'package:income_tax_calculation/CustomNoticeDialog.dart';

class FiveAndOneCustom extends StatefulWidget{
  FiveAndOneCustom({Key key,this.monthPayValue}):super(key:key);

  final double monthPayValue;
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _FiveAndOneCustomState();
  }

}
class _FiveAndOneCustomState extends State<FiveAndOneCustom>{
  String house='',social='';

  void _showNoticeDialog(String noticeText){
    showDialog(context:context,builder: (BuildContext context){
      return CustomNoticeDialog(
        noticeText: noticeText,
        noticeTitle: '提示',
        isShowOneBtn: true,
        clickOutCancel: true,
        posBtnText: '确定',
        negBtnText: '取消',
        posPress: (){

        },
      );
    });
  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        //设置bar和状态栏的颜色
        backgroundColor:Colors.black87,
        title: Text('五险一金',),
        centerTitle: true,
      ),
      body: Container(
        child: Column(
          children: <Widget>[
        Container(
        color:Colors.white,
          padding: EdgeInsets.all(10),
          child: Row(
            children: <Widget>[
              Text('住房公积金(元)：',style: TextStyle(fontSize: 16,color: Color(AppColors.appThemeColor)),),
              Flexible(
                  child: Container(
                    margin: EdgeInsets.fromLTRB(20, 0, 20, 0),
                    padding: EdgeInsets.all(1),
                    decoration: BoxDecoration(
                        border: Border.all(
                          color: Color(AppColors.appThemeColor),
                          width: 1,
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(3))
                    ),
                    child: TextField(
                      style: TextStyle(color: Colors.black87),
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration.collapsed(
                          hintText: '请输入公积金比例'
                      ),
                      onChanged: (text){
                        house = text;
                      },
                    ),
                  ))
            ],
          ),
        ),
        Container(
        color:Colors.white,
        padding: EdgeInsets.all(10),
        child: Row(
          children: <Widget>[
            Text('社保(元)：',style: TextStyle(fontSize: 16,color: Color(AppColors.appThemeColor)),),
            Flexible(
                child: Container(
                  margin: EdgeInsets.fromLTRB(20, 0, 20, 0),
                  padding: EdgeInsets.all(1),
                  decoration: BoxDecoration(
                      border: Border.all(
                        color: Color(AppColors.appThemeColor),
                        width: 1,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(3))
                  ),
                  child: TextField(
                    style: TextStyle(color: Colors.black87),
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration.collapsed(
                        hintText: '请输入社保比例'
                    ),
                    onChanged: (text){
                      social = text;
                    },
                  ),
                ))
          ],
        ),
      ),
            Container(
              margin: EdgeInsets.fromLTRB(0, 30, 0, 0),
              child:
              CupertinoButton(
                color: Colors.black87,
                pressedOpacity: 0.9,
                child: Text('保存'),
                onPressed: (){
                  if(house.length <=0){
                    _showNoticeDialog('请输入公积金比例');
                  }else if(social.length <=0){
                    _showNoticeDialog('请输入社保比例');
                  }else{
                    double houseD = double.tryParse(house);
                    double socialD = double.tryParse(social);
                    if(houseD == null){
                      _showNoticeDialog('请输入正确的公积金比例');
                    }else if(socialD == null){
                      _showNoticeDialog('请输入正确的社保比例');
                    }else{
                      double h = double.tryParse((widget.monthPayValue*houseD).toStringAsFixed(2));
                      double s = double.tryParse((widget.monthPayValue*socialD).toStringAsFixed(2));
                      Navigator.pop(context,{'house':h,'social':s});
                    }
                  }
                },
              ),
            )
          ],
        ),
      ),
    );
  }
  
}