import 'package:app_mobile/core/models/inicio_response.dart';
import 'package:app_mobile/core/service/inicio_service.dart';
import 'package:app_mobile/core/service/token_storage.dart';
import 'package:app_mobile/features/inicio/ui/bloc/inicio_page_bloc.dart';
import 'package:app_mobile/features/reservas/ui/reservas_page.dart';
import 'package:app_mobile/features/incidencias/ui/incidencias_page.dart';
import 'package:app_mobile/features/avisos/ui/avisos_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';

class InicioPage extends StatefulWidget {
  const InicioPage({super.key});

  @override
  State<InicioPage> createState() => _InicioPageState();
}

class _InicioPageState extends State<InicioPage> {
  late final InicioPageBloc inicioPageBloc;
  int _currentIndex = 0;
  String _nombreUsuario = 'Vecino';

  @override
  void initState() {
    super.initState();
    const secureStorage = FlutterSecureStorage();
    final tokenStorage = TokenStorage(secureStorage);
    final inicioService = InicioService(tokenStorage);
    inicioPageBloc = InicioPageBloc(inicioService);
    inicioPageBloc.add(GetAll());
    _loadNombre(tokenStorage);
  }

  Future<void> _loadNombre(TokenStorage tokenStorage) async {
    final nombre = await tokenStorage.getNombre();
    if (nombre != null && mounted) {
      setState(() => _nombreUsuario = nombre);
    }
  }

  @override
  void dispose() {
    inicioPageBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: inicioPageBloc,
      child: BlocListener<InicioPageBloc, InicioPageState>(
        listener: (context, state) {
          if (state is InicioPageError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${state.message}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Scaffold(
          backgroundColor: const Color(0xFFF3F4F6),
          appBar: _buildAppBar(),
          body: IndexedStack(
            index: _currentIndex,
            children: [
              _buildDashboard(),
              const ReservasPage(),
              const IncidenciasPage(),
              const AvisosPage(),
            ],
          ),
          bottomNavigationBar: _buildBottomNav(),
        ),
      ),
    );
  }

  // ─── DASHBOARD ─────────────────────────────────────────────────────────────

  Widget _buildDashboard() {
    return BlocBuilder<InicioPageBloc, InicioPageState>(
      builder: (context, state) {
        if (state is InicioPageLoading || state is InicioPageInitial) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.black),
          );
        }

        if (state is InicioPageError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Error al cargar los datos',
                  style: GoogleFonts.inter(
                      fontSize: 16, color: const Color(0xFF374151)),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => inicioPageBloc.add(GetAll()),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                  child: Text('Reintentar',
                      style: GoogleFonts.inter(color: Colors.white)),
                ),
              ],
            ),
          );
        }

        if (state is InicioPageSuccess) {
          final data = state.inicioResponse;
          return RefreshIndicator(
            color: Colors.black,
            onRefresh: () async {
              inicioPageBloc.add(GetAll());
              await inicioPageBloc.stream.firstWhere(
                  (s) => s is InicioPageSuccess || s is InicioPageError);
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildWelcomeSection(),
                  const SizedBox(height: 12),
                  _buildAccesosRapidos(),
                  const SizedBox(height: 12),
                  _buildEstadisticas(data),
                  const SizedBox(height: 12),
                  _buildFacilitiesOccupation(data.ocupacionInstalaciones),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          );
        }

        return const SizedBox();
      },
    );
  }

  // ─── APP BAR ───────────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          SizedBox(
            height: 32,
            width: 32,
            child: Image.asset('assets/images/Login.png', fit: BoxFit.contain),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Comunidad Vecinal',
                style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF111827)),
              ),
            ],
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
                color: Color(0xFFF3F4F6), shape: BoxShape.circle),
            child: const Icon(Icons.person_outline,
                color: Color(0xFF4B5563), size: 20),
          ),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(color: const Color(0xFFF3F4F6), height: 1),
      ),
    );
  }

  // ─── WELCOME ───────────────────────────────────────────────────────────────

  Widget _buildWelcomeSection() {
    return Container(
      color: Colors.white,
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bienvenido, $_nombreUsuario',
            style: GoogleFonts.inter(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF111827)),
          ),
          const SizedBox(height: 4),
          Text(
            'Resumen de tu actividad',
            style: GoogleFonts.inter(
                fontSize: 13, color: const Color(0xFF6B7280)),
          ),
        ],
      ),
    );
  }

  // ─── ACCESOS RÁPIDOS ───────────────────────────────────────────────────────

  Widget _buildAccesosRapidos() {
    return _buildCard(
      title: 'Accesos Rápidos',
      subtitle: 'Funciones más utilizadas',
      child: Row(
        children: [
          Expanded(
            child: _buildAccesoItem(
              icon: Icons.calendar_month_outlined,
              label: 'Nueva Reserva',
              onTap: () => setState(() => _currentIndex = 1),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildAccesoItem(
              icon: Icons.warning_amber_outlined,
              label: 'Reportar Incidencia',
              onTap: () => setState(() => _currentIndex = 2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccesoItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFF3F4F6)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 28, color: const Color(0xFF1F2937)),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF374151)),
            ),
          ],
        ),
      ),
    );
  }

  // ─── ESTADÍSTICAS ──────────────────────────────────────────────────────────

  Widget _buildEstadisticas(InicioResponse data) {
    return _buildCard(
      title: 'Estadísticas',
      subtitle: 'Resumen general',
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  icon: Icons.calendar_today_rounded,
                  label: 'Reservas Activas',
                  value: '${data.reservasActivas}',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatItem(
                  icon: Icons.error_outline_rounded,
                  label: 'Incidencias Pendientes',
                  value: '${data.incidenciasPendientes}',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  icon: Icons.warning_amber_rounded,
                  label: 'Incidencias Urgentes',
                  value: '${data.incidenciasUrgentes}',
                  urgent: data.incidenciasUrgentes > 0,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatItem(
                  icon: Icons.people_outline_rounded,
                  label: 'Vecinos Registrados',
                  value: '${data.vecinosRegistrados}',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    bool urgent = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: urgent ? const Color(0xFFFEF2F2) : const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: urgent ? const Color(0xFFFECACA) : const Color(0xFFF3F4F6),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon,
              size: 20,
              color: urgent ? Colors.red : const Color(0xFF4B5563)),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: urgent ? Colors.red : const Color(0xFF111827)),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.inter(
                fontSize: 11, color: const Color(0xFF6B7280)),
          ),
        ],
      ),
    );
  }

  // ─── OCUPACIÓN DE INSTALACIONES ────────────────────────────────────────────

  Widget _buildFacilitiesOccupation(List<OcupacionInstalacion> instalaciones) {
    return _buildCard(
      title: 'Ocupación de Instalaciones',
      subtitle: 'Esta semana',
      child: Column(
        children: instalaciones
            .map((i) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildOccupationBar(i.nombre, i.porcentaje / 100),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildOccupationBar(String label, double progress) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF374151)),
            ),
            Text(
              '${(progress * 100).toInt()}%',
              style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF111827)),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            backgroundColor: const Color(0xFFF3F4F6),
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  // ─── HELPER CARD ───────────────────────────────────────────────────────────

  Widget _buildCard({
    IconData? titleIcon,
    required String title,
    String? subtitle,
    Widget? trailing,
    required Widget child,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  if (titleIcon != null) ...[
                    Icon(titleIcon, size: 18, color: const Color(0xFF374151)),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    title,
                    style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF111827)),
                  ),
                ],
              ),
              if (trailing != null) trailing,
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: GoogleFonts.inter(
                  fontSize: 12, color: const Color(0xFF6B7280)),
            ),
          ],
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  // ─── BOTTOM NAV ────────────────────────────────────────────────────────────

  Widget _buildBottomNav() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFF3F4F6))),
      ),
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.home_filled, 'Inicio', 0),
          _buildNavItem(Icons.calendar_month_outlined, 'Reservas', 1),
          _buildNavItem(Icons.error_outline_rounded, 'Incidencias', 2),
          _buildNavItem(Icons.notifications_none_rounded, 'Avisos', 3),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isActive = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() => _currentIndex = index);
        if (index == 0) inicioPageBloc.add(GetAll());
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon,
              color: isActive
                  ? const Color(0xFF111827)
                  : const Color(0xFF9CA3AF),
              size: 22),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                color: isActive
                    ? const Color(0xFF111827)
                    : const Color(0xFF9CA3AF)),
          ),
        ],
      ),
    );
  }
}
