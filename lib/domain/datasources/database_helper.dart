import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    if (!kIsWeb) {
      try {
        if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
          sqfliteFfiInit();
          databaseFactory = databaseFactoryFfi;
          print(' Inicializado SQLite FFI para escritorio');
        }
      } catch (e) {
        print(' Error al inicializar FFI: $e');
      }
    } else {
      print(' Ejecutando en Web - SQLite en modo memoria');
    }

    final directory = await getApplicationDocumentsDirectory();
    final path = join(directory.path, 'cinexa.db');

    print(' Base de datos en: $path');
    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    print(
      ' Actualizando base de datos de versión $oldVersion a $newVersion...',
    );

    if (oldVersion < 2) {
      final info = await db.rawQuery("PRAGMA table_info('usuario')");
      final hasApodoColumn = info.any((column) => column['name'] == 'apodo');

      if (!hasApodoColumn) {
        await db.execute(
          'ALTER TABLE usuario ADD COLUMN apodo TEXT DEFAULT ""',
        );
        print('✅ Columna "apodo" añadida a la tabla usuario');
      }
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    print(' Creando base de datos...');
    await db.execute('''
      CREATE TABLE usuario (
        id_usuario INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT UNIQUE NOT NULL,
        password_hash TEXT NOT NULL,
        nombres TEXT,
        apellidos TEXT,
        telefono TEXT,
        apodo TEXT DEFAULT '',
        fecha_registro TEXT DEFAULT CURRENT_TIMESTAMP,
        es_activo INTEGER DEFAULT 1
      )
    ''');
    print('✅ Tabla "usuario" creada');

    await db.execute('''
      CREATE TABLE perfil (
        id_perfil INTEGER PRIMARY KEY AUTOINCREMENT,
        id_usuario INTEGER NOT NULL,
        nombre_perfil TEXT NOT NULL,
        avatar_url TEXT,
        idioma_preferido TEXT DEFAULT 'es',
        restriccion_infantil INTEGER DEFAULT 0,
        FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario) ON DELETE CASCADE
      )
    ''');
    print('✅ Tabla "perfil" creada');

    await db.execute('''
      CREATE TABLE pelicula (
        id_pelicula INTEGER PRIMARY KEY AUTOINCREMENT,
        titulo TEXT NOT NULL,
        descripcion TEXT,
        duracion_minutos INTEGER,
        anio_lanzamiento INTEGER,
        genero TEXT,
        url_archivo TEXT,
        caratula_url TEXT,
        fecha_subida TEXT DEFAULT CURRENT_TIMESTAMP,
        activo INTEGER DEFAULT 1
      )
    ''');
    print('✅ Tabla "pelicula" creada');

    await db.execute('''
      CREATE TABLE resena (
        id_resena INTEGER PRIMARY KEY AUTOINCREMENT,
        id_perfil INTEGER NOT NULL,
        id_pelicula INTEGER NOT NULL,
        puntuacion INTEGER CHECK (puntuacion >= 1 AND puntuacion <= 5),
        comentario TEXT,
        fecha_creacion TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (id_perfil) REFERENCES perfil(id_perfil) ON DELETE CASCADE,
        FOREIGN KEY (id_pelicula) REFERENCES pelicula(id_pelicula) ON DELETE CASCADE
      )
    ''');
    print('✅ Tabla "resena" creada');

    await db.execute('''
      CREATE TABLE favorito (
        id_favorito INTEGER PRIMARY KEY AUTOINCREMENT,
        id_perfil INTEGER NOT NULL,
        id_pelicula INTEGER NOT NULL,
        fecha_agregado TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (id_perfil) REFERENCES perfil(id_perfil) ON DELETE CASCADE,
        FOREIGN KEY (id_pelicula) REFERENCES pelicula(id_pelicula) ON DELETE CASCADE,
        UNIQUE(id_perfil, id_pelicula)
      )
    ''');
    print('✅ Tabla "favorito" creada');

    await db.execute('''
      INSERT INTO pelicula (titulo, descripcion, duracion_minutos, anio_lanzamiento, genero, caratula_url, activo) VALUES
      ('Inception', 'Un ladrón que roba secretos del subconsciente', 148, 2010, 'Ciencia Ficción', 'inception.jpg', 1),
      ('The Matrix', 'Un programador descubre la realidad simulada', 136, 1999, 'Acción', 'matrix.jpg', 1),
      ('Interstellar', 'Un equipo de exploradores viaja por un agujero de gusano', 169, 2014, 'Ciencia Ficción', 'interstellar.jpg', 1),
      ('El Padrino', 'La historia de la familia Corleone', 175, 1972, 'Drama', 'godfather.jpg', 1),
      ('Toy Story', 'Un vaquero y un astronauta compiten por el afecto de su dueño', 81, 1995, 'Animación', 'toystory.jpg', 1),
      ('Avatar', 'Un marine en un planeta alienígena', 162, 2009, 'Ciencia Ficción', 'avatar.jpg', 1),
      ('Titanic', 'El amor en el barco más famoso', 195, 1997, 'Romance', 'titanic.jpg', 1),
      ('The Dark Knight', 'El caballero de la noche contra el Joker', 152, 2008, 'Acción', 'darkknight.jpg', 1),
      ('Forrest Gump', 'La vida de un hombre extraordinario', 142, 1994, 'Drama', 'forrestgump.jpg', 1),
      ('Gladiador', 'Un general romano busca venganza', 155, 2000, 'Acción', 'gladiator.jpg', 1)
    ''');
    print(' 10 películas de ejemplo insertadas');
    print(' Base de datos creada exitosamente');
  }

  Future<Map<String, dynamic>?> registerUser(
    Map<String, dynamic> userData,
  ) async {
    final db = await database;
    print(' Registrando usuario: ${userData['email']}');

    try {
      final existing = await db.query(
        'usuario',
        where: 'email = ?',
        whereArgs: [userData['email']],
      );
      if (existing.isNotEmpty) {
        throw Exception('El email ya está registrado');
      }

      final userId = await db.insert('usuario', {
        'email': userData['email'],
        'password_hash': userData['password_hash'],
        'nombres': userData['nombres'] ?? '',
        'apellidos': userData['apellidos'] ?? '',
        'telefono': userData['telefono'] ?? '',
        'apodo': userData['apodo'] ?? userData['nombres'] ?? '',
        'fecha_registro': DateTime.now().toIso8601String(),
        'es_activo': 1,
      });
      print('✅ Usuario insertado con ID: $userId');

      await db.insert('perfil', {
        'id_usuario': userId,
        'nombre_perfil': 'Principal',
        'idioma_preferido': 'es',
        'restriccion_infantil': 0,
      });
      print(' Perfil creado para usuario ID: $userId');

      final result = await db.query(
        'usuario',
        where: 'id_usuario = ?',
        whereArgs: [userId],
      );
      return result.first;
    } catch (e) {
      print(' Error en registerUser: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> loginUser(String email, String password) async {
    final db = await database;
    try {
      final result = await db.query(
        'usuario',
        where: 'email = ? AND password_hash = ? AND es_activo = 1',
        whereArgs: [email, password],
      );
      return result.isNotEmpty ? result.first : null;
    } catch (e) {
      print(' Error en loginUser: $e');
      rethrow;
    }
  }

  Future<void> saveReviewLocal({
    required int idPerfil,
    required int idPelicula,
    required String titulo,
    required String descripcion,
    required String caratulaUrl,
    required int rating,
    required String comentario,
  }) async {
    final db = await database;
    try {
      await db.insert('pelicula', {
        'id_pelicula': idPelicula,
        'titulo': titulo,
        'descripcion': descripcion,
        'url_archivo': 'N/A',
        'caratula_url': caratulaUrl,
        'activo': 1,
      }, conflictAlgorithm: ConflictAlgorithm.ignore);

      await db.insert('resena', {
        'id_perfil': idPerfil,
        'id_pelicula': idPelicula,
        'puntuacion': rating,
        'comentario': comentario,
        'fecha_creacion': DateTime.now().toIso8601String(),
      }, conflictAlgorithm: ConflictAlgorithm.abort);
      print(' Reseña guardada localmente para la película: $titulo');
    } catch (e) {
      print(' Error al guardar la reseña local: $e');
      throw Exception('Error al guardar la reseña: $e');
    }
  }

  Future<String> getDatabasePath() async {
    final directory = await getApplicationDocumentsDirectory();
    return join(directory.path, 'cinexa.db');
  }

  Future<Map<String, dynamic>?> authOrRegisterWithGoogle({
    required String email,
    required String googleId,
    required String nombres,
    required String apellidos,
  }) async {
    final db = await database;
    print(' Procesando Google Sign-In para: $email');

    try {
      final existing = await db.query(
        'usuario',
        where: 'email = ? AND es_activo = 1',
        whereArgs: [email],
      );

      if (existing.isNotEmpty) {
        print('✅ Usuario de Google ya registrado. Iniciando sesión...');
        return existing.first;
      }

      print(
        '🆕 El usuario no existe. Creando registro local con datos de Google...',
      );
      final userId = await db.insert('usuario', {
        'email': email,
        'password_hash': 'GOOGLE_$googleId',
        'nombres': nombres,
        'apellidos': apellidos,
        'telefono': '',
        'apodo': nombres,
        'fecha_registro': DateTime.now().toIso8601String(),
        'es_activo': 1,
      });

      await db.insert('perfil', {
        'id_usuario': userId,
        'nombre_perfil': 'Principal',
        'idioma_preferido': 'es',
        'restriccion_infantil': 0,
      });

      final result = await db.query(
        'usuario',
        where: 'id_usuario = ?',
        whereArgs: [userId],
      );
      return result.first;
    } catch (e) {
      print('❌ Error en authOrRegisterWithGoogle: $e');
      rethrow;
    }
  }

  // =========================================================================
  // 🔥 GRÁFICA: Conteo INTELIGENTE separando géneros individuales
  // =========================================================================
  Future<List<Map<String, dynamic>>> getFavoriteGenresData(int idPerfil) async {
    final db = await database;
    try {
      final result = await db.rawQuery(
        '''
        SELECT p.genero
        FROM favorito f
        JOIN pelicula p ON f.id_pelicula = p.id_pelicula
        WHERE f.id_perfil = ?
      ''',
        [idPerfil],
      );

      Map<String, int> conteoGeneros = {};

      for (var row in result) {
        String generosRaw = row['genero'].toString();
        List<String> generosLista = generosRaw.split(',');
        for (String gen in generosLista) {
          String generoLimpio = gen.trim();
          if (generoLimpio.isNotEmpty && generoLimpio != 'Desconocido') {
            conteoGeneros[generoLimpio] =
                (conteoGeneros[generoLimpio] ?? 0) + 1;
          }
        }
      }

      List<Map<String, dynamic>> finalData = [];
      conteoGeneros.forEach((key, value) {
        finalData.add({'genero': key, 'total': value});
      });

      finalData.sort((a, b) => b['total'].compareTo(a['total']));
      return finalData;
    } catch (e) {
      return [];
    }
  }

  // =========================================================================
  // 🔥 FUNCIONES PARA FAVORITOS (RESTAURADAS)
  // =========================================================================
  Future<List<Map<String, dynamic>>> getFavoriteMoviesByUser(
    int idPerfil,
  ) async {
    final db = await database;
    try {
      return await db.rawQuery(
        '''
        SELECT p.*
        FROM favorito f
        JOIN pelicula p ON f.id_pelicula = p.id_pelicula
        WHERE f.id_perfil = ?
        ORDER BY f.fecha_agregado DESC
      ''',
        [idPerfil],
      );
    } catch (e) {
      return [];
    }
  }

  Future<void> removeFavoriteLocal(int idPerfil, int idPelicula) async {
    final db = await database;
    try {
      await db.delete(
        'favorito',
        where: 'id_perfil = ? AND id_pelicula = ?',
        whereArgs: [idPerfil, idPelicula],
      );
    } catch (e) {}
  }

  Future<void> addFavoriteLocal({
    required int idPerfil,
    required int idPelicula,
    required String titulo,
    required String descripcion,
    required String caratulaUrl,
    required String genero,
  }) async {
    final db = await database;
    try {
      await db.insert('pelicula', {
        'id_pelicula': idPelicula,
        'titulo': titulo,
        'descripcion': descripcion,
        'url_archivo': 'N/A',
        'caratula_url': caratulaUrl,
        'genero': genero,
        'activo': 1,
      }, conflictAlgorithm: ConflictAlgorithm.ignore);

      await db.insert('favorito', {
        'id_perfil': idPerfil,
        'id_pelicula': idPelicula,
        'fecha_agregado': DateTime.now().toIso8601String(),
      }, conflictAlgorithm: ConflictAlgorithm.ignore);
    } catch (e) {}
  }

  Future<bool> isFavoriteLocal(int idPerfil, int idPelicula) async {
    final db = await database;
    final result = await db.query(
      'favorito',
      where: 'id_perfil = ? AND id_pelicula = ?',
      whereArgs: [idPerfil, idPelicula],
    );
    return result.isNotEmpty;
  }

  // =========================================================================
  // 🔥 FUNCIONES PARA "MIS GUARDADOS" MULTIUSUARIO
  // =========================================================================
  Future<void> _ensureGuardadoTableExists(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS guardado (
        id_guardado INTEGER PRIMARY KEY AUTOINCREMENT,
        id_perfil INTEGER NOT NULL,
        id_pelicula INTEGER NOT NULL,
        fecha_agregado TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (id_perfil) REFERENCES perfil(id_perfil) ON DELETE CASCADE,
        FOREIGN KEY (id_pelicula) REFERENCES pelicula(id_pelicula) ON DELETE CASCADE,
        UNIQUE(id_perfil, id_pelicula)
      )
    ''');
  }

  Future<List<Map<String, dynamic>>> getSavedMoviesByUser(int idPerfil) async {
    final db = await database;
    await _ensureGuardadoTableExists(db);
    try {
      return await db.rawQuery(
        '''
        SELECT p.*
        FROM guardado g
        JOIN pelicula p ON g.id_pelicula = p.id_pelicula
        WHERE g.id_perfil = ?
        ORDER BY g.fecha_agregado DESC
      ''',
        [idPerfil],
      );
    } catch (e) {
      return [];
    }
  }

  Future<void> removeSavedLocal(int idPerfil, int idPelicula) async {
    final db = await database;
    await _ensureGuardadoTableExists(db);
    try {
      await db.delete(
        'guardado',
        where: 'id_perfil = ? AND id_pelicula = ?',
        whereArgs: [idPerfil, idPelicula],
      );
    } catch (e) {}
  }

  Future<void> addSavedLocal({
    required int idPerfil,
    required int idPelicula,
    required String titulo,
    required String descripcion,
    required String caratulaUrl,
    required String genero,
  }) async {
    final db = await database;
    await _ensureGuardadoTableExists(db);
    try {
      await db.insert('pelicula', {
        'id_pelicula': idPelicula,
        'titulo': titulo,
        'descripcion': descripcion,
        'url_archivo': 'N/A',
        'caratula_url': caratulaUrl,
        'genero': genero,
        'activo': 1,
      }, conflictAlgorithm: ConflictAlgorithm.ignore);

      await db.insert('guardado', {
        'id_perfil': idPerfil,
        'id_pelicula': idPelicula,
        'fecha_agregado': DateTime.now().toIso8601String(),
      }, conflictAlgorithm: ConflictAlgorithm.ignore);
    } catch (e) {}
  }

  Future<bool> isSavedLocal(int idPerfil, int idPelicula) async {
    final db = await database;
    await _ensureGuardadoTableExists(db);
    final result = await db.query(
      'guardado',
      where: 'id_perfil = ? AND id_pelicula = ?',
      whereArgs: [idPerfil, idPelicula],
    );
    return result.isNotEmpty;
  }

  //  Actualizar datos de usuario (Nombres, Apellidos, Teléfono)
  Future<bool> updateUserData({
    required String userId,
    required String nombres,
    required String apellidos,
    required String alias,
    String? telefono,
  }) async {
    final db = await database;
    try {
      int count = await db.update(
        'usuario',
        {
          'nombres': nombres,
          'apellidos': apellidos,
          'telefono': telefono ?? '',
          'apodo': alias,
        },
        where: 'id_usuario = ?',
        whereArgs: [int.parse(userId)],
      );
      return count > 0;
    } catch (e) {
      print('❌ Error al actualizar datos de usuario: $e');
      return false;
    }
  }

  // Actualizar Avatar / Foto de perfil
  Future<List<Map<String, dynamic>>> getProfilesByUser(int userId) async {
    final db = await database;
    try {
      return await db.query(
        'perfil',
        where: 'id_usuario = ?',
        whereArgs: [userId],
        orderBy: 'id_perfil ASC',
      );
    } catch (e) {
      print('❌ Error al consultar perfiles: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> getProfileById(int profileId) async {
    final db = await database;
    try {
      final result = await db.query(
        'perfil',
        where: 'id_perfil = ?',
        whereArgs: [profileId],
        limit: 1,
      );
      return result.isNotEmpty ? result.first : null;
    } catch (e) {
      print('❌ Error al consultar perfil por id: $e');
      return null;
    }
  }

  Future<int?> createProfileForUser({
    required int userId,
    required String nombrePerfil,
    String? avatarUrl,
  }) async {
    final db = await database;
    try {
      final profileId = await db.insert('perfil', {
        'id_usuario': userId,
        'nombre_perfil': nombrePerfil,
        'avatar_url': avatarUrl,
        'idioma_preferido': 'es',
        'restriccion_infantil': 0,
      });
      return profileId;
    } catch (e) {
      print('❌ Error al crear perfil: $e');
      return null;
    }
  }

  Future<bool> updateProfileAvatarById({
    required int profileId,
    required String avatarPath,
  }) async {
    final db = await database;
    try {
      final count = await db.update(
        'perfil',
        {'avatar_url': avatarPath},
        where: 'id_perfil = ?',
        whereArgs: [profileId],
      );
      return count > 0;
    } catch (e) {
      print('❌ Error al actualizar avatar por perfil: $e');
      return false;
    }
  }

  Future<bool> updateProfileNameById({
    required int profileId,
    required String nombrePerfil,
  }) async {
    final db = await database;
    try {
      final count = await db.update(
        'perfil',
        {'nombre_perfil': nombrePerfil},
        where: 'id_perfil = ?',
        whereArgs: [profileId],
      );
      return count > 0;
    } catch (e) {
      print('❌ Error al actualizar nombre de perfil: $e');
      return false;
    }
  }

  Future<bool> updateUserAvatar({
    required String userId,
    required String avatarPath,
  }) async {
    final db = await database;
    try {
      int count = await db.update(
        'perfil',
        {'avatar_url': avatarPath},
        where: 'id_usuario = ?',
        whereArgs: [int.parse(userId)],
      );
      return count > 0;
    } catch (e) {
      print('❌ Error al actualizar avatar: $e');
      return false;
    }
  }

  // Cambiar contraseña validando la actual
  Future<bool> changePassword({
    required String userId,
    required String currentPassword,
    required String newPassword,
  }) async {
    final db = await database;
    try {
      // Verificamos que la contraseña actual sea correcta
      final user = await db.query(
        'usuario',
        where: 'id_usuario = ? AND password_hash = ?',
        whereArgs: [int.parse(userId), currentPassword],
      );

      if (user.isEmpty) {
        return false; // Contraseña actual incorrecta
      }

      // Actualizamos a la nueva contraseña
      int count = await db.update(
        'usuario',
        {'password_hash': newPassword},
        where: 'id_usuario = ?',
        whereArgs: [int.parse(userId)],
      );
      return count > 0;
    } catch (e) {
      print('❌ Error al cambiar contraseña: $e');
      return false;
    }
  }
}
