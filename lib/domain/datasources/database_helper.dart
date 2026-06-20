// lib/domain/datasources/database_helper.dart
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
    // ✅ SOLO INICIALIZAR FFI EN PLATAFORMAS DE ESCRITORIO
    if (!kIsWeb) {
      try {
        if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
          sqfliteFfiInit();
          databaseFactory = databaseFactoryFfi;
          print('✅ Inicializado SQLite FFI para escritorio');
        }
      } catch (e) {
        print('⚠️ Error al inicializar FFI: $e');
      }
    } else {
      print('⚠️ Ejecutando en Web - SQLite en modo memoria');
    }

    final directory = await getApplicationDocumentsDirectory();
    final path = join(directory.path, 'cinexa.db');

    print('📁 Base de datos en: $path');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    print('📦 Creando base de datos...');

    // TABLA USUARIO
    await db.execute('''
      CREATE TABLE usuario (
        id_usuario INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT UNIQUE NOT NULL,
        password_hash TEXT NOT NULL,
        nombres TEXT,
        apellidos TEXT,
        telefono TEXT,
        fecha_registro TEXT DEFAULT CURRENT_TIMESTAMP,
        es_activo INTEGER DEFAULT 1
      )
    ''');
    print('✅ Tabla "usuario" creada');

    // TABLA PERFIL
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

    // TABLA PELICULA
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

    // TABLA RESENA
    await db.execute('''
      CREATE TABLE resena (
        id_resena INTEGER PRIMARY KEY AUTOINCREMENT,
        id_perfil INTEGER NOT NULL,
        id_pelicula INTEGER NOT NULL,
        puntuacion INTEGER CHECK (puntuacion >= 1 AND puntuacion <= 5),
        comentario TEXT,
        fecha_creacion TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (id_perfil) REFERENCES perfil(id_perfil) ON DELETE CASCADE,
        FOREIGN KEY (id_pelicula) REFERENCES pelicula(id_pelicula) ON DELETE CASCADE,
        UNIQUE(id_perfil, id_pelicula)
      )
    ''');
    print('✅ Tabla "resena" creada');

    // TABLA FAVORITO
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

    // DATOS DE EJEMPLO - PELÍCULAS
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
    print('✅ 10 películas de ejemplo insertadas');

    print('✅ Base de datos creada exitosamente');
  }

  // ============================================
  // REGISTRO DE USUARIO
  // ============================================
  Future<Map<String, dynamic>?> registerUser(Map<String, dynamic> userData) async {
    final db = await database;

    print('📝 Registrando usuario: ${userData['email']}');

    try {
      // Verificar si el email ya existe
      final existing = await db.query(
        'usuario',
        where: 'email = ?',
        whereArgs: [userData['email']],
      );

      if (existing.isNotEmpty) {
        throw Exception('El email ya está registrado');
      }

      // Insertar usuario
      final userId = await db.insert('usuario', {
        'email': userData['email'],
        'password_hash': userData['password_hash'],
        'nombres': userData['nombres'] ?? '',
        'apellidos': userData['apellidos'] ?? '',
        'telefono': userData['telefono'] ?? '',
        'fecha_registro': DateTime.now().toIso8601String(),
        'es_activo': 1,
      });

      print('✅ Usuario insertado con ID: $userId');

      // Crear perfil por defecto
      await db.insert('perfil', {
        'id_usuario': userId,
        'nombre_perfil': 'Principal',
        'idioma_preferido': 'es',
        'restriccion_infantil': 0,
      });

      print('✅ Perfil creado para usuario ID: $userId');

      final result = await db.query(
        'usuario',
        where: 'id_usuario = ?',
        whereArgs: [userId],
      );

      return result.first;
    } catch (e) {
      print('❌ Error en registerUser: $e');
      rethrow;
    }
  }

  // ============================================
  // LOGIN DE USUARIO
  // ============================================
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
      print('❌ Error en loginUser: $e');
      rethrow;
    }
  }

  // ============================================
  // RESEÑAS Y PELÍCULAS
  // ============================================
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
      // 1. Guardamos la película si no existe (ConflictAlgorithm.ignore evita errores si ya está en la BD)
      await db.insert(
        'pelicula', 
        {
          'id_pelicula': idPelicula, // Usaremos el ID de TMDB aquí
          'titulo': titulo,
          'descripcion': descripcion,
          'url_archivo': 'N/A',
          'caratula_url': caratulaUrl,
          'activo': 1,
        }, 
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );

      // 2. Guardamos la reseña (ConflictAlgorithm.replace actualiza la reseña si el usuario ya había comentado)
      await db.insert(
        'resena', 
        {
          'id_perfil': idPerfil,
          'id_pelicula': idPelicula,
          'puntuacion': rating,
          'comentario': comentario,
          'fecha_creacion': DateTime.now().toIso8601String(),
        }, 
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      print('✅ Reseña guardada localmente para la película: $titulo');
    } catch (e) {
      print('❌ Error al guardar la reseña local: $e');
      throw Exception('Error al guardar la reseña: $e');
    }
  }

  // ============================================
  // UTILIDADES
  // ============================================
  Future<String> getDatabasePath() async {
    final directory = await getApplicationDocumentsDirectory();
    return join(directory.path, 'cinexa.db');
  }
}