import 'package:flutter/foundation.dart';
class AppState extends ChangeNotifier {
  String language='English';
  void setLanguage(String value){language=value;notifyListeners();}
}
