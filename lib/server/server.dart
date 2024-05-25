import 'dart:io';

import 'package:silent_signal/configs/environment.dart';
import 'package:silent_signal/handlers/auth_handler.dart';
import 'package:silent_signal/handlers/group_handler.dart';
import 'package:silent_signal/handlers/group_message_handler.dart';
import 'package:silent_signal/handlers/private_message_handler.dart';
import 'package:silent_signal/handlers/upload_handler.dart';
import 'package:silent_signal/handlers/user_handler.dart';
import 'package:silent_signal/server/http_handler.dart';
import 'package:silent_signal/server/http_method.dart';

class Server {
  static final Map<String, HttpHandler> _router = _getRoutes();

  Future<void> start() async {
    final server = await HttpServer.bind(
      InternetAddress(Environment.getProperty('SERVER_HOST')!),
      int.parse(Environment.getProperty('SERVER_PORT')!),
    );
    print(
      'Server is running at http://${server.address.address}:${server.port}',
    );

    await for (var request in server) {
      _handleRequest(request);
    }
  }

  Future<void> _handleRequest(HttpRequest request) async {
    final path = '${request.uri.path} ${request.method}';
    var handler = _router[path];
    if (handler != null) {
      HttpMethod? method = HttpMethod.values.firstWhere(
        (e) => e.name == request.method,
      );
      switch (method) {
        case HttpMethod.GET:
          await handler.handleGet(request);
          break;
        case HttpMethod.POST:
          await handler.handlePost(request);
          break;
        case HttpMethod.PUT:
          await handler.handlePut(request);
          break;
        case HttpMethod.DELETE:
          await handler.handleDelete(request);
          break;
        default:
          request.response
            ..statusCode = HttpStatus.methodNotAllowed
            ..write('Not Implemented')
            ..close();
      }
    } else {
      request.response
        ..statusCode = HttpStatus.notFound
        ..write('Route Not Found')
        ..close();
    }
  }

  static Map<String, HttpHandler> _getRoutes() {
    return {
      '/auth/login ${HttpMethod.POST.name}': AuthHandler(),
      '/auth/register ${HttpMethod.POST.name}': AuthHandler(),
      '/auth/validate/token ${HttpMethod.POST.name}': AuthHandler(),
      '/auth/validate/hash ${HttpMethod.POST.name}': AuthHandler(),
      '/user ${HttpMethod.GET.name}': UserHandler(),
      '/user ${HttpMethod.PUT.name}': UserHandler(),
      '/user ${HttpMethod.DELETE.name}': UserHandler(),
      '/user/contact ${HttpMethod.POST.name}': UserHandler(),
      '/group ${HttpMethod.GET.name}': GroupHandler(),
      '/group ${HttpMethod.POST.name}': GroupHandler(),
      '/group ${HttpMethod.PUT.name}': GroupHandler(),
      '/group ${HttpMethod.DELETE.name}': GroupHandler(),
      '/groups ${HttpMethod.GET.name}': GroupHandler(),
      '/upload/picture/user ${HttpMethod.GET}': UploadHandler(),
      '/upload/picture/user ${HttpMethod.POST}': UploadHandler(),
      '/upload/picture/user ${HttpMethod.PUT}': UploadHandler(),
      '/upload/picture/group ${HttpMethod.GET}': UploadHandler(),
      '/upload/picture/group ${HttpMethod.POST}': UploadHandler(),
      '/upload/picture/group ${HttpMethod.PUT}': UploadHandler(),
      '/upload/chat/user ${HttpMethod.GET}': UploadHandler(),
      '/upload/chat/user ${HttpMethod.POST}': UploadHandler(),
      '/upload/chat/group ${HttpMethod.GET}': UploadHandler(),
      '/upload/chat/group ${HttpMethod.POST}': UploadHandler(),
      '/chat/private': PrivateMessageHandler(),
      '/chat/group': GroupMessageHandler(),
    };
  }
}
