import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:multi_image/Api.dart';
import 'package:multi_image/entity/gongzh_entity.dart';
import 'package:multi_image/http/HttpRequest.dart';

import 'GongzhListFragment.dart';

class GongzhFragment extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new GongzhFragmentState();
  }
}

class GongzhFragmentState extends State<GongzhFragment>
    with SingleTickerProviderStateMixin {
  TabController mTabController;
  List<GongzhEntity> datas = [];
  int index = 0;
  var mPageController = new PageController(initialPage: 0);
  var isPageCanChanged = true;

  //  获取首页banner
  void getData() async {
    HttpRequest.getInstance().get(Api.WXARTICLE_CHAPTERS, data: null,
        successCallBack: (data) {
      List responseJson = json.decode(data);
      setState(() {
        datas = responseJson.map((m) => new GongzhEntity.fromJson(m)).toList();
        //initialIndex初始选中第几个
        mTabController =
            TabController(initialIndex: 0, length: datas.length, vsync: this);
        mTabController.addListener(() {
          if (mTabController.indexIsChanging) {
            //判断TabBar是否切换
            onPageChange(mTabController.index, p: mPageController);
          }
        });
      });
    }, errorCallBack: (code, msg) {});
  }

  List<Tab> getTabs() {
    List<Tab> temps = [];
    for (var i = 0; i < datas.length; i++) {
      temps.add(Tab(
        text: datas[i].name,
      ));
    }
    return temps;
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  onPageChange(int index, {PageController p, TabController t}) async {
    if (p != null) {
      //判断是哪一个切换
      isPageCanChanged = false;
      await mPageController.animateToPage(index,
          duration: Duration(milliseconds: 500),
          curve: Curves.ease); //等待pageview切换完毕,再释放pageivew监听
      isPageCanChanged = true;
    } else {
      mTabController.animateTo(index); //切换Tabbar
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // backgroundColor: Color(0xff4282f4),
        centerTitle: true,
        title: datas.length == 0
            ? Text("加载中..")
            : TabBar(
                controller: mTabController,
                //可以和TabBarView使用同一个TabController
                tabs: getTabs(),
                isScrollable: true,
                indicatorColor: Colors.transparent,
                indicatorWeight: 1,
                indicatorSize: TabBarIndicatorSize.tab,
                indicatorPadding: EdgeInsets.only(bottom: 10.0),
                labelPadding: EdgeInsets.only(left: 20),
                labelColor: Colors.white,
                labelStyle: TextStyle(
                  fontSize: ScreenUtil.getInstance().setSp(45),
                ),
                unselectedLabelColor: Color(0x90ffffff),
                unselectedLabelStyle: TextStyle(
                  fontSize: ScreenUtil.getInstance().setSp(45),
                ),
              ),
      ),
      body: new PageView.builder(
        onPageChanged: (index) {
          if (isPageCanChanged) {
            //由于pageview切换是会回调这个方法,又会触发切换tabbar的操作,所以定义一个flag,控制pageview的回调
            onPageChange(index);
          }
        },
        controller: mPageController,
        itemBuilder: (BuildContext context, int index) {
          return new GongzhListFragment(datas[index].id);
        },
        itemCount: datas.length,
      ),
    );
  }
}
