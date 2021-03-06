import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';
import 'package:uuid/uuid.dart';

class FakeWechatScope {
  FakeWechatScope._();

  /// 只能获取openId
  static const String SNSAPI_BASE = 'snsapi_base';

  /// 能获取openId和用户基本信息
  static const String SNSAPI_USERINFO = 'snsapi_userinfo';
}

class FakeWechatBizProfileType {
  FakeWechatBizProfileType._();

  /// 普通公众号
  static const int NORMAL = 0;

  /// 硬件公众号
  static const int DEVICE = 1;
}

class FakeWechatScene {
  FakeWechatScene._();

  /// 聊天界面
  static const int SESSION = 0;

  /// 朋友圈
  static const int TIMELINE = 1;

  /// 收藏
  static const int FAVORITE = 2;
}

class FakeWechatMPWebviewType {
  FakeWechatMPWebviewType._();

  /// 广告网页
  static const int AD = 0;
}

class FakeWechatErrorCode {
  FakeWechatErrorCode._();

  /// 成功
  static const int SUCCESS = 0;

  /// 普通错误类型
  static const int ERRORCODE_COMMON = -1;

  /// 用户点击取消并返回
  static const int ERRORCODE_USERCANCEL = -2;

  /// 发送失败
  static const int ERRORCODE_SENTFAIL = -3;

  /// 授权失败
  static const int ERRORCODE_AUTHDENY = -4;

  /// 微信不支持
  static const int ERRORCODE_UNSUPPORT = -5;
}

class FakeWechatQrauthErrorCode {
  FakeWechatQrauthErrorCode._();

  /// Auth成功
  static const int ERROR_OK = 0;

  /// 普通错误
  static const int ERROR_NORMAL = -1;

  /// 网络错误
  static const int ERROR_NETWORK = -2;

  /// 获取二维码失败
  static const int ERROR_GETQRCODEFAILED = -3;

  /// 用户取消授权
  static const int ERROR_CANCEL = -4;

  /// 超时
  static const int ERROR_TIMEOUT = -5;
}

abstract class FakeWechatBaseResp {
  FakeWechatBaseResp({
    @required this.errorCode,
    @required this.errorMsg,
  });

  /// 错误码
  final int errorCode;

  /// 错误提示字符串
  final String errorMsg;
}

class FakeWechatAuthResp extends FakeWechatBaseResp {
  FakeWechatAuthResp._({
    @required int errorCode,
    @required String errorMsg,
    this.code,
    this.state,
    this.lang,
    this.country,
  }) : super(errorCode: errorCode, errorMsg: errorMsg);

  final String code;
  final String state;
  final String lang;
  final String country;
}

class FakeWechatOpenUrlResp extends FakeWechatBaseResp {
  FakeWechatOpenUrlResp._({
    @required int errorCode,
    @required String errorMsg,
  }) : super(errorCode: errorCode, errorMsg: errorMsg);
}

class FakeWechatOpenChatResp extends FakeWechatBaseResp {
  FakeWechatOpenChatResp._({
    @required int errorCode,
    @required String errorMsg,
  }) : super(errorCode: errorCode, errorMsg: errorMsg);
}

class FakeWechatOpenRankListResp extends FakeWechatBaseResp {
  FakeWechatOpenRankListResp._({
    @required int errorCode,
    @required String errorMsg,
  }) : super(errorCode: errorCode, errorMsg: errorMsg);
}

class FakeWechatShareMsgResp extends FakeWechatBaseResp {
  FakeWechatShareMsgResp._({
    @required int errorCode,
    @required String errorMsg,
  }) : super(errorCode: errorCode, errorMsg: errorMsg);
}

class FakeWechatSubscribeMsgResp extends FakeWechatBaseResp {
  FakeWechatSubscribeMsgResp._({
    @required int errorCode,
    @required String errorMsg,
    this.templateId,
    this.scene,
    this.action,
    this.reserved,
    this.openId,
  }) : super(errorCode: errorCode, errorMsg: errorMsg);

  final String templateId;
  final int scene;
  final String action;
  final String reserved;
  final String openId;
}

class FakeWechatLaunchMiniProgramResp extends FakeWechatBaseResp {
  FakeWechatLaunchMiniProgramResp._({
    @required int errorCode,
    @required String errorMsg,
    this.extMsg,
  }) : super(errorCode: errorCode, errorMsg: errorMsg);

  final String extMsg;
}

class FakeWechatPayResp extends FakeWechatBaseResp {
  FakeWechatPayResp._({
    @required int errorCode,
    @required String errorMsg,
    this.returnKey,
  }) : super(errorCode: errorCode, errorMsg: errorMsg);

  final String returnKey;
}

abstract class FakeWechatApiResp {
  FakeWechatApiResp({
    @required this.errorCode,
    @required this.errorMsg,
  });

  /// 成功
  static const int SUCCESS = 0;

  static const String KEY_ERRORCODE = 'errcode';
  static const String KEY_ERRORMSG = 'errmsg';

  static const String KEY_OPENID = 'openid';
  static const String KEY_SCOPE = 'scope';

  static const String KEY_ACCESS_TOKEN = 'access_token';
  static const String KEY_REFRESH_TOKEN = 'refresh_token';
  static const String KEY_EXPIRES_IN = 'expires_in';

  static const String KEY_NICKNAME = 'nickname';
  static const String KEY_SEX = 'sex';
  static const String KEY_PROVINCE = 'province';
  static const String KEY_CITY = 'city';
  static const String KEY_COUNTRY = 'country';
  static const String KEY_HEADIMGURL = 'headimgurl';
  static const String KEY_PRIVILEGE = 'privilege';
  static const String KEY_UNIONID = 'unionid';

  /// -1	    系统繁忙，此时请开发者稍候再试
  /// 0       请求成功
  /// 40001	  AppSecret错误或者AppSecret不属于这个公众号，请开发者确认AppSecret的正确性
  /// 40002	  请确保grant_type字段值为client_credential
  /// 40164	  调用接口的IP地址不在白名单中，请在接口IP白名单中进行设置。（小程序及小游戏调用不要求IP地址在白名单内。）
  final int errorCode;
  final String errorMsg;
}

class FakeWechatAccessToken extends FakeWechatApiResp {
  FakeWechatAccessToken._({
    @required int errorCode,
    @required String errorMsg,
    this.accessToken,
    this.expiresIn,
  }) : super(errorCode: errorCode, errorMsg: errorMsg);

  final String accessToken;

  /// 单位：秒
  final int expiresIn;
}

class FakeWechatTicket extends FakeWechatApiResp {
  FakeWechatTicket._({
    @required int errorCode,
    @required String errorMsg,
    this.ticket,
    this.expiresIn,
  }) : super(errorCode: errorCode, errorMsg: errorMsg);

  static const String KEY_TICKET = 'ticket';

  final String ticket;

  /// 单位：秒
  final int expiresIn;
}

class FakeWechatQrauthResp {
  FakeWechatQrauthResp._({
    @required this.errorCode,
    @required this.authCode,
  });

  final int errorCode;
  final String authCode;
}

class FakeWechatUnionIDAccessToken extends FakeWechatApiResp {
  FakeWechatUnionIDAccessToken._({
    @required int errorCode,
    @required String errorMsg,
    this.openId,
    this.scope,
    this.accessToken,
    this.refreshToken,
    this.expiresIn,
  }) : super(errorCode: errorCode, errorMsg: errorMsg);

  final String openId;
  final String scope;
  final String accessToken;
  final String refreshToken;

  /// 单位：秒
  final int expiresIn;
}

class FakeWechatUnionIDUserInfo extends FakeWechatApiResp {
  FakeWechatUnionIDUserInfo._({
    @required int errorCode,
    @required String errorMsg,
    this.openId,
    this.nickName,
    this.sex,
    this.province,
    this.city,
    this.country,
    this.headImgUrl,
    this.privilege,
    this.unionId,
  }) : super(errorCode: errorCode, errorMsg: errorMsg);

  final String openId;
  final String nickName;

  /// 1为男性，2为女性
  final int sex;
  final String province;
  final String city;
  final String country;
  final String headImgUrl;
  final List<dynamic> privilege;
  final String unionId;

  bool isMale() {
    return sex == 1;
  }

  bool isFemale() {
    return sex == 2;
  }
}

class FakeWechat {
  static const String _METHOD_REGISTERAPP = 'registerApp';
  static const String _METHOD_ISWECHATINSTALLED = 'isWechatInstalled';
  static const String _METHOD_ISWECHATSUPPORTAPI = 'isWechatSupportApi';
  static const String _METHOD_OPENWECHAT = 'openWechat';
  static const String _METHOD_AUTH = 'auth';
  static const String _METHOD_STARTQRAUTH = 'startQrauth';
  static const String _METHOD_STOPQRAUTH = 'stopQrauth';
  static const String _METHOD_OPENURL = 'openUrl';
  static const String _METHOD_OPENRANKLIST = 'openRankList';
  static const String _METHOD_OPENBIZPROFILE = 'openBizProfile';
  static const String _METHOD_OPENBIZURL = 'openBizUrl';
  static const String _METHOD_SHARETEXT = 'shareText';
  static const String _METHOD_SHAREIMAGE = 'shareImage';
  static const String _METHOD_SHAREMUSIC = 'shareMusic';
  static const String _METHOD_SHAREVIDEO = 'shareVideo';
  static const String _METHOD_SHAREWEBPAGE = 'shareWebpage';
  static const String _METHOD_SHAREMINIPROGRAM = 'shareMiniProgram';
  static const String _METHOD_SUBSCRIBEMSG = 'subscribeMsg';
  static const String _METHOD_LAUNCHMINIPROGRAM = 'launchMiniProgram';
  static const String _METHOD_PAY = 'pay';

  static const String _METHOD_ONAUTHRESP = 'onAuthResp';
  static const String _METHOD_ONOPENURLRESP = 'onOpenUrlResp';
  static const String _METHOD_ONSHAREMSGRESP = 'onShareMsgResp';
  static const String _METHOD_ONSUBSCRIBEMSGRESP = 'onSubscribeMsgResp';
  static const String _METHOD_ONLAUNCHMINIPROGRAMRESP =
      'onLaunchMiniProgramResp';
  static const String _METHOD_ONPAYRESP = 'onPayResp';
  static const String _METHOD_ONAUTHGOTQRCODE = 'onAuthGotQrcode';
  static const String _METHOD_ONAUTHQRCODESCANNED = 'onAuthQrcodeScanned';
  static const String _METHOD_ONAUTHFINISH = 'onAuthFinish';

  static const String _ARGUMENT_KEY_APPID = 'appId';
  static const String _ARGUMENT_KEY_ENABLEMTA = 'enableMTA';
  static const String _ARGUMENT_KEY_SCOPE = 'scope';
  static const String _ARGUMENT_KEY_STATE = 'state';
  static const String _ARGUMENT_KEY_NONCESTR = 'noncestr';
  static const String _ARGUMENT_KEY_TIMESTAMP = 'timestamp';
  static const String _ARGUMENT_KEY_SIGNATURE = 'signature';
  static const String _ARGUMENT_KEY_URL = 'url';
  static const String _ARGUMENT_KEY_PROFILETYPE = 'profileType';
  static const String _ARGUMENT_KEY_USERNAME = 'username';
  static const String _ARGUMENT_KEY_EXTMSG = 'extMsg';
  static const String _ARGUMENT_KEY_WEBTYPE = 'webType';
  static const String _ARGUMENT_KEY_SCENE = 'scene';
  static const String _ARGUMENT_KEY_TEXT = 'text';
  static const String _ARGUMENT_KEY_TITLE = 'title';
  static const String _ARGUMENT_KEY_DESCRIPTION = 'description';
  static const String _ARGUMENT_KEY_THUMBDATA = 'thumbData';
  static const String _ARGUMENT_KEY_IMAGEDATA = 'imageData';
  static const String _ARGUMENT_KEY_MUSICURL = 'musicUrl';
  static const String _ARGUMENT_KEY_MUSICDATAURL = 'musicDataUrl';
  static const String _ARGUMENT_KEY_MUSICLOWBANDURL = 'musicLowBandUrl';
  static const String _ARGUMENT_KEY_MUSICLOWBANDDATAURL = 'musicLowBandDataUrl';
  static const String _ARGUMENT_KEY_VIDEOURL = 'videoUrl';
  static const String _ARGUMENT_KEY_VIDEOLOWBANDURL = 'videoLowBandUrl';
  static const String _ARGUMENT_KEY_WEBPAGEURL = 'webpageUrl';
  static const String _ARGUMENT_KEY_PATH = 'path';
  static const String _ARGUMENT_KEY_HDIMAGEDATA = 'hdImageData';
  static const String _ARGUMENT_KEY_WITHSHARETICKET = 'withShareTicket';
  static const String _ARGUMENT_KEY_TEMPLATEID = 'templateId';
  static const String _ARGUMENT_KEY_RESERVED = 'reserved';
  static const String _ARGUMENT_KEY_PARTNERID = 'partnerId';
  static const String _ARGUMENT_KEY_PREPAYID = 'prepayId';

//  static const String _ARGUMENT_KEY_NONCESTR = 'noncestr';
//  static const String _ARGUMENT_KEY_TIMESTAMP = 'timestamp';
  static const String _ARGUMENT_KEY_PACKAGE = 'package';
  static const String _ARGUMENT_KEY_SIGN = 'sign';

  static const String _ARGUMENT_KEY_RESULT_ERRORCODE = 'errorCode';
  static const String _ARGUMENT_KEY_RESULT_ERRORMSG = 'errorMsg';
  static const String _ARGUMENT_KEY_RESULT_CODE = 'code';
  static const String _ARGUMENT_KEY_RESULT_STATE = 'state';
  static const String _ARGUMENT_KEY_RESULT_LANG = 'lang';
  static const String _ARGUMENT_KEY_RESULT_COUNTRY = 'country';
  static const String _ARGUMENT_KEY_RESULT_TEMPLATEID = 'templateId';
  static const String _ARGUMENT_KEY_RESULT_SCENE = 'scene';
  static const String _ARGUMENT_KEY_RESULT_ACTION = 'action';
  static const String _ARGUMENT_KEY_RESULT_RESERVED = 'reserved';
  static const String _ARGUMENT_KEY_RESULT_OPENID = 'openId';
  static const String _ARGUMENT_KEY_RESULT_EXTMSG = 'extMsg';
  static const String _ARGUMENT_KEY_RESULT_RETURNKEY = 'returnKey';
  static const String _ARGUMENT_KEY_RESULT_IMAGEDATA = 'imageData';
  static const String _ARGUMENT_KEY_RESULT_AUTHCODE = 'authCode';

  static const MethodChannel _channel =
      MethodChannel('v7lin.github.io/fake_wechat');

  final StreamController<FakeWechatAuthResp> _authRespStreamController =
      StreamController<FakeWechatAuthResp>.broadcast();

  final StreamController<FakeWechatOpenUrlResp> _openUrlRespStreamController =
      StreamController<FakeWechatOpenUrlResp>.broadcast();

  final StreamController<FakeWechatShareMsgResp> _shareMsgRespStreamController =
      StreamController<FakeWechatShareMsgResp>.broadcast();

  final StreamController<FakeWechatSubscribeMsgResp>
      _subscribeMsgRespStreamController =
      StreamController<FakeWechatSubscribeMsgResp>.broadcast();

  final StreamController<FakeWechatLaunchMiniProgramResp>
      _launchMiniProgramRespStreamController =
      StreamController<FakeWechatLaunchMiniProgramResp>.broadcast();

  final StreamController<FakeWechatPayResp> _payRespStreamController =
      StreamController<FakeWechatPayResp>.broadcast();

  final StreamController<Uint8List> _authGotQrcodeRespStreamController =
      StreamController<Uint8List>.broadcast();

  final StreamController<String> _authQrcodeScannedRespStreamController =
      StreamController<String>.broadcast();

  final StreamController<FakeWechatQrauthResp> _authFinishRespStreamController =
      StreamController<FakeWechatQrauthResp>.broadcast();

  /// 向微信注册应用
  Future<void> registerApp({
    @required String appId,
    bool enableMTA = false,
  }) {
    assert(appId != null && appId.isNotEmpty);
    _channel.setMethodCallHandler(_handleMethod);
    return _channel.invokeMethod(
      _METHOD_REGISTERAPP,
      <String, dynamic>{
        _ARGUMENT_KEY_APPID: appId,
        _ARGUMENT_KEY_ENABLEMTA: enableMTA,
      },
    );
  }

  Future<dynamic> _handleMethod(MethodCall call) async {
    switch (call.method) {
      case _METHOD_ONAUTHRESP:
        _authRespStreamController.add(FakeWechatAuthResp._(
          errorCode: call.arguments[_ARGUMENT_KEY_RESULT_ERRORCODE] as int,
          errorMsg: call.arguments[_ARGUMENT_KEY_RESULT_ERRORMSG] as String,
          code: call.arguments[_ARGUMENT_KEY_RESULT_CODE] as String,
          state: call.arguments[_ARGUMENT_KEY_RESULT_STATE] as String,
          lang: call.arguments[_ARGUMENT_KEY_RESULT_LANG] as String,
          country: call.arguments[_ARGUMENT_KEY_RESULT_COUNTRY] as String,
        ));
        break;
      case _METHOD_ONOPENURLRESP:
        _openUrlRespStreamController.add(FakeWechatOpenUrlResp._(
          errorCode: call.arguments[_ARGUMENT_KEY_RESULT_ERRORCODE] as int,
          errorMsg: call.arguments[_ARGUMENT_KEY_RESULT_ERRORMSG] as String,
        ));
        break;
      case _METHOD_ONSHAREMSGRESP:
        _shareMsgRespStreamController.add(FakeWechatShareMsgResp._(
          errorCode: call.arguments[_ARGUMENT_KEY_RESULT_ERRORCODE] as int,
          errorMsg: call.arguments[_ARGUMENT_KEY_RESULT_ERRORMSG] as String,
        ));
        break;
      case _METHOD_ONSUBSCRIBEMSGRESP:
        _subscribeMsgRespStreamController.add(FakeWechatSubscribeMsgResp._(
          errorCode: call.arguments[_ARGUMENT_KEY_RESULT_ERRORCODE] as int,
          errorMsg: call.arguments[_ARGUMENT_KEY_RESULT_ERRORMSG] as String,
          templateId: call.arguments[_ARGUMENT_KEY_RESULT_TEMPLATEID] as String,
          scene: call.arguments[_ARGUMENT_KEY_RESULT_SCENE] as int,
          action: call.arguments[_ARGUMENT_KEY_RESULT_ACTION] as String,
          reserved: call.arguments[_ARGUMENT_KEY_RESULT_RESERVED] as String,
          openId: call.arguments[_ARGUMENT_KEY_RESULT_OPENID] as String,
        ));
        break;
      case _METHOD_ONLAUNCHMINIPROGRAMRESP:
        _launchMiniProgramRespStreamController
            .add(FakeWechatLaunchMiniProgramResp._(
          errorCode: call.arguments[_ARGUMENT_KEY_RESULT_ERRORCODE] as int,
          errorMsg: call.arguments[_ARGUMENT_KEY_RESULT_ERRORMSG] as String,
          extMsg: call.arguments[_ARGUMENT_KEY_RESULT_EXTMSG] as String,
        ));
        break;
      case _METHOD_ONPAYRESP:
        _payRespStreamController.add(FakeWechatPayResp._(
          errorCode: call.arguments[_ARGUMENT_KEY_RESULT_ERRORCODE] as int,
          errorMsg: call.arguments[_ARGUMENT_KEY_RESULT_ERRORMSG] as String,
          returnKey: call.arguments[_ARGUMENT_KEY_RESULT_RETURNKEY] as String,
        ));
        break;
      case _METHOD_ONAUTHGOTQRCODE:
        _authGotQrcodeRespStreamController
            .add(call.arguments[_ARGUMENT_KEY_RESULT_IMAGEDATA] as Uint8List);
        break;
      case _METHOD_ONAUTHQRCODESCANNED:
        _authQrcodeScannedRespStreamController.add('QrcodeScanned');
        break;
      case _METHOD_ONAUTHFINISH:
        _authFinishRespStreamController.add(FakeWechatQrauthResp._(
          errorCode: call.arguments[_ARGUMENT_KEY_RESULT_ERRORCODE] as int,
          authCode: call.arguments[_ARGUMENT_KEY_RESULT_AUTHCODE] as String,
        ));
        break;
    }
  }

  /// 登录
  Stream<FakeWechatAuthResp> authResp() {
    return _authRespStreamController.stream;
  }

  /// 打开浏览器
  Stream<FakeWechatOpenUrlResp> openUrlResp() {
    return _openUrlRespStreamController.stream;
  }

  /// 分享
  Stream<FakeWechatShareMsgResp> shareMsgResp() {
    return _shareMsgRespStreamController.stream;
  }

  /// 一次性订阅消息
  Stream<FakeWechatSubscribeMsgResp> subscribeMsgResp() {
    return _subscribeMsgRespStreamController.stream;
  }

  /// 打开小程序
  Stream<FakeWechatLaunchMiniProgramResp> launchMiniProgramResp() {
    return _launchMiniProgramRespStreamController.stream;
  }

  /// 支付
  Stream<FakeWechatPayResp> payResp() {
    return _payRespStreamController.stream;
  }

  /// 扫码登录 - 获取二维码
  Stream<Uint8List> authGotQrcodeResp() {
    return _authGotQrcodeRespStreamController.stream;
  }

  /// 扫码登录 - 用户扫描二维码
  Stream<String> authQrcodeScannedResp() {
    return _authQrcodeScannedRespStreamController.stream;
  }

  /// 扫码登录 - 用户点击授权
  Stream<FakeWechatQrauthResp> authFinishResp() {
    return _authFinishRespStreamController.stream;
  }

  /// 检测微信是否已安装
  Future<bool> isWechatInstalled() async {
    return (await _channel.invokeMethod(_METHOD_ISWECHATINSTALLED)) as bool;
  }

  /// 判断当前微信的版本是否支持OpenApi
  Future<bool> isWechatSupportApi() async {
    return (await _channel.invokeMethod(_METHOD_ISWECHATSUPPORTAPI)) as bool;
  }

  /// 打开微信
  Future<bool> openWechat() async {
    return (await _channel.invokeMethod(_METHOD_OPENWECHAT)) as bool;
  }

  /// 授权登录
  Future<void> auth({
    @required List<String> scope,
    String state,
  }) {
    assert(scope != null && scope.isNotEmpty);
    Map<String, dynamic> map = <String, dynamic>{
      _ARGUMENT_KEY_SCOPE: scope.join(','), // Scope
//      _ARGUMENT_KEY_STATE: state,
    };

    /// 兼容 iOS 空安全 -> NSNull
    if (state != null) {
      map.putIfAbsent(_ARGUMENT_KEY_STATE, () => state);
    }
    return _channel.invokeMethod(_METHOD_AUTH, map);
  }

  /// 获取access_token
  Future<FakeWechatAccessToken> getAccessToken({
    @required String appId,
    @required String appSecret,
  }) {
    assert(appId != null && appId.isNotEmpty);
    assert(appSecret != null && appSecret.isNotEmpty);
    return HttpClient()
        .getUrl(Uri.parse(
            'https://api.weixin.qq.com/cgi-bin/token?grant_type=client_credential&appid=$appId&secret=$appSecret'))
        .then((HttpClientRequest request) {
      return request.close();
    }).then((HttpClientResponse response) async {
      if (response.statusCode == HttpStatus.ok) {
        String content = await utf8.decodeStream(response);
        Map<dynamic, dynamic> map = json.decode(content) as Map<dynamic, dynamic>;
        int errorCode = map.containsKey(FakeWechatApiResp.KEY_ERRORCODE)
            ? map[FakeWechatApiResp.KEY_ERRORCODE] as int
            : FakeWechatApiResp.SUCCESS;
        String errorMsg = map[FakeWechatApiResp.KEY_ERRORMSG] as String;
        if (errorCode == FakeWechatApiResp.SUCCESS) {
          return FakeWechatAccessToken._(
            errorCode: errorCode,
            errorMsg: errorMsg,
            accessToken: map[FakeWechatApiResp.KEY_ACCESS_TOKEN] as String,
            expiresIn: map[FakeWechatApiResp.KEY_EXPIRES_IN] as int,
          );
        } else {
          return FakeWechatAccessToken._(
            errorCode: errorCode,
            errorMsg: errorMsg,
          );
        }
      }
      throw HttpException(
          'HttpResponse statusCode: ${response.statusCode}, reasonPhrase: ${response.reasonPhrase}.');
    });
  }

  Future<FakeWechatTicket> getTicket({
    @required String accessToken,
  }) {
    assert(accessToken != null && accessToken.isNotEmpty);
    return HttpClient()
        .getUrl(Uri.parse(
            'https://api.weixin.qq.com/cgi-bin/ticket/getticket?access_token=$accessToken&type=2'))
        .then((HttpClientRequest request) {
      return request.close();
    }).then((HttpClientResponse response) async {
      if (response.statusCode == HttpStatus.ok) {
        String content = await utf8.decodeStream(response);
        Map<dynamic, dynamic> map = json.decode(content) as Map<dynamic, dynamic>;
        int errorCode = map.containsKey(FakeWechatApiResp.KEY_ERRORCODE)
            ? map[FakeWechatApiResp.KEY_ERRORCODE] as int
            : FakeWechatApiResp.SUCCESS;
        String errorMsg = map[FakeWechatApiResp.KEY_ERRORMSG] as String;
        if (errorCode == FakeWechatApiResp.SUCCESS) {
          return FakeWechatTicket._(
            errorCode: errorCode,
            errorMsg: errorMsg,
            ticket: map[FakeWechatTicket.KEY_TICKET] as String,
            expiresIn: map[FakeWechatApiResp.KEY_EXPIRES_IN] as int,
          );
        } else {
          return FakeWechatTicket._(
            errorCode: errorCode,
            errorMsg: errorMsg,
          );
        }
      }
      throw HttpException(
          'HttpResponse statusCode: ${response.statusCode}, reasonPhrase: ${response.reasonPhrase}.');
    });
  }

  /// 开始扫码登录
  Future<void> startQrauth({
    @required String appId,
    @required String scope,
    @required String ticket,
  }) {
    assert(appId != null && appId.isNotEmpty);
    assert(scope != null && scope.isNotEmpty);
    assert(ticket != null && ticket.isNotEmpty);
    String noncestr = Uuid().v1().toString().replaceAll('-', '');
    String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final String content =
        'appid=$appId&noncestr=$noncestr&sdk_ticket=$ticket&timestamp=$timestamp';
    String signature = hex.encode(sha1.convert(utf8.encode(content)).bytes);
    return _channel.invokeMethod(_METHOD_STARTQRAUTH, <String, dynamic>{
      _ARGUMENT_KEY_APPID: appId,
      _ARGUMENT_KEY_SCOPE: scope, // Scope
      _ARGUMENT_KEY_NONCESTR: noncestr,
      _ARGUMENT_KEY_TIMESTAMP: timestamp,
      _ARGUMENT_KEY_SIGNATURE: signature,
    });
  }

  /// 暂停扫码登录请求
  Future<void> stopQrauth() {
    return _channel.invokeMethod(_METHOD_STOPQRAUTH);
  }

  /// 获取 access_token
  Future<FakeWechatUnionIDAccessToken> getUnionIDAccessToken({
    @required String appId,
    @required String appSecret,
    @required String code,
  }) {
    assert(appId != null && appId.isNotEmpty);
    assert(appSecret != null && appSecret.isNotEmpty);
    assert(code != null && code.isNotEmpty);
    return HttpClient()
        .getUrl(Uri.parse(
            'https://api.weixin.qq.com/sns/oauth2/access_token?appid=$appId&secret=$appSecret&code=$code&grant_type=authorization_code'))
        .then((HttpClientRequest request) {
      return request.close();
    }).then((HttpClientResponse response) async {
      if (response.statusCode == HttpStatus.ok) {
        String content = await utf8.decodeStream(response);
        Map<dynamic, dynamic> map = json.decode(content) as Map<dynamic, dynamic>;
        int errorCode = map.containsKey(FakeWechatApiResp.KEY_ERRORCODE)
            ? map[FakeWechatApiResp.KEY_ERRORCODE] as int
            : FakeWechatApiResp.SUCCESS;
        String errorMsg = map[FakeWechatApiResp.KEY_ERRORMSG] as String;
        if (errorCode == FakeWechatApiResp.SUCCESS) {
          return FakeWechatUnionIDAccessToken._(
            errorCode: errorCode,
            errorMsg: errorMsg,
            openId: map[FakeWechatApiResp.KEY_OPENID] as String,
            scope: map[FakeWechatApiResp.KEY_SCOPE] as String,
            accessToken: map[FakeWechatApiResp.KEY_ACCESS_TOKEN] as String,
            refreshToken: map[FakeWechatApiResp.KEY_REFRESH_TOKEN] as String,
            expiresIn: map[FakeWechatApiResp.KEY_EXPIRES_IN] as int,
          );
        } else {
          return FakeWechatUnionIDAccessToken._(
            errorCode: errorCode,
            errorMsg: errorMsg,
          );
        }
      }
      throw HttpException(
          'HttpResponse statusCode: ${response.statusCode}, reasonPhrase: ${response.reasonPhrase}.');
    });
  }

  /// 获取用户个人信息（UnionID机制）
  Future<FakeWechatUnionIDUserInfo> getUnionIDUserInfo({
    @required String openId,
    @required String accessToken,
  }) {
    assert(openId != null && openId.isNotEmpty);
    assert(accessToken != null && accessToken.isNotEmpty);
    return HttpClient()
        .getUrl(Uri.parse(
            'https://api.weixin.qq.com/sns/userinfo?access_token=$accessToken&openid=$openId'))
        .then((HttpClientRequest request) {
      return request.close();
    }).then((HttpClientResponse response) async {
      if (response.statusCode == HttpStatus.ok) {
        String content = await utf8.decodeStream(response);
        Map<dynamic, dynamic> map = json.decode(content) as Map<dynamic, dynamic>;
        int errorCode = map.containsKey(FakeWechatApiResp.KEY_ERRORCODE)
            ? map[FakeWechatApiResp.KEY_ERRORCODE] as int
            : FakeWechatApiResp.SUCCESS;
        String errorMsg = map[FakeWechatApiResp.KEY_ERRORMSG] as String;
        if (errorCode == FakeWechatApiResp.SUCCESS) {
          return FakeWechatUnionIDUserInfo._(
            errorCode: errorCode,
            errorMsg: errorMsg,
            openId: map[FakeWechatApiResp.KEY_OPENID] as String,
            nickName: map[FakeWechatApiResp.KEY_NICKNAME] as String,
            sex: map[FakeWechatApiResp.KEY_SEX] as int,
            province: map[FakeWechatApiResp.KEY_PROVINCE] as String,
            city: map[FakeWechatApiResp.KEY_CITY] as String,
            country: map[FakeWechatApiResp.KEY_COUNTRY] as String,
            headImgUrl: map[FakeWechatApiResp.KEY_HEADIMGURL] as String,
            privilege: map[FakeWechatApiResp.KEY_PRIVILEGE] as List<dynamic>,
            unionId: map[FakeWechatApiResp.KEY_UNIONID] as String,
          );
        } else {
          return FakeWechatUnionIDUserInfo._(
            errorCode: errorCode,
            errorMsg: errorMsg,
          );
        }
      }
      throw HttpException(
          'HttpResponse statusCode: ${response.statusCode}, reasonPhrase: ${response.reasonPhrase}.');
    });
  }

  /// 打开指定网页
  Future<void> openUrl({
    @required String url,
  }) {
    assert(url != null && url.isNotEmpty && url.length <= 10 * 1024);
    return _channel.invokeMethod(
      _METHOD_OPENURL,
      <String, dynamic>{
        _ARGUMENT_KEY_URL: url,
      },
    );
  }

  /// 打开硬件排行榜
  Future<void> openRankList() {
    return _channel.invokeMethod(_METHOD_OPENRANKLIST);
  }

  /// 打开指定微信号profile页面
  Future<void> openBizProfile({
    @required int profileType,
    @required String username,
    String extMsg,
  }) {
    assert(username != null && username.isNotEmpty && username.length <= 512);
    assert(extMsg == null || extMsg.length <= 1024);
    Map<String, dynamic> map = <String, dynamic>{
      _ARGUMENT_KEY_PROFILETYPE: profileType, // BizProfileType
      _ARGUMENT_KEY_USERNAME: username,
//      _ARGUMENT_KEY_EXTMSG: extMsg,
    };
    if (extMsg != null) {
      map.putIfAbsent(_ARGUMENT_KEY_EXTMSG, () => extMsg);
    }

    /// 兼容 iOS 空安全 -> NSNull
    return _channel.invokeMethod(_METHOD_OPENBIZPROFILE, map);
  }

  /// 打开指定username的profile网页版
  Future<void> openBizUrl({
    @required int webType,
    @required String username,
    String extMsg,
  }) {
    assert(username != null && username.isNotEmpty && username.length <= 512);
    assert(extMsg == null || extMsg.length <= 1024);
    Map<String, dynamic> map = <String, dynamic>{
      _ARGUMENT_KEY_WEBTYPE: webType, // MPWebviewType
      _ARGUMENT_KEY_USERNAME: username,
//      _ARGUMENT_KEY_EXTMSG: extMsg,
    };

    /// 兼容 iOS 空安全 -> NSNull
    if (extMsg != null) {
      map.putIfAbsent(_ARGUMENT_KEY_EXTMSG, () => extMsg);
    }
    return _channel.invokeMethod(_METHOD_OPENBIZURL, map);
  }

  /// 分享 - 文本
  Future<void> shareText({
    @required int scene,
    @required String text,
  }) {
    assert(text != null && text.isNotEmpty && text.length <= 10 * 1024);
    return _channel.invokeMethod(_METHOD_SHARETEXT, <String, dynamic>{
      _ARGUMENT_KEY_SCENE: scene, // Scene
      _ARGUMENT_KEY_TEXT: text,
    });
  }

  /// 分享 - 图片
  Future<void> shareImage({
    @required int scene,
    String title,
    String description,
    Uint8List thumbData,
    @required Uint8List imageData,
  }) {
    assert(title == null || title.length <= 512);
    assert(description == null || description.length <= 1024);
    assert(thumbData == null || thumbData.lengthInBytes <= 32 * 1024);
    assert(imageData != null && imageData.lengthInBytes <= 10 * 1024 * 1024);
    Map<String, dynamic> map = <String, dynamic>{
      _ARGUMENT_KEY_SCENE: scene, // Scene
//      _ARGUMENT_KEY_TITLE: title,
//      _ARGUMENT_KEY_DESCRIPTION: description,
//      _ARGUMENT_KEY_THUMBDATA: thumbData,
      _ARGUMENT_KEY_IMAGEDATA: imageData,
    };

    /// 兼容 iOS 空安全 -> NSNull
    if (title != null) {
      map.putIfAbsent(_ARGUMENT_KEY_TITLE, () => title);
    }
    if (description != null) {
      map.putIfAbsent(_ARGUMENT_KEY_DESCRIPTION, () => description);
    }
    if (thumbData != null) {
      map.putIfAbsent(_ARGUMENT_KEY_THUMBDATA, () => thumbData);
    }
    return _channel.invokeMethod(_METHOD_SHAREIMAGE, map);
  }

  /// 分享 - 音乐
  Future<void> shareMediaMusic({
    @required int scene,
    String title,
    String description,
    Uint8List thumbData,
    String musicUrl,
    String musicDataUrl,
    String musicLowBandUrl,
    String musicLowBandDataUrl,
  }) {
    assert(title == null || title.length <= 512);
    assert(description == null || description.length <= 1024);
    assert(thumbData == null || thumbData.lengthInBytes <= 32 * 1024);
    assert((musicUrl != null &&
            musicUrl.isNotEmpty &&
            musicUrl.length <= 10 * 1024) ||
        (musicLowBandUrl != null &&
            musicLowBandUrl.isNotEmpty &&
            musicLowBandUrl.length <= 10 * 1024));
    Map<String, dynamic> map = <String, dynamic>{
      _ARGUMENT_KEY_SCENE: scene, // Scene
//      _ARGUMENT_KEY_TITLE: title,
//      _ARGUMENT_KEY_DESCRIPTION: description,
//      _ARGUMENT_KEY_THUMBDATA: thumbData,
//      _ARGUMENT_KEY_MUSICURL: musicUrl,
//      _ARGUMENT_KEY_MUSICDATAURL: musicDataUrl,
//      _ARGUMENT_KEY_MUSICLOWBANDURL: musicLowBandUrl,
//      _ARGUMENT_KEY_MUSICLOWBANDDATAURL: musicLowBandDataUrl,
    };

    /// 兼容 iOS 空安全 -> NSNull
    if (title != null) {
      map.putIfAbsent(_ARGUMENT_KEY_TITLE, () => title);
    }
    if (description != null) {
      map.putIfAbsent(_ARGUMENT_KEY_DESCRIPTION, () => description);
    }
    if (thumbData != null) {
      map.putIfAbsent(_ARGUMENT_KEY_THUMBDATA, () => thumbData);
    }
    if (musicUrl != null) {
      map.putIfAbsent(_ARGUMENT_KEY_MUSICURL, () => musicUrl);
    }
    if (musicDataUrl != null) {
      map.putIfAbsent(_ARGUMENT_KEY_MUSICDATAURL, () => musicDataUrl);
    }
    if (musicLowBandUrl != null) {
      map.putIfAbsent(_ARGUMENT_KEY_MUSICLOWBANDURL, () => musicLowBandUrl);
    }
    if (musicLowBandDataUrl != null) {
      map.putIfAbsent(
          _ARGUMENT_KEY_MUSICLOWBANDDATAURL, () => musicLowBandDataUrl);
    }
    return _channel.invokeMethod(_METHOD_SHAREMUSIC, map);
  }

  /// 分享 - 视频
  Future<void> shareVideo({
    @required int scene,
    String title,
    String description,
    Uint8List thumbData,
    String videoUrl,
    String videoLowBandUrl,
  }) {
    assert(title == null || title.length <= 512);
    assert(description == null || description.length <= 1024);
    assert(thumbData == null || thumbData.lengthInBytes <= 32 * 1024);
    assert((videoUrl != null &&
            videoUrl.isNotEmpty &&
            videoUrl.length <= 10 * 1024) ||
        (videoLowBandUrl != null &&
            videoLowBandUrl.isNotEmpty &&
            videoLowBandUrl.length <= 10 * 1024));
    Map<String, dynamic> map = <String, dynamic>{
      _ARGUMENT_KEY_SCENE: scene, // Scene
//      _ARGUMENT_KEY_TITLE: title,
//      _ARGUMENT_KEY_DESCRIPTION: description,
//      _ARGUMENT_KEY_THUMBDATA: thumbData,
//      _ARGUMENT_KEY_VIDEOURL: videoUrl,
//      _ARGUMENT_KEY_VIDEOLOWBANDURL: videoLowBandUrl,
    };

    /// 兼容 iOS 空安全 -> NSNull
    if (title != null) {
      map.putIfAbsent(_ARGUMENT_KEY_TITLE, () => title);
    }
    if (description != null) {
      map.putIfAbsent(_ARGUMENT_KEY_DESCRIPTION, () => description);
    }
    if (thumbData != null) {
      map.putIfAbsent(_ARGUMENT_KEY_THUMBDATA, () => thumbData);
    }
    if (videoUrl != null) {
      map.putIfAbsent(_ARGUMENT_KEY_VIDEOURL, () => videoUrl);
    }
    if (videoLowBandUrl != null) {
      map.putIfAbsent(_ARGUMENT_KEY_VIDEOLOWBANDURL, () => videoLowBandUrl);
    }
    return _channel.invokeMethod(_METHOD_SHAREVIDEO, map);
  }

  /// 分享 - 网页
  Future<void> shareWebpage({
    @required int scene,
    String title,
    String description,
    Uint8List thumbData,
    @required String webpageUrl,
  }) {
    assert(title == null || title.length <= 512);
    assert(description == null || description.length <= 1024);
    assert(thumbData == null || thumbData.lengthInBytes <= 32 * 1024);
    assert(webpageUrl != null &&
        webpageUrl.isNotEmpty &&
        webpageUrl.length <= 10 * 1024);
    Map<String, dynamic> map = <String, dynamic>{
      _ARGUMENT_KEY_SCENE: scene, // Scene
//      _ARGUMENT_KEY_TITLE: title,
//      _ARGUMENT_KEY_DESCRIPTION: description,
//      _ARGUMENT_KEY_THUMBDATA: thumbData,
      _ARGUMENT_KEY_WEBPAGEURL: webpageUrl,
    };

    /// 兼容 iOS 空安全 -> NSNull
    if (title != null) {
      map.putIfAbsent(_ARGUMENT_KEY_TITLE, () => title);
    }
    if (description != null) {
      map.putIfAbsent(_ARGUMENT_KEY_DESCRIPTION, () => description);
    }
    if (thumbData != null) {
      map.putIfAbsent(_ARGUMENT_KEY_THUMBDATA, () => thumbData);
    }
    return _channel.invokeMethod(_METHOD_SHAREWEBPAGE, map);
  }

  /// 分享 - 小程序 - 目前只支持分享到会话
  Future<void> shareMiniProgram({
    @required int scene,
    String title,
    String description,
    Uint8List thumbData,
    @required String webpageUrl,
    @required String userName,
    String path,
    Uint8List hdImageData,
    bool withShareTicket = false,
  }) {
    assert(title == null || title.length <= 512);
    assert(description == null || description.length <= 1024);
    assert(thumbData == null || thumbData.lengthInBytes <= 32 * 1024);
    assert(webpageUrl != null && webpageUrl.isNotEmpty);
    assert(userName != null && userName.isNotEmpty);
    assert(hdImageData == null || hdImageData.lengthInBytes <= 128 * 1024);
    Map<String, dynamic> map = <String, dynamic>{
      _ARGUMENT_KEY_SCENE: scene, // Scene
//      _ARGUMENT_KEY_TITLE: title,
//      _ARGUMENT_KEY_DESCRIPTION: description,
//      _ARGUMENT_KEY_THUMBDATA: thumbData,
      _ARGUMENT_KEY_WEBPAGEURL: webpageUrl,
      _ARGUMENT_KEY_USERNAME: userName,
//      _ARGUMENT_KEY_PATH: path,
//      _ARGUMENT_KEY_HDIMAGEDATA: hdImageData,
      _ARGUMENT_KEY_WITHSHARETICKET: withShareTicket,
    };

    /// 兼容 iOS 空安全 -> NSNull
    if (title != null) {
      map.putIfAbsent(_ARGUMENT_KEY_TITLE, () => title);
    }
    if (description != null) {
      map.putIfAbsent(_ARGUMENT_KEY_DESCRIPTION, () => description);
    }
    if (thumbData != null) {
      map.putIfAbsent(_ARGUMENT_KEY_THUMBDATA, () => thumbData);
    }
    if (path != null) {
      map.putIfAbsent(_ARGUMENT_KEY_PATH, () => path);
    }
    if (hdImageData != null) {
      map.putIfAbsent(_ARGUMENT_KEY_HDIMAGEDATA, () => hdImageData);
    }
    return _channel.invokeMethod(_METHOD_SHAREMINIPROGRAM, map);
  }

  /// 一次性订阅消息
  Future<void> subscribeMsg({
    @required int scene,
    @required String templateId,
    String reserved,
  }) {
    assert(templateId != null &&
        templateId.isNotEmpty &&
        templateId.length <= 1024);
    assert(reserved == null || reserved.length <= 1024);
    Map<String, dynamic> map = <String, dynamic>{
      _ARGUMENT_KEY_SCENE: scene,
      _ARGUMENT_KEY_TEMPLATEID: templateId,
//      _ARGUMENT_KEY_RESERVED: reserved,
    };

    /// 兼容 iOS 空安全 -> NSNull
    if (reserved != null) {
      map.putIfAbsent(_ARGUMENT_KEY_RESERVED, () => reserved);
    }
    return _channel.invokeMethod(_METHOD_SUBSCRIBEMSG, map);
  }

  /// 打开小程序
  Future<void> launchMiniProgram({
    @required String userName,
    String path,
  }) {
    assert(userName != null && userName.isNotEmpty);
    Map<String, dynamic> map = <String, dynamic>{
      _ARGUMENT_KEY_USERNAME: userName,
//      _ARGUMENT_KEY_PATH: path,
    };

    /// 兼容 iOS 空安全 -> NSNull
    if (path != null) {
      map.putIfAbsent(_ARGUMENT_KEY_PATH, () => path);
    }
    return _channel.invokeMethod(_METHOD_LAUNCHMINIPROGRAM, map);
  }

  /// 支付
  Future<void> pay({
    @required String appId,
    @required String partnerId,
    @required String prepayId,
    @required String nonceStr,
    @required String timeStamp,
    @required String package,
    @required String sign,
  }) {
    assert(appId != null && appId.isNotEmpty);
    assert(partnerId != null && partnerId.isNotEmpty);
    assert(prepayId != null && prepayId.isNotEmpty);
    assert(nonceStr != null && nonceStr.isNotEmpty);
    assert(timeStamp != null && timeStamp.isNotEmpty);
    assert(package != null && package.isNotEmpty);
    assert(sign != null && sign.isNotEmpty);
    return _channel.invokeMethod(_METHOD_PAY, <String, dynamic>{
      _ARGUMENT_KEY_APPID: appId,
      _ARGUMENT_KEY_PARTNERID: partnerId,
      _ARGUMENT_KEY_PREPAYID: prepayId,
      _ARGUMENT_KEY_NONCESTR: nonceStr,
      _ARGUMENT_KEY_TIMESTAMP: timeStamp,
      _ARGUMENT_KEY_PACKAGE: package,
      _ARGUMENT_KEY_SIGN: sign,
    });
  }
}

class FakeWechatProvider extends InheritedWidget {
  FakeWechatProvider({
    Key key,
    @required this.wechat,
    @required Widget child,
  }) : super(key: key, child: child);

  final FakeWechat wechat;

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) {
    FakeWechatProvider oldProvider = oldWidget as FakeWechatProvider;
    return wechat != oldProvider.wechat;
  }

  static FakeWechatProvider of(BuildContext context) {
    return context.inheritFromWidgetOfExactType(FakeWechatProvider)
        as FakeWechatProvider;
  }
}
