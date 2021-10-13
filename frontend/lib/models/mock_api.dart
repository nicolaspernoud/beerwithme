import 'package:http/http.dart';
import 'package:http/testing.dart';

class MockAPI {
  late final Client client;
  MockAPI() {
    client = MockClient((request) async {
      switch (request.url.toString()) {
        case '/api/items/all':
          return Response(
              '[{"id":1,"category_id":1,"title":"MyItem","creator":"A Creator","creator_mail":"A Mail","creator_phone":"A Tel","description":"MyDescription","time":"2021-08-12T20:00:00","is_closed":false}]',
              200);
        default:
          return Response('Not Found', 404);
      }
    });
  }
}
