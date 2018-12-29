
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
  printAll(h4s);
}

printAll(List<Element> h4s) {
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
  final out = <List<String>>[];
  final region = reg.children[0].text;
  print(region);
  var next = reg.nextElementSibling;
  while (next != null && next.localName != 'h4') {
    final tbody = next.querySelector('tbody');
    if (tbody != null) {
      out.addAll(extractTownships(tbody));
    }
    next = next.nextElementSibling;
  }
  out.forEach((arr) {
    arr.insert(0, region);
  });
  return out;
}

List<List<String>> extractTownships(Element tbody) {
  final out = <List<String>>[];
  tbody.children.forEach((tr) {
    final district = tr.children[0].text.replaceFirst(' District',  '').trim();
    if (tr.children.length == 2) {
      final text = tr.children[1].text;
      final rm = new RegExp(r'([^\n]+) [Township|Subtownship]').allMatches(
          text);
      final townships = rm.map((m) => m[1].trim()).toSet().toList()
        ..sort();

      townships.forEach((tw) {
        out.add([district, tw]);
      });
    }
  });
  return out;
}

printRegions(String text) {
  final rm = new RegExp(r'(\w+) Region').allMatches(text);
  final regions = rm.map((m) => m[1]).toSet().toList()..sort();
  print(regions);
}