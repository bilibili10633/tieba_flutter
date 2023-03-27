import 'package:shared_preferences/shared_preferences.dart';

late final LocalStorage finalInstance;

bool storageGet=false;

class LocalStorage{
  final SharedPreferences _preferences;

  static Future<LocalStorage> getInstance()async{
    SharedPreferences instanceShared= await SharedPreferences.getInstance();
    if(!storageGet){
      finalInstance=LocalStorage._internal(instanceShared);
      storageGet=true;
    }
    return finalInstance;
  }
  factory LocalStorage(){
    throw Exception("Using default to create the class is not allowed.Use Storage.getInstance() instead\n"
        "此类不允许使用默认构造器创建！！请使用Storage.getInstance()");
  }
  LocalStorage._internal(this._preferences);

  Future setCookie({required String cookie}){
    return _preferences.setString("cookie", cookie);
  }

  Future<void> saveOtherThings({required String key,required String value})async{
    await _preferences.setString(key, value);
  }

  String? getOtherThings({required String key})=>_preferences.getString(key);


  String? getCookie()=>_preferences.getString("cookie");


}