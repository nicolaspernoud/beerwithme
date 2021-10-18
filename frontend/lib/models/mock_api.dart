import 'package:http/http.dart';
import 'package:http/testing.dart';

class MockAPI {
  late final Client client;
  MockAPI() {
    client = MockClient((request) async {
      switch (request.url.toString()) {
        case '/api/items':
          return Response(
              '[{"id":1,"brand_id":1,"category_id":1,"name":"01_name","description":"01_description","time":"2021-10-18T00:00:00"},{"id":2,"brand_id":1,"category_id":1,"name":"02_name","description":"02_description","time":"2021-10-18T00:00:01"}]',
              200);
        default:
          return Response('Not Found', 404);
      }
    });
  }
}
