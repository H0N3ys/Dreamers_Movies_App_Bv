import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

class _UserDetailsScreenState extends State<UserDetailsScreen>
    with SingleTickerProviderStateMixin {
  final UserRepository _userRepository = UserRepository();
  final DatabaseHelper _dbHelper = DatabaseHelper();

  UserEntity? _currentUser;

  // Usa el getter fullName de UserEntity (ya corregido para evitar
  // apellidos "sobrantes" de datos antiguos).
  String get _fullName => _currentUser?.fullName ?? '';
  List<Map<String, dynamic>> _chartData = [];
  bool _isLoading = true;

  int? _touchedIndex;

  late final AnimationController _chartAnimController;
  late final Animation<double> _chartAnimation;

  @override
  void initState() {
    super.initState();
    _chartAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    _chartAnimation = CurvedAnimation(
      parent: _chartAnimController,
      curve: Curves.easeOutCubic,
    );
    _loadData();
  }

  @override
  void dispose() {
    _chartAnimController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final user = await _userRepository.getCurrentUser();

      if (user != null) {
        final prefs = await SharedPreferences.getInstance();
        final activeProfileId = prefs.getInt('active_profile_id');
        if (activeProfileId != null) {
          final int idPerfil = activeProfileId;
          final chartData = await _dbHelper.getFavoriteGenresData(idPerfil);

          if (mounted) {
            setState(() {
              _currentUser = user;
              _chartData = chartData;
              _isLoading = false;
            });
            _chartAnimController.forward(from: 0);
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

  // Paleta usada para dar variedad de color por barra (efecto premium)
  static const List<List<Color>> _barGradients = [
    [Color(0xFFFFC371), Color(0xFFFF5F6D)],
    [Color(0xFF43CBFF), Color(0xFF9708CC)],
    [Color(0xFF56CCF2), Color(0xFF2F80ED)],
    [Color(0xFFF7971E), Color(0xFFFFD200)],
    [Color(0xFF00F5A0), Color(0xFF00D9F5)],
    [Color(0xFFFF6A88), Color(0xFFFF99AC)],
    [Color(0xFFA18CD1), Color(0xFFFBC2EB)],
    [Color(0xFF00C6FB), Color(0xFF005BEA)],
  ];

  List<Color> _gradientFor(int index) =>
      _barGradients[index % _barGradients.length];

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
              pw.Text('Nombre: $_fullName'),
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
                            _buildInfoRow(Icons.person, 'Nombre completo', _fullName),
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

                      // 🔥🔥 GRÁFICA DE BARRAS PSEUDO-3D ANIMADA 🔥🔥
                      _buildChartCard(),

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

  // ---------------------------------------------------------------------
  // 🔥 TARJETA CONTENEDORA DE LA GRÁFICA CON PROFUNDIDAD Y BRILLO
  // ---------------------------------------------------------------------
  Widget _buildChartCard() {
    return Container(
      height: 300,
      padding: const EdgeInsets.only(top: 34, right: 26, bottom: 12, left: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.black.withOpacity(0.65),
            Colors.black.withOpacity(0.35),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
        boxShadow: [
          // sombra profunda para "levantar" la tarjeta
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 24,
            offset: const Offset(0, 16),
          ),
          // brillo sutil superior tipo cristal
          BoxShadow(
            color: Colors.white.withOpacity(0.03),
            blurRadius: 1,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Brillo diagonal decorativo (glassmorphism)
          Positioned(
            top: -40,
            right: -40,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.amber.withOpacity(0.12),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          _chartData.isEmpty
              ? const Center(
                  child: Text(
                    'Aún no tienes películas favoritas',
                    style: TextStyle(color: Colors.white54),
                  ),
                )
              : AnimatedBuilder(
                  animation: _chartAnimation,
                  builder: (context, _) {
                    return BarChart(
                      _buildBarChartData(_chartAnimation.value),
                      duration: const Duration(milliseconds: 250),
                    );
                  },
                ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------
  // 🔥 DATA DE LA GRÁFICA CON EFECTO 3D (barras dobles: sombra + frente)
  // ---------------------------------------------------------------------
  BarChartData _buildBarChartData(double animValue) {
    final maxY = _getMaxY();

    return BarChartData(
      alignment: BarChartAlignment.spaceAround,
      maxY: maxY,
      minY: 0,
      groupsSpace: 22,
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: 1,
        getDrawingHorizontalLine: (value) => FlLine(
          color: Colors.white.withOpacity(0.05),
          strokeWidth: 1,
          dashArray: const [5, 5],
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
              final isTouched = _touchedIndex == index;
              return Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: TextStyle(
                    color: isTouched ? Colors.white : _gradientFor(index).first,
                    fontSize: isTouched ? 12 : 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                  child: Text(shortName.toUpperCase()),
                ),
              );
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              if (value % 1 != 0 || value == 0) return const SizedBox.shrink();
              return Text(
                value.toInt().toString(),
                style: const TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold),
              );
            },
            reservedSize: 30,
          ),
        ),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      borderData: FlBorderData(show: false),
      barTouchData: BarTouchData(
        touchTooltipData: BarTouchTooltipData(
          getTooltipColor: (_) => const Color(0xD9000000),
          tooltipBorderRadius: BorderRadius.circular(12),
          tooltipPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          getTooltipItem: (group, groupIndex, rod, rodIndex) {
            final genre = _chartData[group.x.toInt()]['genero'].toString();
            return BarTooltipItem(
              '$genre\n',
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
              children: [
                TextSpan(
                  text: '${rod.toY.toInt()} guardadas',
                  style: TextStyle(color: _gradientFor(group.x.toInt()).first, fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ],
            );
          },
        ),
        touchCallback: (event, response) {
          setState(() {
            if (!event.isInterestedForInteractions || response == null || response.spot == null) {
              _touchedIndex = null;
            } else {
              _touchedIndex = response.spot!.touchedBarGroupIndex;
            }
          });
        },
      ),
      barGroups: List.generate(_chartData.length, (index) {
        double barValue = double.tryParse(_chartData[index]['total'].toString()) ?? 0;
        final animatedValue = barValue * animValue;
        final isTouched = _touchedIndex == index;
        final colors = _gradientFor(index);

        return BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              toY: animatedValue,
              width: isTouched ? 22 : 18,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: isTouched
                    ? colors
                    : colors.map((c) => c.withOpacity(0.85)).toList(),
              ),
              // 🔥 Efecto de "profundidad" detrás de la barra (fake 3D shadow bar)
              rodStackItems: [
                BarChartRodStackItem(
                  0,
                  animatedValue,
                  colors.last.withOpacity(0.0),
                ),
              ],
              backDrawRodData: BackgroundBarChartRodData(
                show: true,
                toY: maxY,
                color: Colors.white.withOpacity(0.04),
              ),
            ),
          ],
          showingTooltipIndicators: isTouched ? [0] : [],
        );
      }),
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