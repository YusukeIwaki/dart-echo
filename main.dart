import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';

class MyArgs {
  final String address;
  final int port;

  MyArgs._(this.address, this.port);

  factory MyArgs.parse(List<String> args) {
    ArgResults parsedArgs = (ArgParser()
          ..addOption("bind", abbr: "b", defaultsTo: "127.0.0.1")
          ..addOption("port", abbr: "p", defaultsTo: "3000"))
        .parse(args);
    return MyArgs._(parsedArgs["bind"], int.parse(parsedArgs["port"]));
  }
}

main(List<String> args) async {
  final myArgs = MyArgs.parse(args);
  final server = await HttpServer.bind(myArgs.address, myArgs.port);

  print("OS: ${Platform.operatingSystem}");
  print("OSVersion: ${Platform.operatingSystemVersion}");
  print("Listening on ${myArgs.address}:${myArgs.port}");

  await for (HttpRequest request in server) {
    print("${request.method} ${request.uri}");
    request.headers.forEach((String key, List<String> values) {
      values.forEach((String value) {
        print("$key: $value");
      });
    });
    String body = await utf8.decodeStream(request);
    print("\n$body");

    await (request.response
          ..statusCode = 200
          ..write(body))
        .close();
  }
}
