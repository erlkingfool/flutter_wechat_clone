import 'package:flutter/material.dart';
import 'package:flutter_wechat_clone/routers/application.dart';
import '../constants.dart' show AppColors, AppStyles, Constants;
import '../model/conversation.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../provide/websocket.dart';
import 'package:provider/provider.dart';

//SECTION 微信-对话页面:对应flutter_wechat  message_page.dart

class _ConversationItem extends StatelessWidget {
  const _ConversationItem(
      {required this.conversation, required this.index, required this.type});
  final int index;
  final int type;
  final Conversation conversation; //对话

  @override
  Widget build(BuildContext context) {
    Widget avatar; //头像
    if (conversation.isAvatarFromNet()) {
      //网络图片
      avatar = CachedNetworkImage(
        //缓存图片
        imageUrl: conversation.avatar,
        placeholder: (context, msg) =>
            Constants.ConversationAvatarDefaultIocn, //占位图片
        width: Constants.ConversationAvatarSize,
        height: Constants.ConversationAvatarSize,
      );
    } else {
      //本地图片
      avatar = Image.asset(
        conversation.avatar,
        width: Constants.ConversationAvatarSize,
        height: Constants.ConversationAvatarSize,
      );
    }
    //头像包裹
    Widget avatarContainer;
    if (conversation.unreadMsgCount > 0) {
      //如果有没读消息,则添加角标.

      // 未读消息角标
      Widget unreadMsgCountText = Container(
        width: Constants.UnReadMsgNotifyDotSize,
        height: Constants.UnReadMsgNotifyDotSize,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius:
              BorderRadius.circular(Constants.UnReadMsgNotifyDotSize / 2.0),
          color: AppColors.NotifyDotBgColor,
        ),
        child: Text(conversation.unreadMsgCount.toString(),
            style: AppStyles.UnreadMsgCountDotStyle),
      );

      avatarContainer = Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          avatar,
          Positioned(
            right: -6.0,
            top: -6.0,
            child: unreadMsgCountText,
          )
        ],
      );
    } else {
      avatarContainer = avatar;
    }

    Color muteIconColor;
    if (conversation.isMute) {
      //是否是mute
      muteIconColor = AppColors.ConversationMuteIconColor;
    } else {
      muteIconColor = Colors.transparent; //透明
    }

    //勿扰模式图标
    Widget muteContainer = Container(
      margin: const EdgeInsets.only(top: 10.0),
      child: Icon(
        IconData(
          0xe78b, //勿扰图标代码
          fontFamily: Constants.IconFontFamily,
        ),
        color: muteIconColor,
        size: Constants.ConversationMuteIcon,
      ),
    );
    //右侧区域
    var _rightArea = <Widget>[
      Text(conversation.updateAt, style: AppStyles.DescStyle), //更新时间
      muteContainer //静音
    ];

    var tapPos;

    //返回一个message条目
    return Container(
      child: InkWell(
        onTap: () {
          print('打开会话:${conversation.title}');
          Application.router
              .navigateTo(context, '/chatdetail?index=$index&type=$type');
        },
        onTapDown: (TapDownDetails details) {
          tapPos = details.globalPosition;
        },
        onLongPress: () {
          _showMenu(context, tapPos);
          print('弹出会话菜单:${conversation.title}');
        },
        child: Container(
          padding: const EdgeInsets.all(10.0),
          decoration: BoxDecoration(
              color: AppColors.ConversationItemBgColor,
              border: Border(
                  bottom: BorderSide(
                      color: AppColors.DividerColor,
                      width: Constants.DividerWidth))),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              avatarContainer, //头像
              Container(width: 10.0), //设置了间隔?
              Expanded(
                //中间消息内容
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(conversation.title, style: AppStyles.TitleStyle), //标题
                    Text(conversation.desc, style: AppStyles.DescStyle) //内容
                  ],
                ),
              ),
              Container(width: 10.0), //设置了间隔?
              Column(
                children: _rightArea, //右侧区域
              )
            ],
          ),
        ),
      ),
    );
  }

  _showMenu(BuildContext context, Offset tapPos) {
    final RenderBox? overlay = Overlay.of(context)!.context.findRenderObject()
        as RenderBox?; //!我修改为as转换

    final RelativeRect position = RelativeRect.fromLTRB(tapPos.dx, tapPos.dy,
        overlay!.size.width - tapPos.dx, overlay.size.height - tapPos.dy);
    showMenu<String>(
        context: context,
        position: position,
        items: <PopupMenuItem<String>>[
          PopupMenuItem(
            child: Text(Constants.MENU_MARK_AS_UNREAD_VALUE),
            value: Constants.MENU_MARK_AS_UNREAD,
          ),
          PopupMenuItem(
            child: Text(Constants.MENU_PIN_TO_TOP_VALUE),
            value: Constants.MENU_PIN_TO_TOP,
          ),
          PopupMenuItem(
            child: Text(Constants.MENU_DELETE_CONVERSATION_VALUE),
            value: Constants.MENU_DELETE_CONVERSATION,
          ),
        ]).then<String?>((String? selected) {
      switch (selected) {
        default:
          print('当前选中的是：$selected');
      }
    });
  }
}

//顶部**微信已经登录,手机通知已关闭
class _DeviceInfoItem extends StatelessWidget {
  const _DeviceInfoItem({required this.device});
  final Device device;

  int get iconName {
    return device == Device.WIN ? 0xe72a : 0xe640; //iconName
  }

  String get deviceName {
    return device == Device.WIN ? "Windows" : "Mac";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          EdgeInsets.only(left: 24.0, top: 10.0, right: 24.0, bottom: 10.0),
      decoration: BoxDecoration(
          border: Border(
        bottom: BorderSide(
          width: Constants.DividerWidth,
          color: AppColors.DividerColor,
        ),
      )),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Icon(
            IconData(this.iconName,
                fontFamily: Constants.IconFontFamily), //windows or mac icon
            size: 24.0,
            color: AppColors.DeviceInfoItemIconColor,
          ),
          SizedBox(width: 16.0),
          Text('$deviceName 微信已登录，手机通知已关闭。',
              style: AppStyles.DeviceInfoItemTextStyle)
        ],
      ),
    );
  }
}

//这是原版flutter_wechat_clone
class ConversationPage extends StatefulWidget {
  @override
  _ConversationPageState createState() => _ConversationPageState();
}

class _ConversationPageState extends State<ConversationPage> {
  final ConversationPageData data = ConversationPageData.mock(); //!
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemBuilder: (BuildContext context, int index) {
        if (data.device != null) {
          //需要显示其他设备的登录信息
          if (index == 0) {
            return _DeviceInfoItem(device: data.device!);
          } else {
            return _ConversationItem(
                conversation: data.conversations[index - 1],
                index: index - 1,
                type: 0);
          }
        } else {
          return _ConversationItem(
              conversation: data.conversations[index], index: index, type: 1);
        }
      },
      itemCount: data.device != null
          ? data.conversations.length + 1
          : data.conversations.length,
    );
  }
}

//这是flutter_wechat定义
class MessagePage extends StatelessWidget {
  final ConversationPageData data = ConversationPageData.mock(); //!

  @override
  Widget build(BuildContext context) {
    return Consumer<WebSocketProvide>(builder: (context, child, val) {
      //!
      var messageList = Provider.of<WebSocketProvide>(context, listen: false)
          .messageList; //!服务器数据,flutter交流群
      var length = data.conversations.length + 1 + messageList.length;
      print('数据个数:$length');
      return Container(
          child: ListView.builder(
        itemBuilder: (BuildContext context, int index) {
          if (index == 0) {
            //登录信息
            return _DeviceInfoItem(device: data.device!);
          } else if (index < data.conversations.length + 1) {
            //模拟数据
            return _ConversationItem(
                conversation: data.conversations[index - 1],
                index: index - 1,
                type: 0); //tpye0为模拟数据
          } else {
            var inde = index - 1 - data.conversations.length;
            return _ConversationItem(
                conversation: messageList[inde],
                index: inde,
                type: 1); //!type1:服务器数据flutter 交流群
          }
        },
        itemCount: length,
      ));
    });
  }
}
