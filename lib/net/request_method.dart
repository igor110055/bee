import 'dart:async';
import 'dart:convert';
import 'dart:io';
// import 'dart:isolate';
import 'package:beewallet/net/url.dart';
import 'package:beewallet/utils/sp_manager.dart';
import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
// import 'package:isolate/isolate.dart';
import '../public.dart';

enum Method {
  GET,
  POST,
}

int _connectTimeout = 30 * 1000; //15s
int _receiveTimeout = 30 * 1000; //15s
int _sendTimeout = 10 * 1000; //10s

typedef complationBlock = void Function(dynamic result, int? code);

class RequestMethod {
  factory RequestMethod() => _getInstance()!;
  static RequestMethod? get manager => _getInstance();
  static RequestMethod? _manager;
  static Dio? get dio => _dio;
  static Dio? _dio;
  static Map<String, CancelToken> _cancelTMap = Map(); //自管理CancelToken
  static RequestMethod? _getInstance() {
    if (_manager == null) {
      _manager = RequestMethod.init();
    }
    return _manager;
  }

  final _options = BaseOptions(
    connectTimeout: _connectTimeout,
    receiveTimeout: _receiveTimeout,
    sendTimeout: _sendTimeout,
    responseType: ResponseType.json,
    contentType: "application/json",
  );

  RequestMethod.init() {
    // 初始化
    _dio = Dio(_options);
    if (!inProduction) {
      _setupPROXY(_dio!); //添加转发代理
    }
  }

  Future<dynamic> requestData<T>(
    Method method,
    String url, {
    Map<String, dynamic>? queryParameters,
    dynamic data,
    Map<String, dynamic>? header,
    complationBlock? complationBlock,
  }) async {
    CancelToken cancelToken = RequestMethod._getCancelToken(url);
    Response response;
    if (url.contains(RequestURLS.testUrl) ||
        url.contains(RequestURLS.productUrl)) {
      //按照plat统一传adr，苹果ios，语言英文en_us,繁体：zh_TW
      KAppLanguage langu = SPManager.getAppLanguageMode();
      if (langu == KAppLanguage.system) {
        langu = SPManager.getSystemAppLanguage();
      }
      Map<String, dynamic> _commonParams = {
        "plat": isIOS ? "ios" : "adr",
        "lang": langu == KAppLanguage.zh_cn ? "zh_TW" : "en_us",
      };
      queryParameters ??= {};
      queryParameters.addAll(_commonParams);
    }
    Options? options;
    if (header != null) {
      options ??= Options(headers: header);
    }
    try {
      if (Method.GET == method) {
        response = await _dio!.get(url,
            queryParameters: queryParameters,
            cancelToken: cancelToken,
            options: options);
      } else {
        response = await _dio!.post(url,
            data: data,
            queryParameters: queryParameters,
            options: options,
            cancelToken: cancelToken);
      }
      dynamic result = response.data;
      if (response.statusCode == 200 || response.statusCode == 201) {
        // LogUtil.v("完整地址 " + response.realUri.toString());
        if (complationBlock != null) {
          complationBlock(result, 200);
        }
        return result;
      } else {
        throw Exception('statusCode:${response.statusCode}');
      }
    } on DioError catch (e) {
      LogUtil.v('请求出错：' + e.toString());
      LogUtil.v("错误完整地址 " + e.requestOptions.uri.toString());
      if (complationBlock != null) {
        complationBlock(e.toString(), 500);
      }
      return null;
    }
  }

  Future download<T>(
    String url, {
    Map<String, dynamic>? queryParameters,
    dynamic data,
    ProgressCallback? progress,
    String? savePath,
  }) async {
    CancelToken cancelToken = RequestMethod._getCancelToken(url);
    Response response;
    try {
      response = await _dio!.download(
        url,
        savePath,
        data: data,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
        onReceiveProgress: progress,
      );
      if (response.statusCode == 200) {
        // LogUtil.v("完整地址 " + response.request.uri.toString());
        return Future.value(response.data);
      } else {
        throw Exception('statusCode:${response.statusCode}');
      }
    } on DioError catch (e) {
      LogUtil.v('请求出错：' + e.toString());
      // LogUtil.v("完整地址 " + e.request.uri.toString());
    }
  }

  //配置取消token
  static CancelToken _getCancelToken(String? url) {
    CancelToken cancelToken = CancelToken(); //自管理取消码
    _cancelTMap["url"] = cancelToken;
    return cancelToken;
  }

  //取消请求
  static cancelRequest(String url) {
    CancelToken? cancelToken = _cancelTMap[url];
    if (cancelToken != null && cancelToken.isCancelled) {
      cancelToken.cancel();
    }
  }

  //获得请求方法
  static String _getRequestMethod(Method method) {
    String m;
    switch (method) {
      case Method.GET:
        m = 'get';
        break;
      case Method.POST:
        m = 'post';
        break;
      default:
        m = 'post';
        break;
    }
    return m;
  }

  //添加代理转发
  _setupPROXY(Dio dio) {
    (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
        (HttpClient client) {
      client.findProxy = (uri) {
        return "PROXY 192.168.0.104:8888";
      };
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) {
        return true;
      };
    };
  }
}
