import 'dart:convert';

import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter/cupertino.dart';
import 'package:get_storage/get_storage.dart';
import 'package:table_now_app/config.dart';

class MyCrypt {
  
  static MyCrypt mycrypt = MyCrypt();


  // 복호화
  // k: FAF98C06EF4C39584964750C2DE67006
  // i: 5468697320697320616E204956343536
  String ase_decrypt(String k, String i) {
    
    try{
      String? encryptedData = GetStorage().read<String>(storageTossKey);
      if(encryptedData == null) return '';
      final encrypter = encrypt.Encrypter(encrypt.AES(encrypt.Key.fromUtf8(k), mode: encrypt.AESMode.cbc));
      final decrypted = encrypter.decrypt(encrypt.Encrypted.from64(encryptedData), iv: encrypt.IV.fromBase16(i));

      return decrypted;
    }catch(error){
      debugPrint('Decrypt ERROR: $error');
      return '';
    }
   
  }

  
}
