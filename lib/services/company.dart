import 'package:flutter_flavor/flutter_flavor.dart';
import 'package:http/http.dart';
import 'package:perna/helpers/my_decoder.dart';
import 'package:perna/models/bank_account.dart';
import 'package:perna/models/company.dart';

class CompanyService {
  CompanyService({this.myDecoder});

  MyDecoder myDecoder;
  String baseUrl = FlavorConfig.instance.variables['baseUrl'] as String;

  Future<int> createCompany(
      Company company, BankAccount bankAccount, String token) async {
    final Response res = await post(Uri.parse('$baseUrl/createCompany'),
        body: await myDecoder.encode(<String, dynamic>{
          'company': company.toJson(),
          'bankAccount': bankAccount.toJson()
        }),
        headers: <String, String>{'Authorization': token});
    return res.statusCode;
  }

  Future<int> deleteCompany(Company company, String token) async {
    final Response res = await post(Uri.parse('$baseUrl/deleteCompany'),
        body: await myDecoder.encode(company.toJson()),
        headers: <String, String>{'Authorization': token});
    return res.statusCode;
  }

  Future<int> updateCompany(Company company, String token) async {
    final Response res = await post(Uri.parse('$baseUrl/updateCompany'),
        body: await myDecoder.encode(company.toJson()),
        headers: <String, String>{'Authorization': token});
    return res.statusCode;
  }

  Future<int> changeBank(
      Company company, BankAccount bankAccount, String token) async {
    final Response res = await post(Uri.parse('$baseUrl/changeBank'),
        body: await myDecoder.encode(<String, dynamic>{
          'company': company.toJson(),
          'bankAccount': bankAccount.toJson()
        }),
        headers: <String, String>{'Authorization': token});
    return res.statusCode;
  }
}
