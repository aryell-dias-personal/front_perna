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

  Future<int> deleteCompany(String companyId, String token) async {
    final Response res = await post(Uri.parse('$baseUrl/deleteCompany'),
        body: await myDecoder.encode(<String, dynamic>{
          'companyId': companyId,
        }),
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
      String companyId, BankAccount bankAccount, String token) async {
    final Response res = await post(Uri.parse('$baseUrl/changeBank'),
        body: await myDecoder.encode(<String, dynamic>{
          'companyId': companyId,
          'bankAccount': bankAccount.toJson()
        }),
        headers: <String, String>{'Authorization': token});
    return res.statusCode;
  }

  Future<int> answerManager(String companyId, String token,
      {bool accepted}) async {
    final String body = await myDecoder.encode(
        <String, dynamic>{'companyId': companyId, 'accepted': accepted});
    final Response res = await post(Uri.parse('$baseUrl/answerManager'),
        body: body, headers: <String, String>{'Authorization': token});
    return res.statusCode;
  }

  Future<int> askEmployee(
      String companyId, String employeeEmail, String token) async {
    final Response res = await post(Uri.parse('$baseUrl/askEmployee'),
        body: await myDecoder.encode(
            <String, dynamic>{'companyId': companyId, 'employee': employeeEmail}),
        headers: <String, String>{'Authorization': token});
    return res.statusCode;
  }
}
