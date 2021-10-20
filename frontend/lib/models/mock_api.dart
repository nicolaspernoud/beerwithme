import 'package:http/http.dart';
import 'package:http/testing.dart';

class MockAPI {
  late final Client client;
  MockAPI() {
    client = MockClient((request) async {
      switch (request.url.toString()) {
        case '/api/items':
          return Response('''
              [{"id":1,"brand_id":1,"category_id":1,"name":"01_name","alcohol":5.0,"ibu":10,"description":"01_description","rating":8,"time":"2021-01-01T00:00:00"},
              {"id":2,"brand_id":1,"category_id":1,"name":"02_name","alcohol":6.0,"ibu":21,"description":"02_description","rating":6,"time":"2021-01-01T00:00:01"}]
              ''', 200);
        default:
          return Response('Not Found', 404);
      }
    });
  }
}
