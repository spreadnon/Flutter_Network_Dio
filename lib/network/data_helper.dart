import 'dart:convert';

import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';

class DataHelper {
  static encrypParams(Map map) {
    var buffer = StringBuffer();
    map.forEach((key, value) {
      buffer.write(key);
      buffer.write(value);
    });

    buffer.write("SERECT");
    var sign = string2MD5(buffer.toString());
    print("sign---->" + sign);
    return sign;
  }

  static string2MD5(String data) {
    var content = new Utf8Encoder().convert(data);
    var digest = md5.convert(content);
    return hex.encode(digest.bytes);
  }
}
