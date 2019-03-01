import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:income_tax_calculation/AppColors.dart';
import 'package:income_tax_calculation/CustomListDialog.dart';
import 'package:income_tax_calculation/CustomNoticeDialog.dart';
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
  final List<String> itemList = ['月薪资','五险一金','子女教育','继续教育','住房贷款利息','住房租金','赡养老人','大病医疗'];
  final double baseTax = 5000;
  double houseValue=0;//公积金值
  double socialValue=0;//社保值
  double houseLoansValue=0;//住房支出，贷款1000，租房分为1500、1100、800
  List<String> value= ['','','','','','','',''];
  List<double> valueDouble=[0,0,0,0,0,0,0,0];
  InputDecoration inputDecoration;
  List<double> preTaxList=[0,0,0,0,0,0,0,0,0,0,0,0];//预缴默认税款，
  double preUpTaxValue = 0;//预缴税本金
  bool seriousByMonth = true;
  String seriousValue='';//保存大病医疗的输入值，因为大病医疗分为两种情况计算，
  String childNum='';

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
              value[index] = '';
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
          if(index != -1 && index != -2){
            setState(() {
              value[index] = '';
              if(index == itemList.length -1){
                seriousValue='';
              }
            });
          }else if(index == -2){
            setState(() {
              childNum = '';
            });
          }
        },
      );
    });
  }
//上一年度的大病医疗实时扣除
  void _onCalculate(){
    if(value[0].isEmpty){
      _showNoticeDialog('月工资是必填项',-1);
      return;
    }
    double count=0;
    if(seriousByMonth){//大病医疗按月扣除
        if(double.tryParse(value[value.length-1]) != null){
          value[value.length-1] = (double.tryParse(seriousValue)/12).toString();
        }else{
          value[value.length-1] = '0';
        }
        print('每月大病疗 = ${value[value.length-1]}');
        double need = 0;
        for(int i=0;i<value.length;i++){
          if(i == 0){
            need = double.tryParse(value[i]) == null ? 0 :double.tryParse(value[i]) - baseTax;
          }else{
            need -= (double.tryParse(value[i]) == null ? 0 :double.tryParse(value[i]));
          }
          print('need = $need');
        }


        for(int i=0;i<12;i++){
          double temp = _calculateMonth(need,i+1);
          print('${i+1}月：$temp 元');
          preTaxList[i] = temp;//循环是直接从第一个月到12月，所以一次添加每个月的扣税金额即可
          count+=temp;
        }
    }else{
      double need = 0;
      bool seriousOver = false;
      value[itemList.length-1] = seriousValue;
      for(int i=0;i<value.length;i++){
        if(i == 0){
          need = double.tryParse(value[i]) == null ? 0 :double.tryParse(value[i]) -baseTax;
        }else{
          need -= (double.tryParse(value[i]) == null ? 0 :double.tryParse(value[i]));
        }
      }
      if(need <= 0){//说明大病医疗还有剩余的没有扣除
        value[value.length-1] = need.abs().toString();
        seriousOver = false;
      }else{
        seriousOver = true;
        value[value.length-1] = '0';
      }
      int noUpTaxMonth = 0;
      for(int i=0;i<12;i++){
        print('need=$need');
        if(seriousOver){
          double temp = _calculateMonth(need,i+1-noUpTaxMonth);
          print('${i+1}月缴税：$temp 元,缴税本金：${need*(i+1-noUpTaxMonth)}元 ${i+1-noUpTaxMonth}，剩余大病医疗保险：${value[value.length-1]}元');
          preTaxList[i] = temp;//循环是直接从第一个月到12月，所以一次添加每个月的扣税金额即可
          count+=temp;
          for(int i=0;i<value.length;i++){
            if(i == 0){
              need = double.tryParse(value[i]) == null ? 0 :double.tryParse(value[i]) -baseTax;
            }else{
              need -= (double.tryParse(value[i]) == null ? 0 :double.tryParse(value[i]));
            }
          }
        }else{
          noUpTaxMonth++;
          double temp = _calculateMonth(0,i+1);
          print('${i+1}月缴税：$temp 元,缴税本金：0元，剩余大病医疗保险：${value[value.length-1]}元');
          preTaxList[i] = temp;//循环是直接从第一个月到12月，所以一次添加每个月的扣税金额即可
          count+=temp;

          //重新计算need，直到大病医疗没有剩余
          for(int i=0;i<value.length;i++){
            if(i == 0){
              need = double.tryParse(value[i]) == null ? 0 :double.tryParse(value[i]) -baseTax;
            }else{
              need -= (double.tryParse(value[i]) == null ? 0 :double.tryParse(value[i]));
            }
          }
          if(need <= 0){//说明大病医疗还有剩余的没有扣除
            value[value.length-1] = need.abs().toString();
            seriousOver = false;
          }else{
            value[value.length-1] = '0';
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
  Widget _payMonth(int index){
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
              controller: TextEditingController(text: index == itemList.length-1 ? seriousValue :value[index]) ,
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
                    _showNoticeDialog('请输入正确金额!',index);
                  }else{
                    value[index] = text;
                    if(index == itemList.length-1){
                      seriousValue = text;
                    }
                  }
                }else{
                  value[index] = '';

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
                child: Text('编辑',style: TextStyle(fontSize: 14),),
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
               margin: EdgeInsets.fromLTRB(30, 0, 30, 0),
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
                    controller: TextEditingController(text: childNum) ,
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
                          _showNoticeDialog('请输入正确的数量',-2);
                        }else{
                          ///TODO
                        }
                      }
                    },
                ),
              ),
            ),
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
          _payMonth(0),
          _getTitleItem('五险一金'),
          _getFiveAndOne(),
          _getTitleItem('住房支出'),
          _getHouseLoans(),
          _getTitleItem('子女教育'),
          _getEducation(),
          _getTitleItem('赡养老人'),
          _getTitleItem('继续教育'),
          _getTitleItem('大病支出'),
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
//                      double temp = double.tryParse(value[value.length-1]);
//                      if(temp == null){
//                        value[value.length-1] = '0';
//                      }else{
//                        value[value.length-1] = (temp*12).toString();
//                      }
                    });
                  }),
            ),
          ),
          Container(
            padding: EdgeInsets.all(5),
            margin: EdgeInsets.fromLTRB(40, 5, 40, 5),
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
