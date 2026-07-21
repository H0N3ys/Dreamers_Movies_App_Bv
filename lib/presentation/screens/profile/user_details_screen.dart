import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:dreamers_movies_app_bv/resources/colors/colors.dart';
import 'package:dreamers_movies_app_bv/domain/repositories/user_repositories.dart';
import 'package:dreamers_movies_app_bv/domain/entities/user_entities.dart';
import 'package:dreamers_movies_app_bv/domain/datasources/database_helper.dart';

class UserDetailsScreen extends StatefulWidget {
  static const name = 'user-details-screen';
  const UserDetailsScreen({super.key});

  @override
  State<UserDetailsScreen> createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends State<UserDetailsScreen> {
  final UserRepository _userRepository = UserRepository();
  final DatabaseHelper _dbHelper = DatabaseHelper();
  
  UserEntity? _currentUser;
  List<Map<String, dynamic>> _chartData = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final user = await _userRepository.getCurrentUser();
      
      if (user != null) {
        final db = await _dbHelper.database;
        final profileResult = await db.query(
          'perfil',
          where: 'id_usuario = ?',
          whereArgs: [user.id],
          limit: 1,
        );

        if (profileResult.isNotEmpty) {
          final int idPerfil = profileResult.first['id_perfil'] as int;
          final chartData = await _dbHelper.getFavoriteGenresData(idPerfil);
          
          if (mounted) {
            setState(() {
              _currentUser = user;
              _chartData = chartData;
              _isLoading = false;
            });
          }
          return;
        }
      }
      
      if (mounted) setState(() => _isLoading = false);
    } catch (e) {
      debugPrint('Error cargando detalles del usuario: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // 🔥 FUNCIÓN DE SEGURIDAD PARA EL TAMAÑO DE LA GRÁFICA
  double _getMaxY() {
    if (_chartData.isEmpty) return 10.0;
    double maxVal = 0;
    for (var item in _chartData) {
      double val = double.tryParse(item['total'].toString()) ?? 0;
      if (val > maxVal) maxVal = val;
    }
    return maxVal + 2;
  }

  // 🔥 FUNCIÓN PARA GENERAR EL PDF
  Future<void> _generateAndPrintPdf() async {
    if (_currentUser == null) return;

    final doc = pw.Document();

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(level: 0, child: pw.Text('Reporte de Perfil - Cinexa', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold))),
              pw.SizedBox(height: 20),
              pw.Text('Datos del Usuario:', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              pw.Text('Nombre: ${_currentUser!.nombres} ${_currentUser!.apellidos}'),
              pw.Text('Correo: ${_currentUser!.email}'),
              pw.Text('Teléfono: ${(_currentUser!.telefono == null || _currentUser!.telefono!.isEmpty) ? "No registrado" : _currentUser!.telefono}'),
              pw.SizedBox(height: 30),
              pw.Text('Estadísticas de Películas Favoritas:', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              
              if (_chartData.isEmpty)
                pw.Text('No hay películas guardadas aún.')
              else
                pw.TableHelper.fromTextArray(
                  context: context,
                  data: <List<String>>[
                    <String>['Categoría', 'Total Guardadas'],
                    ..._chartData.map((data) => [data['genero'].toString(), data['total'].toString()]),
                  ],
                ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => doc.save(),
      name: 'Reporte_Cinexa_${_currentUser!.nombres}.pdf',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondaryColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Detalles de Cuenta', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : _currentUser == null
              ? const Center(child: Text('Error al cargar perfil', style: TextStyle(color: Colors.white)))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // TARJETA DE DATOS DEL USUARIO
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('INFORMACIÓN PERSONAL', style: TextStyle(color: Colors.white54, fontSize: 12, letterSpacing: 1.5)),
                            const SizedBox(height: 15),
                            _buildInfoRow(Icons.person, 'Nombre completo', '${_currentUser!.nombres} ${_currentUser!.apellidos}'),
                            const SizedBox(height: 15),
                            _buildInfoRow(Icons.email, 'Correo electrónico', _currentUser!.email),
                            const SizedBox(height: 15),
                            _buildInfoRow(Icons.phone, 'Teléfono', (_currentUser!.telefono == null || _currentUser!.telefono!.isEmpty) ? 'No registrado' : _currentUser!.telefono!),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 40),
                      const Text('TUS CATEGORÍAS FAVORITAS', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 20),

                      // GRÁFICA DE BARRAS EN VIVO
                     // 🔥 GRÁFICA DE BARRAS INSANA EN VIVO 🔥
                      Container(
                        height: 280, // Un poco más alta
                        padding: const EdgeInsets.only(top: 30, right: 25, bottom: 10, left: 10),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Colors.black.withOpacity(0.6), Colors.black.withOpacity(0.3)],
                          ),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.white12),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 15, offset: const Offset(0, 10)),
                          ],
                        ),
                        child: _chartData.isEmpty 
                          ? const Center(child: Text('Aún no tienes películas favoritas', style: TextStyle(color: Colors.white54)))
                          : BarChart(
                              BarChartData(
                                alignment: BarChartAlignment.spaceAround,
                                maxY: _getMaxY(),
                                // 🔥 Cuadriculado sutil de fondo
                                gridData: FlGridData(
                                  show: true,
                                  drawVerticalLine: false,
                                  horizontalInterval: 1, // Una línea por cada película
                                  getDrawingHorizontalLine: (value) => FlLine(
                                    color: Colors.white.withOpacity(0.05),
                                    strokeWidth: 1,
                                    dashArray: [5, 5], // Efecto de línea punteada
                                  ),
                                ),
                                titlesData: FlTitlesData(
                                  show: true,
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      getTitlesWidget: (double value, TitleMeta meta) {
                                        int index = value.toInt();
                                        if (index < 0 || index >= _chartData.length) return const SizedBox.shrink();
                                        String genre = _chartData[index]['genero'].toString();
                                        String shortName = genre.length >= 3 ? genre.substring(0, 3) : genre;
                                        return Padding(
                                          padding: const EdgeInsets.only(top: 12.0),
                                          child: Text(
                                            shortName.toUpperCase(),
                                            style: const TextStyle(color: Colors.amber, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  leftTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      // 🔥 Forzamos a que solo muestre números enteros (1, 2, 3...) sin decimales repetidos
                                      getTitlesWidget: (value, meta) {
                                        if (value % 1 != 0 || value == 0) return const SizedBox.shrink();
                                        return Text(value.toInt().toString(), style: const TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold));
                                      },
                                      reservedSize: 30,
                                    ),
                                  ),
                                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                ),
                                borderData: FlBorderData(show: false),
                                barGroups: List.generate(_chartData.length, (index) {
                                  double barValue = double.tryParse(_chartData[index]['total'].toString()) ?? 0;
                                  return BarChartGroupData(
                                    x: index,
                                    barRods: [
                                      BarChartRodData(
                                        toY: barValue,
                                        // 🔥 Degradado de colores para la barra
                                        gradient: const LinearGradient(
                                          colors: [Colors.orangeAccent, Colors.amber],
                                          begin: Alignment.bottomCenter,
                                          end: Alignment.topCenter,
                                        ),
                                        width: 18,
                                        borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                                        backDrawRodData: BackgroundBarChartRodData(
                                          show: true,
                                          toY: _getMaxY(),
                                          color: Colors.white.withOpacity(0.05), // Sombra de la barra al fondo
                                        )
                                      ),
                                    ],
                                  );
                                }),
                              ),
                            ),
                      ),

                      const SizedBox(height: 40),

                      // BOTÓN DE DESCARGA PDF
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton.icon(
                          onPressed: _generateAndPrintPdf,
                          icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
                          label: const Text('Generar Reporte PDF', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            elevation: 5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.white54, size: 24),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    );
  }
}