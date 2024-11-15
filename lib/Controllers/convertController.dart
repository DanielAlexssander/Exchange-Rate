import 'package:http/http.dart' as http;
import 'dart:convert';

class ConvertController {
  static ConvertController instance = ConvertController();
  final apiKey = '1ee7cf91-c92f-495e-8964-1c60dcbd64ea';

  String data = '';

  convertCurrency(String currency, String convertToCurrency) async {
    try {
      final response = await http.get(
        Uri.parse(
            'https://pro-api.coinmarketcap.com/v1/cryptocurrency/quotes/latest?symbol=${currency}&convert=${convertToCurrency}'),
        headers: {
          'X-CMC_PRO_API_KEY': '${apiKey}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        try {
          var price =
              jsonData['data'][currency]['quote'][convertToCurrency]['price'];
          return price.toStringAsFixed(2);
        } catch (e) {
          return "null";
        }
      } else {
        print('Erro na requisição: ${response.statusCode}');
        return "null";
      }
    } catch (e) {
      print('Erro: $e');
      return "null";
    }
  }
}
