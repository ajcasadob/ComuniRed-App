import 'package:app_mobile/core/models/inicio_response.dart';
import 'package:app_mobile/core/service/inicio_service.dart';
import 'package:app_mobile/core/service/token_storage.dart';
import 'package:app_mobile/features/inicio/ui/bloc/inicio_page_bloc.dart';
import 'package:app_mobile/features/reservas/ui/reservas_page.dart';
import 'package:app_mobile/features/incidencias/ui/incidencias_page.dart';
import 'package:app_mobile/features/avisos/ui/avisos_page.dart';
import 'package:app_mobile/features/pagos/ui/pagos_page.dart';
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
  late InicioPageBloc inicioPageBloc;
  int _currentIndex = 0; // 👈 controla el tab activo

  @override
  void initState() {
    super.initState();
    const secureStorage = FlutterSecureStorage();
    final tokenStorage = TokenStorage(secureStorage);
    final inicioService = InicioService(tokenStorage);
    inicioPageBloc = InicioPageBloc(inicioService);
    inicioPageBloc.add(GetAll());
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
          backgroundColor: Colors.white,
          appBar: _buildAppBar(),
          // 👇 IndexedStack mantiene todas las páginas en memoria
          // y solo muestra la del índice activo
          body: IndexedStack(
            index: _currentIndex,
            children: [
              _buildDashboard(),         // index 0 - Inicio
              const ReservasPage(),      // index 1
              const IncidenciasPage(),   // index 2
              const AvisosPage(),        // index 3
              const PagosPage(),         // index 4
            ],
          ),
          bottomNavigationBar: _buildBottomNav(),
        ),
      ),
    );
  }

  // ─── DASHBOARD (index 0) ───────────────────────────────────────────────────

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
                    fontSize: 16,
                    color: const Color(0xFF374151),
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => inicioPageBloc.add(GetAll()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                  ),
                  child: Text(
                    'Reintentar',
                    style: GoogleFonts.inter(color: Colors.white),
                  ),
                ),
              ],
            ),
          );
        }

        if (state is InicioPageSuccess) {
          final data = state.inicioResponse;
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildWelcomeSection(),
                _buildStatsGrid(data),
                _buildFacilitiesOccupation(data.ocupacionInstalaciones),
                const SizedBox(height: 100),
              ],
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
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.business, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Text(
            'Comunidad Vecinal',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF111827),
            ),
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
              color: Color(0xFFF3F4F6),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_outline,
              color: Color(0xFF4B5563),
              size: 20,
            ),
          ),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(color: const Color(0xFFF9FAFB), height: 1),
      ),
    );
  }

  // ─── WELCOME ───────────────────────────────────────────────────────────────

  Widget _buildWelcomeSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bienvenido',
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF111827),
              height: 1.1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Resumen de tu comunidad',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: const Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }

  // ─── ESTADÍSTICAS ──────────────────────────────────────────────────────────

  Widget _buildStatsGrid(InicioResponse data) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ESTADÍSTICAS',
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF9CA3AF),
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 12),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.4,
            children: [
              _buildStatCard(
                label: 'Reservas Activas',
                value: '${data.reservasActivas}',
                icon: Icons.calendar_today_rounded,
              ),
              _buildStatCard(
                label: 'Incidencias Pendientes',
                value: '${data.incidenciasPendientes}',
                icon: Icons.error_outline_rounded,
              ),
              _buildStatCard(
                label: 'Incidencias Urgentes',
                value: '${data.incidenciasUrgentes}',
                icon: Icons.warning_amber_rounded,
                urgent: true,
              ),
              _buildStatCard(
                label: 'Tasa de Cobro',
                value: '${data.tasaCobro}%',
                icon: Icons.credit_card_rounded,
              ),
              _buildStatCard(
                label: 'Vecinos Registrados',
                value: '${data.vecinosRegistrados}',
                icon: Icons.people_outline_rounded,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    required IconData icon,
    bool urgent = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: urgent ? const Color(0xFFFEF2F2) : const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: urgent ? const Color(0xFFFECACA) : const Color(0xFFF3F4F6),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(
            icon,
            color: urgent ? Colors.red : const Color(0xFF1F2937),
            size: 24,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: urgent ? Colors.red : const Color(0xFF111827),
                ),
              ),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── OCUPACIÓN DE INSTALACIONES ────────────────────────────────────────────

  Widget _buildFacilitiesOccupation(List<OcupacionInstalacion> instalaciones) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 32, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ocupación de Instalaciones',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Esta semana',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: const Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 16),
          ...instalaciones.map(
            (instalacion) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildOccupationBar(
                instalacion.nombre,
                instalacion.porcentaje / 100,
              ),
            ),
          ),
        ],
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
                color: const Color(0xFF374151),
              ),
            ),
            Text(
              '${(progress * 100).toInt()}%',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF111827),
              ),
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

  // ─── BOTTOM NAV ────────────────────────────────────────────────────────────

  Widget _buildBottomNav() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFF3F4F6)),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.home_filled, 'Inicio', 0),
          _buildNavItem(Icons.calendar_month_outlined, 'Reservas', 1),
          _buildNavItem(Icons.error_outline_rounded, 'Incidencias', 2),
          _buildNavItem(Icons.notifications_none_rounded, 'Avisos', 3),
          _buildNavItem(Icons.credit_card_rounded, 'Pagos', 4),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isActive = _currentIndex == index; // 👈 calculado dinámicamente
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isActive ? const Color(0xFF111827) : const Color(0xFF9CA3AF),
            size: 22,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
              color: isActive
                  ? const Color(0xFF111827)
                  : const Color(0xFF9CA3AF),
            ),
          ),
        ],
      ),
    );
  }
}
