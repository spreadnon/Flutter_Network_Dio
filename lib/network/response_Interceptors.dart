import 'package:dio/dio.dart';

class ResultData {
  var data;
  bool isSuccess;
  int code;
  var headers;

  ResultData(this.data, this.isSuccess, this.code, {this.headers});
}

class ResponseInterceptors extends InterceptorsWrapper {
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    RequestOptions option = response.requestOptions;
    try {
      if (option.contentType != null && option.contentType!.contains("text")) {
        response.data = ResultData(response.data, true, 200);
        handler.next(response);
      }

      //一般只需要处理200的情况，300 400 500保留错误信息，外层为http协议定义的相应码
      if (response.statusCode == 200 || response.statusCode == 201) {
        int code = response.data["code"];
        if (code == 0) {
          response.data =
              ResultData(response.data, true, 200, headers: response.headers);
          handler.next(response);
        }
      } else {
        response.data =
            ResultData(response.data, false, 200, headers: response.headers);
        handler.next(response);
      }
    } catch (e) {
      print("ResponseError====" + e.toString() + "****" + option.path);

      response.data = ResultData(response.data, false, response.statusCode!,
          headers: response.headers);

      handler.next(response);
    }

    response.data = ResultData(response.data, false, response.statusCode!,
        headers: response.headers);
    handler.next(response);
  }
}
