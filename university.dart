import 'dart:convert';

import 'package:http/http.dart';
import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart';

main(List<String> args) async {
  final res = await get('https://en.wikipedia.org/wiki/List_of_universities_in_Myanmar');
  final doc = parse(res.body);
  // final text = doc.body.text;
  final h3s = doc.querySelectorAll('h3');
  // final reg = procRegion(h3s[1]);
  final universities = <String, List<String>>{};
  h3s.forEach((reg) {
    universities.addAll(procRegion(reg));
  });
  print(json.encode(universities));
}

Map<String, List<String>> procRegion(Element reg) {
  final name = reg.firstChild.text.trim();
  if (!name.endsWith('Region') && !name.endsWith('State')) return {};
  print(name);
  final ul = reg.nextElementSibling;
  assert (ul.localName == 'ul');
  final lis = ul.querySelectorAll('li');
  final list = lis.map((li) => li.text).toList();
  return {
    name: list,
  };
}