import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:multi_image/Api.dart';
import 'package:multi_image/entity/system_entity.dart';
import 'package:multi_image/http/HttpRequest.dart';
import 'package:multi_image/page/System/SystemDetailPage.dart';

//体系-》体系
class SystemChildFragment extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new SystemChildFragmentState();
  }
}

class SystemChildFragmentState extends State<SystemChildFragment>
    with AutomaticKeepAliveClientMixin {
  List<SystemEntity> dataList = [];

  @override
  void initState() {
    getData();
    super.initState();
  }

//  获取数据
  void getData() async {
    HttpRequest.getInstance().get(Api.TREE, successCallBack: (data) {
      print(data);
      List responseJson = json.decode(data);
      setState(() {
        dataList =
            responseJson.map((m) => new SystemEntity.fromJson(m)).toList();
      });
    }, errorCallBack: (code, msg) {});
  }

  ///添加子项
  ///pEntity 父项
  ///index 子项在父项中的位置
  ///entity 子项
  List<Widget> getChild(SystemEntity pEntity, int index, SystemEntity entity) {
    List<Widget> children = [];
    if (entity.children.length > 0) {
      children.add(new Row(
        children: <Widget>[
          new Text(
            entity.name,
            style: TextStyle(fontSize: ScreenUtil.getInstance().setSp(40)),
          )
        ],
      ));
      for (int i = 0; i < entity.children.length; i++) {
        children.addAll(getChild(entity, i, entity.children[i]));
      }
    } else {
      children.add(new InkWell(
        onTap: () => {
          Navigator.of(context).push(new MaterialPageRoute(builder: (_) {
            return new SystemDetailPage(pEntity, index);
          }))
        },
        child: new Container(
            padding: EdgeInsets.fromLTRB(
                ScreenUtil.getInstance().setWidth(50),
                ScreenUtil.getInstance().setWidth(20),
                ScreenUtil.getInstance().setWidth(50),
                ScreenUtil.getInstance().setWidth(20)),
            decoration: new BoxDecoration(
              border: new Border.all(color: Colors.transparent, width: 1),
              // 边色与边宽度
              color: Color(0xFFf5f5f5),
              borderRadius: new BorderRadius.circular(
                  (ScreenUtil.getInstance().setWidth(50))), // 圆角度
            ),
            child: new Text(
              entity.name,
              textAlign: TextAlign.center,
              style: new TextStyle(
                  fontSize: ScreenUtil.getInstance().setSp(36),
                  color: const Color(0xFF999999)),
            )),
      ));
    }
    return children;
  }

  List<Widget> getChildren() {
    List<Widget> children = [];
    for (int i = 0; i < dataList.length; i++) {
      children.addAll(getChild(null, i, dataList[i]));
    }
    return children;
  }

  @override
  Widget build(BuildContext context) {
    return
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
        ),
        child:  SingleChildScrollView(
          padding: EdgeInsets.all(ScreenUtil.getInstance().setWidth(45)),
          child: Wrap(
            /**
             * 这里区分一下主轴和纵轴的概念：
             * 当水平方向的时候，其主轴就是水平，纵轴就是垂直。
             * 当垂直方向的时候，其主轴就是垂直，纵轴就是水平。
             *
             */
            direction: Axis.horizontal,
            //不设置默认为horizontal
            alignment: WrapAlignment.start,
            //沿主轴方向居中
            spacing: 10.0,
            //主轴（水平）方向间距
            runSpacing: 10.0,
            //纵轴（垂直）方向间距
            children: getChildren(),
          ),
        ) ,
      )
    ;
  }

  @override
  bool get wantKeepAlive => true;
}
