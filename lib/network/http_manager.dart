import 'package:dio/dio.dart';
import 'package:flutter_network_dio/network/Code.dart';
import 'package:flutter_network_dio/network/dio_logInterceptor.dart';
import 'package:flutter_network_dio/network/loading.dart';
import 'package:flutter_network_dio/network/response_Interceptors.dart';
import 'package:flutter_network_dio/network/url_path.dart';
import 'data_helper.dart';

/// 所有接口类
class Api {
  ///示例请求
  static request(Map<String, dynamic> param) {
    return HttpManager.getInstance().get(UrlPath.testPath, params: param);
  }

  static requestOther(Map<String, dynamic> param) {
    return HttpManager.getInstance(baseUrl: UrlPath.otherUrl)
        .post(UrlPath.testPath, params: param);
  }
}

class HttpManager {
  static HttpManager _instance = HttpManager._internal();

  late Dio _dio;
  static const CODE_SUCCESS = 200;
  static const CODE_TIME_OUT = -1;
  static const CONNECT_TIMEOUT = 15000;

  factory HttpManager() => _instance;

  // ignore: unused_element
  HttpManager._internal({String? baseUrl}) {
    // ignore: unnecessary_null_comparison
    if (null == _dio) {
      _dio = new Dio(new BaseOptions(
          baseUrl: UrlPath.baseUrl, connectTimeout: CONNECT_TIMEOUT));
      _dio.interceptors.add(new DioLogInterceptor());
      _dio.interceptors.add(new ResponseInterceptors());
    }
  }

  static HttpManager getInstance({String? baseUrl}) {
    if (baseUrl == null) {
      return _instance.normal();
    } else {
      return _instance.baseUrl(baseUrl);
    }
  }

  HttpManager baseUrl(String baseUrl) {
    // ignore: unnecessary_null_comparison
    if (_dio != null) {
      _dio.options.baseUrl = baseUrl;
    }
    return this;
  }

  HttpManager normal() {
    // ignore: unnecessary_null_comparison
    if (_dio != null) {
      if (_dio.options.baseUrl != UrlPath.baseUrl) {
        _dio.options.baseUrl = UrlPath.baseUrl;
      }
    }
    return this;
  }

  //GET请求
  get(api, {params, withLoading = true}) async {
    if (withLoading) {
      Loading.show();
    }

    Response response;
    params["platform"] = "ios";
    params["system"] = "1.0.0";
    params["channel"] = "appstore";
    params["time"] = new DateTime.now().microsecondsSinceEpoch.toString();
    params["sign"] = DataHelper.encrypParams(params);

    try {
      response = await _dio.get(api, queryParameters: params);
      if (withLoading) {
        Loading.dismiss();
      }
    } on DioError catch (e) {
      if (withLoading) {
        Loading.dismiss();
      }
      return resultError(e);
    }

    if (response.data is DioError) {
      return resultError(response.data['code']);
    }

    return response.data;
  }

  //POST请求
  post(api, {params, withLoading = true}) async {
    if (withLoading) {
      Loading.show();
    }

    Response response;
    params["platform"] = "ios";
    params["system"] = "1.0.0";
    params["channel"] = "appstore";
    params["time"] = new DateTime.now().microsecondsSinceEpoch.toString();
    params["sign"] = DataHelper.encrypParams(params);

    try {
      response = await _dio.post(api, data: params);
      if (withLoading) {
        Loading.dismiss();
      }
    } on DioError catch (e) {
      if (withLoading) {
        Loading.dismiss();
      }
      return resultError(e);
    }

    if (response.data is DioError) {
      return resultError(response.data['code']);
    }

    return response.data;
  }
}

ResultData resultError(DioError e) {
  Response errorResponse;
  if (e.response != null) {
    errorResponse = e.response!;
  } else {
    // ignore: null_check_always_fails
    errorResponse = new Response(statusCode: 666, requestOptions: null!);
  }
  if (e.type == DioErrorType.connectTimeout ||
      e.type == DioErrorType.receiveTimeout) {
    errorResponse.statusCode = Code.NETWORK_TIMEOUT;
  }
  return new ResultData(
      errorResponse.statusMessage, false, errorResponse.statusCode!);
}
