import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:income_tax_calculation/AppColors.dart';
import 'package:income_tax_calculation/CustomListDialog.dart';
import 'package:income_tax_calculation/CustomNoticeDialog.dart';
import 'package:income_tax_calculation/Ratio.dart';
import 'package:income_tax_calculation/RentHouseSelectDialog.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '个税计算',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: '个税计算'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);


  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final double baseTax = 5000;
  double houseValue=0;//公积金值
  double socialValue=0;//社保值
  double houseLoansValue=0;//住房支出，贷款1000，租房分为1500、1100、800
  double childValue=0;//小孩受教育，每个1000元
  double oldManValue=0;//赡养老人，独生子女2000，不是则自定义填写，不能超过1000
  double continueEducationValue = 0;//继续教育，学历教育400，技能/资格教育300
  double seriousValue=0;//大病支出，小于15000则不予扣减，但不能超过80000
  double monthPayValue=0;//月薪资

  String monthPayStr='';

  List<double> value = List();//'月薪资','五险一金','子女教育','继续教育','住房支出','赡养老人','大病医疗'
  InputDecoration inputDecoration;
  List<double> preTaxList=[0,0,0,0,0,0,0,0,0,0,0,0];//预缴默认税款，
  double preUpTaxValue = 0;//预缴税本金
  bool seriousByMonth = true;
  int childNum=0;
  bool oldManOff = true;//隐藏

  @override
  void initState(){
    super.initState();
  }
  void _showListDialog(List<double> data,String posBtnText,int index){
    showDialog(context:context,builder: (BuildContext context){
      return CustomListDialog(
        listData: data,
        isShowOneBtn: true,
        clickOutCancel: true,
        posBtnText: posBtnText,
        negBtnText: '取消',
        posPress: (){
          if(index != -1){
            setState(() {
              value[index] = 0;
            });
          }
        },
      );
    });
  }
  void _showSelectRentHouseDialog(){
    showDialog(context:context,builder: (BuildContext context){
      return RentHouseSelectDialog(
        clickOutCancel: false,
        press: (value){
            setState(() {
              houseLoansValue = value;
            });
        },
      );
    });
  }
  void _showNoticeDialog(String noticeText,int index){
    showDialog(context:context,builder: (BuildContext context){
      return CustomNoticeDialog(
        noticeText: noticeText,
        noticeTitle: '提示',
        isShowOneBtn: true,
        clickOutCancel: true,
        posBtnText: '确定',
        negBtnText: '取消',
        posPress: (){

          setState(() {
            switch(index){
              case 1:
                monthPayValue = 0;
                break;
              case 2:
                childNum = 0;
                break;
              case 3:
                oldManValue = 0;
                break;
              case 999:
                break;
            }

          });
        },
      );
    });
  }
//上一年度的大病医疗实时扣除
  void _onCalculate(){


    if(monthPayValue==0){
      _showNoticeDialog('月工资是必填项',999);
      return;
    }
    print('$monthPayValue,${houseValue+socialValue},$childValue,$continueEducationValue,$houseLoansValue,$oldManValue');
    value.clear();
    value.add(monthPayValue);
    value.add(houseValue+socialValue);
    value.add(childValue);
    value.add(continueEducationValue);
    value.add(houseLoansValue);
    value.add(oldManValue);

    double count=0;
    if(seriousByMonth){//大病医疗按月扣除
         value.add(seriousValue/12);
        print('每月大病疗 = ${value[value.length-1]}');
        double need = 0;
        for(int i=0;i<value.length;i++){
          if(i == 0){
            need = value[i] - baseTax;
          }else{
            need -= value[i];
          }
        }
         print('need = $need');

        for(int i=0;i<12;i++){
          double temp = _calculateMonth(need,i+1);
          print('${i+1}月：$temp 元');
          preTaxList[i] = temp;//循环是直接从第一个月到12月，所以一次添加每个月的扣税金额即可
          count+=temp;
        }
    }else{
      value.add(seriousValue);
      double need = 0;//需要缴税的本金
      bool seriousOver = false;
      for(int i=0;i<value.length;i++){
        if(i == 0){
          need = value[i] -baseTax;
        }else{
          need -= value[i];
        }
      }

      if(need <= 0){//说明大病医疗还有剩余的没有扣除
        value[value.length-1] = need.abs();
        seriousOver = false;
      }else{
        seriousOver = true;
        value[value.length-1] = 0;
      }
      print('need = ${value[value.length-1]}');
      int noUpTaxMonth = 0;
      for(int i=0;i<12;i++){
        if(seriousOver){
          double temp = _calculateMonth(need,i+1-noUpTaxMonth);
          print('${i+1}月缴税：$temp 元,缴税本金：${need*(i+1-noUpTaxMonth)}元 ${i+1-noUpTaxMonth}，剩余大病医疗保险：${value[value.length-1]}元');
          preTaxList[i] = temp;//循环是直接从第一个月到12月，所以一次添加每个月的扣税金额即可
          count+=temp;
          for(int i=0;i<value.length;i++){
            if(i == 0){
              need = value[i]-baseTax;
            }else{
              need -= value[i];
            }
          }
        }else{
          noUpTaxMonth++;
          double temp = _calculateMonth(0,i+1);
          print('${i+1}月缴税：$temp 元,缴税本金：0元，剩余大病医疗保险：${value[value.length-1]}元');
          preTaxList[i] = temp;//循环是直接从第一个月到12月，所以一次添加每个月的扣税金额即可
          count+=temp;

          //重新计算need，直到大病医疗没有剩余
          print(value);
          for(int i=0;i<value.length;i++){
            if(i == 0){
              need = value[i] -baseTax;
            }else{
              need -= value[i];
            }
          }
          if(need <= 0){//说明大病医疗还有剩余的没有扣除
            value[value.length-1] = need.abs();
            seriousOver = false;
          }else{
            value[value.length-1] = 0;
            seriousOver = true;
          }

        }

      }

    }
    print(preTaxList);
    _showListDialog(preTaxList,'全年合计缴税${count.toStringAsFixed(2)}元', -1);
  }
  //获取税率
  double _getTaxRate(double preUpTaxValue){
//    final List<double> taxRate=[0.03,0.1,0.2,0.25,0.30,0.35,0.45];//税率
    double taxRate=0.03;
    if(preUpTaxValue <= 36000){
      taxRate=0.03;
    }else if(preUpTaxValue > 36000 && preUpTaxValue <=144000){
      taxRate=0.1;
    }else if(preUpTaxValue > 144000 && preUpTaxValue <=300000){
      taxRate=0.2;
    }else if(preUpTaxValue > 300000 && preUpTaxValue <=420000){
      taxRate=0.25;
    }else if(preUpTaxValue > 420000 && preUpTaxValue <=660000){
      taxRate=0.3;
    }else if(preUpTaxValue > 660000 && preUpTaxValue <=960000){
      taxRate=0.35;
    }else{
      taxRate=0.45;
    }
    return taxRate;
  }
  ///根据税率获取速算扣除数
  double _getTaxDeduct(double taxRate){
    double deductValue = 0;
    if(taxRate == 0.03){
      deductValue = 0;
    }else if(taxRate == 0.1){
      deductValue = 2520;
    }else if(taxRate == 0.2){
      deductValue = 16920;
    }else if(taxRate == 0.25){
      deductValue = 31920;
    }else if(taxRate == 0.3){
      deductValue = 52920;
    }else if(taxRate == 0.35){
      deductValue = 85920;
    }else if(taxRate == 0.45){
      deductValue = 181920;
    }

    return deductValue;
  }
  double _calculateMonth(double temp,int month){
    double taxRate = _getTaxRate(temp*month);//税率
    double deductValue = _getTaxDeduct(taxRate);//得到速算扣除数
    double preMonthTaxCount=0;//前month月前缴税综合
    for(int i=0; i< month-1;i++){
      preMonthTaxCount+=preTaxList[i];
    }
    double current =  temp*month*taxRate-deductValue-preMonthTaxCount;
    print('缴税本金${temp*month},税率$taxRate,速算扣除数$deductValue,前${month-1}月缴税$preMonthTaxCount,当前缴税$current');
    return current;
  }

  //税前工资
  Widget _payMonth(){
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(10, 5, 40, 5),
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Flexible(
            child: Container(
              margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
              child: Text('税前工资：',textAlign:TextAlign.left,style: TextStyle(
                  fontSize: 16,color: Colors.black87,fontWeight: FontWeight.bold
              ),),
            ),
          ),
          ///在Row或者Column等使用TextField时，需要在外面包裹一层Flexible,
          Flexible(
            child: TextField(
//              controller: TextEditingController.fromValue(
//                  TextEditingValue(
//                      text: '${monthPayValue==0?'':monthPayValue}',
//                      //当setState设置text属性时，下面的属性可以保持光标在最后
//                      selection: TextSelection.fromPosition(
//                        TextPosition(
//                          affinity: TextAffinity.downstream,
//                          offset: '${monthPayValue==0?'':monthPayValue}'.length
//                        )
//                      )
//                  )
//              ) ,
              focusNode: FocusNode(),
              keyboardType:TextInputType.number,
              textAlign: TextAlign.left,
              cursorWidth: 1,
              style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87

              ),
              decoration: inputDecoration =InputDecoration(
                contentPadding: EdgeInsets.all(5) ,
                hintText:'0.0',
                hintStyle: TextStyle(color: Colors.grey,fontSize: 16),
                border:OutlineInputBorder(
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (String text){

                if(text.length > 0){
                  double temp = double.tryParse(text);
                  if(temp==null){
                    _showNoticeDialog('请输入正确金额!',1);
                  }else{
                    monthPayValue = temp;
                    setState(() {
                      houseValue = double.parse((monthPayValue*Ratio.houseFound).toStringAsFixed(2));
                      socialValue = double.parse((monthPayValue*Ratio.social).toStringAsFixed(2));
                    });
                  }
                }else{
                  monthPayValue = 0;
                  setState(() {
                    houseValue = 0;
                    socialValue = 0;
                  });
                }
              },
            ),
          ),
        ],
      ),
    );
  }
  Widget _getTitleItem(String title){
    return Container(
      padding: EdgeInsets.all(5),
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        color: Color(AppColors.grey),
        border: Border(left: BorderSide(
          color:Color(AppColors.appThemeColor),
          width: 10
        ))
      ),
      child: Text(title,style: TextStyle(
        color: Colors.white,fontWeight: FontWeight.bold,fontSize: 16,
      ),),
    );
  }

  ///五险一金布局
  Widget _getFiveAndOne(){

    return Container(
        color: Colors.white,
      padding: EdgeInsets.fromLTRB(20, 5, 5, 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              RichText(
                text:TextSpan(
                  children: [
                    TextSpan(
                        text: '住房公积金：',
                        style: TextStyle(color: Colors.black87,fontSize: 14,)
                    ),
                    TextSpan(
                        text: '$houseValue',
                        style: TextStyle(color: Color(AppColors.appThemeColor),fontSize: 14,)
                    ),
                    TextSpan(
                        text: '元',
                        style: TextStyle(color: Colors.black87,fontSize: 14,)
                    ),
                  ]
                )
              ),
              RichText(
                  text:TextSpan(
                      children: [
                        TextSpan(
                            text: '社保：',
                            style: TextStyle(color: Colors.black87,fontSize: 14,)
                        ),
                        TextSpan(
                            text: '$socialValue',
                            style: TextStyle(color: Color(AppColors.appThemeColor),fontSize: 14,)
                        ),
                        TextSpan(
                            text: '元',
                            style: TextStyle(color: Colors.black87,fontSize: 14,)
                        ),
                      ]
                  )
              )
            ],
          ),
          SizedBox(
            width: 60,
            height: 30,
            child: CupertinoButton(
                color: Color(AppColors.appThemeColor),
                pressedOpacity: 0.9,
                borderRadius: BorderRadius.all(Radius.circular(3)),
                padding: EdgeInsets.all(0),
                child: Text('自定义',style: TextStyle(fontSize: 14),),
                onPressed: (){
                  //TODO 跳转到自定义页面
                }
            ),
          )
        ],
      ),
    );
  }
///住房贷款支出
  Widget _getHouseLoans(){

    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          SizedBox(
              height: 30,
            child:CupertinoButton(
                color: houseLoansValue == 1000 ?Color(AppColors.appThemeColor):Colors.grey[500],
                pressedOpacity: 0.9,
                borderRadius: BorderRadius.all(Radius.circular(3)),
                padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                child: Text('首套房贷(1000元/月)',style: TextStyle(fontSize: 14),),
                onPressed: (){
                  setState(() {
                    houseLoansValue = 1000;
                  });
                })
            ),
            SizedBox(
                height: 30,
                child:CupertinoButton(
                    color: houseLoansValue != 1000 && houseLoansValue != 0 ?Color(AppColors.appThemeColor):Colors.grey[500],
                    pressedOpacity: 0.9,
                    borderRadius: BorderRadius.all(Radius.circular(3)),
                    padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                    child: Text(houseLoansValue != 1000 && houseLoansValue != 0 ?'租房($houseLoansValue )元/月':'租房',style: TextStyle(fontSize: 14),),
                    onPressed: (){
                      _showSelectRentHouseDialog();
                    })
            )
        ],
      ),
    );
  }

  ///子女教育
  Widget _getEducation(){
    return Container(
      color:Colors.white,
      padding: EdgeInsets.all(10),
      child: Column(
        children: <Widget>[
             Container(
               margin: EdgeInsets.fromLTRB(30, 0, 30, 10),
              padding: EdgeInsets.all(3),
              ///间接设置TextField的输入框边框颜色，和宽度
              decoration: BoxDecoration(
                border: Border.all(
                  color: Color(AppColors.appThemeColor),
                  width: 1,
                  
                ),
                borderRadius: BorderRadius.all(Radius.circular(3))
              ),
              child: Theme(
                ///设置输入框的边框颜色，使用上面的方式可以设置输入框的边框宽度
                data: ThemeData(
                    primaryColor: Color(AppColors.appThemeColor),
                    accentColor: Color(AppColors.appThemeColor),
                    hintColor:  Colors.black87
                ),
                child: TextField(
                  ///设置输入框的内容
//                    controller: TextEditingController(text: childNum==0?'':'$childNum') ,
                    keyboardType:TextInputType.number,
//                    inputFormatters: WIn,
                    style:TextStyle(
                        color: Colors.black87,
                        fontSize: 15
                    ),

                    decoration:InputDecoration.collapsed(
                      hintText: '请先填写受教育子女个数',
                    ),
                    onChanged: (text){
                      if(text.length > 0){
                        int temp = int.tryParse(text);
                        if(temp == null){
                          _showNoticeDialog('请输入正确的数量',2);
                        }else{
                          ///TODO
                          print('子女个数：$temp');
//                          setState(() {
                            childNum = temp;
//                          });
                        }
                      }else{
                        setState(() {
                          childNum = 0;
                        });
                      }
                    },
                ),
              ),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              SizedBox(
                  height: 30,
                  child:CupertinoButton(
                      color: childValue/childNum == 1000 ?Color(AppColors.appThemeColor):Colors.grey[500],
                      pressedOpacity: 0.9,
                      borderRadius: BorderRadius.all(Radius.circular(3)),
                      padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                      child: Text('单独抵扣(${childValue/childNum == 1000?childValue:0}元/月)',style: TextStyle(fontSize: 14),),
                      onPressed: (){
                        if(childNum > 0){
                          setState(() {
                            print(childNum);
                            childValue = 1000.0 * childNum;
                            print(childValue);
                          });
                        }else{
                          _showNoticeDialog('请先填写受教育子女个数', 999);
                        }
                      })
              ),
              SizedBox(
                  height: 30,
                  child:CupertinoButton(
                      color: childValue/childNum == 500 ?Color(AppColors.appThemeColor):Colors.grey[500],
                      pressedOpacity: 0.9,
                      borderRadius: BorderRadius.all(Radius.circular(3)),
                      padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                      child: Text('共同抵扣(${childValue/childNum == 500?childValue:0}元/月)',style: TextStyle(fontSize: 14),),
                      onPressed: (){
                        if(childNum > 0){
                          setState(() {
                            // ignore: unnecessary_statements
                            childValue = 1000*childNum/2;
                          });
                        }else{
                          _showNoticeDialog('请先填写受教育子女个数', 999);
                        }
                      })
              )
            ],
          )
        ],
      ),
    );
  }
  ///赡养老人
  Widget _getOldMan(){
    return Container(
      color:Colors.white,
      padding: EdgeInsets.all(10),
      child: Column(

        children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Text('是否独生子女:',style: TextStyle(fontSize: 16,color: Color(AppColors.appThemeColor)),),
                SizedBox(
                  height: 30,
                  child: CupertinoButton(
                      color: oldManValue== 2000 ?Color(AppColors.appThemeColor):Colors.grey[500],
                      padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                      pressedOpacity: 0.9,
                      borderRadius: BorderRadius.all(Radius.circular(3)),
                      child: Text('是(2000元/月)',style: TextStyle(fontSize: 14),),
                      onPressed: (){
                        setState(() {
                          oldManOff = true;
                          oldManValue = 2000;
                        });
                      }
                  ),
                ),
                SizedBox(
                  height: 30,
                  child: CupertinoButton(
                      color:  oldManValue!= 2000 ? Color(AppColors.appThemeColor):Colors.grey[500],
                      padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                      pressedOpacity: 0.9,
                      borderRadius: BorderRadius.all(Radius.circular(3)),
                      child: Text('否(${oldManValue != 2000?oldManValue:0}元/月)',style: TextStyle(fontSize: 14),),
                      onPressed: (){
                        setState(() {
                          oldManValue=0;
                          oldManOff = false;
                        });
                      }
                  ),
                ),
              ],
            ),
            Offstage(
              offstage: oldManOff,
              child: Container(
                margin: EdgeInsets.fromLTRB(60, 10, 20, 10),
                padding: EdgeInsets.all(3),
                decoration: BoxDecoration(
                      border: Border.all(
                        color: Color(AppColors.appThemeColor),
                        width: 1,

                      ),
                      borderRadius: BorderRadius.all(Radius.circular(3))
                ),
                child: TextField(
                  decoration: InputDecoration.collapsed(hintText: '请输入分摊金额(不超过1000元)'),
                  keyboardType: TextInputType.number,
                  onChanged: (text){
                    if(text.length > 0){
                      double temp = double.tryParse(text);
                      if(temp == null || temp >1000){
                        _showNoticeDialog('请输入正确的金额', 3);
                      }else{
                        setState(() {
                          oldManValue = temp;
                        });
                      }
                    }else{
                      setState(() {
                        oldManValue = 0;
                      });
                    }
                  },
                ),
              ),
            )
        ],

      ),
    );
  }
  ///继续教育
  Widget _getContinuingEducation(){
    return Container(
      color:Colors.white,
      padding: EdgeInsets.all(10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          SizedBox(
            height: 30,
            child: CupertinoButton(
                color:  continueEducationValue == 400 ? Color(AppColors.appThemeColor):Colors.grey[500],
                padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                pressedOpacity: 0.9,
                borderRadius: BorderRadius.all(Radius.circular(3)),
                child: Text('学历教育(400元/月)',style: TextStyle(fontSize: 14),),
                onPressed: (){
                  setState(() {
                    continueEducationValue = 400;
                  });
                }
            ),
          ),
          SizedBox(
            height: 30,
            child: CupertinoButton(
                color:  continueEducationValue == 300 ? Color(AppColors.appThemeColor):Colors.grey[500],
                padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                pressedOpacity: 0.9,
                borderRadius: BorderRadius.all(Radius.circular(3)),
                child: Text('技能/资格教育(300元/月)',style: TextStyle(fontSize: 14),),
                onPressed: (){
                  setState(() {
                    continueEducationValue = 300;
                  });
                }
            ),
          ),
        ],
      ),
    );
  }
  ///大病支出
  Widget _getSerious(){
    return Container(
      color:Colors.white,
      padding: EdgeInsets.all(10),
      child: Row(
        children: <Widget>[
          Text('大病支出(元)：',style: TextStyle(fontSize: 16,color: Color(AppColors.appThemeColor)),),
          Flexible(
              child: Container(
                margin: EdgeInsets.fromLTRB(20, 0, 20, 0),
                padding: EdgeInsets.all(3),
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
                      hintText: '请输入金额(限1.5万以上/年)'
                  ),
                  onChanged: (text){
                    if(text.length > 0){
                      double temp = double.tryParse(text);
                      if(temp == null){
                        _showNoticeDialog('请输入正确的金额', 999);
                      }else{
                        if(temp < 15000){
                          seriousValue = 0;
                        }else if(temp >= 15000 && temp <=80000){
                          seriousValue = temp;
                        }else{
                          seriousValue = 80000;
                        }
                      }
                    }else{
                        seriousValue = 0;
                    }
                  },
            ),
          ))
        ],
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      backgroundColor: Color(AppColors.grey),
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
          centerTitle:true
      ),
      body:ListView(
        children: <Widget>[
          _payMonth(),
          _getTitleItem('五险一金'),
          _getFiveAndOne(),
          _getTitleItem('住房支出'),
          _getHouseLoans(),
          _getTitleItem('子女教育'),
          _getEducation(),
          _getTitleItem('赡养老人(60周岁以上)'),
          _getOldMan(),
          _getTitleItem('继续教育'),
          _getContinuingEducation(),
          _getTitleItem('大病支出'),
          _getSerious(),
          Container(
            alignment: Alignment.centerRight,
            margin: EdgeInsets.fromLTRB(40, 5, 20, 5),
            child: SizedBox(
              width: 220,
              child: CheckboxListTile(
                  title:Text('大病医疗按月扣除'),
                  selected:seriousByMonth,
                  value: seriousByMonth,
                  onChanged: (bool check){
                    setState(() {
                      seriousByMonth = check;
                    });
                  }),
            ),
          ),
          Container(
            padding: EdgeInsets.all(5),
            margin: EdgeInsets.fromLTRB(40, 5, 40, 40),
            decoration: BoxDecoration(
                color:Color(AppColors.appThemeColor),
                borderRadius: BorderRadius.all(Radius.circular(3))
            ),
            child: CupertinoButton(
              disabledColor: Colors.grey,
              color: Color(AppColors.appThemeColor),
              pressedOpacity: 0.9,
              borderRadius: BorderRadius.all(Radius.circular(3)),
              padding: EdgeInsets.all(1),
              child:Text('计算',style: TextStyle(color: Colors.white,fontSize: 16,),),
              ///  onPressed为null，按钮就会自动不能点击
              onPressed: ()=>_onCalculate(),
            ),
          ),
        ],
      )
    );
  }
}
