import 'package:flutter/foundation.dart' as foundation;
import 'package:sembast/sembast.dart';
import 'package:sembast/src/api/v2/database.dart';
import 'package:sembast/src/type.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast_io.dart';
import 'package:sembast_web/sembast_web.dart';

class SembastRepository {

  late Database db;
  late StoreRef<Key?, Value?> store;

  init() async {
    store = StoreRef.main();

    if (foundation.kIsWeb) {
      db = await databaseFactoryWeb.openDatabase('cluein_games.db');
    }
    else {
      var dir = await getApplicationDocumentsDirectory();
      await dir.create(recursive: true);
      var dbPath = join(dir.path, 'cluein_games.db');
      db = await databaseFactoryIo.openDatabase(dbPath);
    }
  }

  Future<String?> getString(String key) async {
    return await store.record(key).get(db) as String?;
  }

  Future<void> setString(String key, String value) async {
    await store.record(key).put(db, value);
  }

  Future<List<String>?> readStringList(String key) async {
    return (await store.record(key).get(db) as Iterable<Object?>?)?.map((e) => e.toString()).toList();
  }

  Future<Key?> delete(String key) async {
    return await store.record(key).delete(db);
  }

  Future<void> writeStringList(String key, List<String> value) async {
    await store.record(key).put(db, value);
  }

  SembastRepository() {
    init();
  }
}