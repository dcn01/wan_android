import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:multi_image/entity/home_article_entity.dart';
import 'package:multi_image/http/HttpRequest.dart';
import 'package:shimmer/shimmer.dart';
import 'package:multi_image/event/LoginEvent.dart';

import '../../Api.dart';
import '../../r.dart';
import '../BrowserPage.dart';
import '../../main.dart';

class ProjectListFragment extends StatefulWidget {
  int _Id;

  ProjectListFragment(this._Id);

  @override
  State<StatefulWidget> createState() {
    return ProjectListFragmentState(_Id);
  }
}

class ProjectListFragmentState extends State<ProjectListFragment>
    with AutomaticKeepAliveClientMixin {
  int _Id;
  int currentPage = 0; //第一页
  List<HomeArticleEntity> articleList = new List();

  ProjectListFragmentState(this._Id);

  @override
  void initState() {
    super.initState();
    eventBus.on<LoginOutEvent>().listen((event) async { // 监听退出登录事件 退出登录就重新刷新数据
        articleList.clear();
        currentPage = 0;
        await loadArticleData();
        setState(() {
        });
    });
    loadArticleData();
  }

  //  加载文章
  loadArticleData() async {
    var params = {"cid":_Id};
    HttpRequest.getInstance().get("${Api.PROJECT_LIST}$currentPage/json",data: params,
        successCallBack: (data) {
      Map<String, dynamic> dataJson = json.decode(data);
      List responseJson = json.decode(json.encode(dataJson["datas"]));
      List<HomeArticleEntity> cardbeanList =
          responseJson.map((m) => new HomeArticleEntity.fromJson(m)).toList();
      setState(() {
        articleList.addAll(cardbeanList);
      });
    }, errorCallBack: (code, msg) {});
  }

  @override
  Widget build(BuildContext context) {
    return articleList.length == 0?  showLoadding() :
      EasyRefresh(
      child: ListView.builder(
          itemCount: articleList.length,
          itemBuilder: (context, index) {
            return renderRow(index, context);
          }),
//      header: MaterialHeader(),
//      footer: MaterialFooter(),
      onRefresh: () async {
        articleList.clear();
        currentPage = 0;
        loadArticleData();
      },
      onLoad: () async {
        currentPage++;
        loadArticleData();
      },
    );
  }

  Widget showLoadding(){
    return Shimmer.fromColors(
      baseColor: Colors.grey[300],
      highlightColor: Colors.grey[100],
      child: Column(
        children: [0, 1, 2, 3, 4, 5, 6]
            .map((_) => new Column(
          children: <Widget>[
            new Container(
              margin: EdgeInsets.all(ScreenUtil.getInstance().setWidth(45)),
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  new Row(
                    children: <Widget>[
                      Container(
                        width: ScreenUtil.getInstance().setWidth(180),
                        height: ScreenUtil.getInstance().setWidth(45),
                        color: Colors.white,
                      ),
                      new Expanded(
                          child: Container()
                      ),
                      Container(
                        width: ScreenUtil.getInstance().setWidth(170),
                        height: ScreenUtil.getInstance().setWidth(45),
                        color: Colors.white,
                      )
                    ],
                  ),
                  new Divider(
                    height: ScreenUtil.getInstance().setWidth(30),
                    color: Colors.transparent,
                  ),
                  new Row(
                    children: <Widget>[
                      Container(
                        width:  ScreenUtil.getInstance().setWidth(330),
                        height: ScreenUtil.getInstance().setWidth(220),
                        color: Colors.white,
                        margin: EdgeInsets.only(right: ScreenUtil.getInstance().setWidth(30)),
                      ),
                      new Expanded(
                        child: new Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              height: ScreenUtil.getInstance().setWidth(47),
                              color: Colors.white,
                            ),
                            Container(
                              margin: EdgeInsets.only(top: ScreenUtil.getInstance().setWidth(15)),
                              height: ScreenUtil.getInstance().setWidth(150),
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  new Divider(
                    height: ScreenUtil.getInstance().setWidth(30),
                    color: Colors.transparent,
                  ),
                  Container(
                    width:  ScreenUtil.getInstance().setWidth(300),
                    height: ScreenUtil.getInstance().setWidth(45),
                    color: Colors.white,
                  ),
                ],
              ),
            ),
            //分割线
            new Divider(height: 1)
          ],
        ))
            .toList(),
      ),
    );
  }

  //列表的item
  renderRow(index, context) {
    var article = articleList[index];
    return new Container(
        child: new InkWell(
          onTap: () => {
            Navigator.of(context).push(new MaterialPageRoute(builder: (_) {
              return new Browser(
                url: article.link,
                title: article.title,
                id: article.id,
              );
            }))
          },
          child: new Column(
            children: <Widget>[
              new Container(
                margin: EdgeInsets.all(ScreenUtil.getInstance().setWidth(45)),
                child: new Column(
                  children: <Widget>[
                    new Row(
                      children: <Widget>[
                        new Expanded(
                          child: new Text(
                            article.author,
                            style: new TextStyle(
                                fontSize: ScreenUtil.getInstance().setSp(35),
                                color: const Color(0xFF6e6e6e)),
                          ),
                        ),
                        new Text(
                          article.niceDate,
                          style: new TextStyle(
                              fontSize: ScreenUtil.getInstance().setSp(35),
                              color: const Color(0xFF999999)),
                        )
                      ],
                    ),
                    new Divider(
                      height: ScreenUtil.getInstance().setWidth(30),
                      color: Colors.transparent,
                    ),
                    new Row(
                      children: <Widget>[
                        article.envelopePic != ""
                            ? new Container(
                                child: new Image(
                                    image: NetworkImage(article.envelopePic),
                                    width:
                                        ScreenUtil.getInstance().setWidth(330),
                                    fit: BoxFit.fitWidth,
                                    height:
                                        ScreenUtil.getInstance().setWidth(220)),
                                margin: EdgeInsets.only(
                                    right:
                                        ScreenUtil.getInstance().setWidth(30)),
                              )
                            : new Container(),
                        new Expanded(
                          child: new Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              new Text(
                                article.title,
                                softWrap: false,
                                //是否自动换行 false文字不考虑容器大小  单行显示   超出；屏幕部分将默认截断处理
                                overflow: TextOverflow.ellipsis,
                                //文字超出屏幕之后的处理方式  TextOverflow.clip剪裁   TextOverflow.fade 渐隐  TextOverflow.ellipsis省略号
                                style: new TextStyle(
                                    fontSize:
                                        ScreenUtil.getInstance().setSp(40),
                                    color: Color(0xFF333333)),
                              ),
                              new Text(
                                article.desc,
                                softWrap: false,
                                maxLines: 3,
                                textAlign: TextAlign.start,
                                //文本对齐方式  居中
                                //是否自动换行 false文字不考虑容器大小  单行显示   超出；屏幕部分将默认截断处理
                                overflow: TextOverflow.ellipsis,
                                //文字超出屏幕之后的处理方式  TextOverflow.clip剪裁   TextOverflow.fade 渐隐  TextOverflow.ellipsis省略号
                                style: new TextStyle(
                                    fontSize:
                                        ScreenUtil.getInstance().setSp(35),
                                    color: Color(0xFF999999)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    new Divider(
                      height: ScreenUtil.getInstance().setWidth(30),
                      color: Colors.transparent,
                    ),
                    new Row(
                      children: <Widget>[
                        new Text(
                          article.superChapterName,
                          style: new TextStyle(
                              fontSize: ScreenUtil.getInstance().setSp(35),
                              color: const Color(0xFF999999)),
                        ),
                        new Text(" • ",
                            style: new TextStyle(
                                fontSize: ScreenUtil.getInstance().setSp(35),
                                color: const Color(0xFF999999))),
                        new Expanded(
                          child: new Text(article.chapterName,
                              style: new TextStyle(
                                  fontSize: ScreenUtil.getInstance().setSp(35),
                                  color: const Color(0xFF999999))),
                        ),
                        new GestureDetector(
                          onTap: () => {
                            HttpRequest.getInstance().post(
                                article.collect == false
                                    ? "${Api.COLLECT}${article.id}/json"
                                    : "${Api.UN_COLLECT_ORIGIN_ID}${article.id}/json",
                                successCallBack: (data) {
                                  setState(() {
                                    article.collect = !article.collect;
                                  });
                                }, errorCallBack: (code, msg) {},context: context)
                          },
                          child: new Image(
                            image: article.collect == false
                                ? AssetImage(R.assetsImgZan0)
                                : AssetImage(R.assetsImgZan1),
                            width: ScreenUtil.getInstance().setWidth(66),
                            height: ScreenUtil.getInstance().setWidth(66),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
              //分割线
              new Divider(height: 1)
            ],
          ),
        ));
  }

  @override
  bool get wantKeepAlive => true;
}
