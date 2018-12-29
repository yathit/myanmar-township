
import 'dart:convert';

import 'package:http/http.dart';
import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart';

main(List<String> args) async {
  final res = await get('https://en.wikipedia.org/wiki/Townships_of_Myanmar#Yangon_Region');
  final doc = parse(res.body);
  // final text = doc.body.text;
  final h4s = doc.querySelectorAll('h4');

  // printRegion(h4s[0]); // Magway Region
  // printRegion(h4s[3]); // Kayah State
  // printRegion(h4s[4]); // Shan State
  // printRegion(h4s[14]); // Rakhine State
  // printCsv(h4s);
  printJson(h4s);

}

printJson(List<Element> h4s) {
  final regions = <String, Map<String, List<String>>>{};
  h4s.forEach((reg) {
    final region = reg.children[0].text;
    regions[region] = processRegion(reg);
  });

  print(json.encode(regions));
}

printCsv(List<Element> h4s) {
  final list = <List<String>>[];
  h4s.forEach((reg) {
    final townships = procRegion(reg);
    list.addAll(townships);
  });
  list.forEach((x) {
    print(x.join(', '));
  });
}

printRegion(Element reg) {
  final region = procRegion(reg);
  region.forEach((x) {
    print(x.join(', '));
  });
}

List<List<String>> procRegion(Element reg) {
  final region = reg.children[0].text;
  final out = processRegion(reg);
  final list = <List<String>>[];

  out.keys.forEach((district) {
    out[district].forEach((tw) {
      list.add([region, district, tw]);
    });
  });
  return list;
}

Map<String, List<String>> processRegion(Element reg) {
  final out = <String, List<String>>{};
  final region = reg.children[0].text;
  // print(region);
  var next = reg.nextElementSibling;
  while (next != null && next.localName != 'h4') {
    final tbody = next.querySelector('tbody');
    if (tbody != null) {
      out.addAll(extractTownship(tbody));
    }
    next = next.nextElementSibling;
  }

  return out;
}

List<List<String>> extractTownships(Element tbody) {
  final out = extractTownship(tbody);
  final list = <List<String>>[];
  out.keys.forEach((district) {
    out[district].forEach((tw) {
      list.add([district, tw]);
    });
  });
  return list;
}

Map<String, List<String>> extractTownship(Element tbody) {
  final out = <String, List<String>>{};
  tbody.children.forEach((tr) {
    final district = tr.children[0].text.replaceFirst(' District',  '').trim();
    if (tr.children.length == 2) {
      final text = tr.children[1].text;
      final rm = new RegExp(r'([^\n]+) [Township|Subtownship]').allMatches(
          text);
      final townships = rm.map((m) => m[1].trim()).toSet().toList()
        ..sort();

      if (townships.length > 0) {
        out.putIfAbsent(district, () => <String>[]);
        out[district].addAll(townships);
      }
    }
  });
  return out;
}

printRegions(String text) {
  final rm = new RegExp(r'(\w+) Region').allMatches(text);
  final regions = rm.map((m) => m[1]).toSet().toList()..sort();
  print(regions);
}