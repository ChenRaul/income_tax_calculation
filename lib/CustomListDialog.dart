import 'package:flutter/material.dart';
import 'package:income_tax_calculation/AppColors.dart';

class CustomListDialog<T> extends Dialog{
  final String posBtnText,negBtnText;
  final bool clickOutCancel,isShowOneBtn;
  final Function posPress,negPress;
  final List<T> listData;

  CustomListDialog({
    Key key,
    this.listData,
    this.clickOutCancel,//点击对话框外部 是否消失
    this.isShowOneBtn,//是否只显示一个按钮
    this.posBtnText,
    this.negBtnText,
    this.posPress,
    this.negPress,
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
  Widget _getBtn(BuildContext context){
    if(isShowOneBtn){//显示一个按钮
      return GestureDetector(
        child: Container(
          alignment: Alignment.center,
          padding: EdgeInsets.fromLTRB(0, 15, 0, 15),
          decoration: BoxDecoration(
              border: Border(
                  top: BorderSide(
                    color: Color(AppColors.grey),
                    width: 1,
                  )
              )
          ),
          child: _getText(posBtnText),

        ),
        onTap: (){
          Navigator.pop(context);
          posPress();
        },
      );
    }else{
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          GestureDetector(
            child: Container(
              alignment: Alignment.center,
              padding: EdgeInsets.fromLTRB(0, 15, 0, 15),
              width: MediaQuery.of(context).size.width*0.8*0.5,
              decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: Color(AppColors.grey),
                      width: 1,
                    ),
                    right:BorderSide(
                      color: Color(AppColors.grey),
                      width: 0.5,
                    ),
                  )
              ),
              child: _getText(negBtnText),
            ),
            onTap: (){
              Navigator.pop(context);
              negPress();
            },
          ),
          GestureDetector(
            child: Container(
              alignment: Alignment.center,
              padding: EdgeInsets.fromLTRB(0, 15, 0, 15),
              width: MediaQuery.of(context).size.width*0.8*0.5,
              decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: Color(AppColors.grey),
                      width: 1,
                    ),
                    left:BorderSide(
                      color: Color(AppColors.grey),
                      width: 0.5,
                    ),
                  )
              ),
              child: _getText(posBtnText),
            ),
            onTap: (){

              Navigator.pop(context);
              posPress();
            },
          ),
        ],
      );
    }
  }
  List<Widget> _getData(BuildContext context){
    List<Widget> add = new List();
    for(int i=0;i<listData.length;i++){
      add.add(_getListItem(listData[i], i));
    }
    add.add( _getBtn(context));
    return add;
  }
  Widget _getListItem(T data,int index){
    return Container(
      height: 25,
      alignment: Alignment.center,
      child: Text('${index+1}月缴税：${double.tryParse('$data').toStringAsFixed(2)}元',textAlign:TextAlign.left,style: TextStyle(
          fontSize: 16,color: Colors.black87,decoration: TextDecoration.none,
        ),
      ),
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
            height: 380,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:BorderRadius.all( Radius.circular(3)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
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