import 'package:app_mobile/core/models/incidencias_response.dart';
import 'package:app_mobile/core/service/incidencias_service.dart';
import 'package:app_mobile/core/service/token_storage.dart';
import 'package:app_mobile/features/incidencias/ui/bloc/incidencia_page_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';

class IncidenciasPage extends StatefulWidget {
  const IncidenciasPage({super.key});

  @override
  State<IncidenciasPage> createState() => _IncidenciasPageState();
}

class _IncidenciasPageState extends State<IncidenciasPage> {
  late final IncidenciaPageBloc incidenciaPageBloc;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    const secureStorage = FlutterSecureStorage();
    final tokenStorage = TokenStorage(secureStorage);
    final incidenciasService = IncidenciasService(tokenStorage);
    incidenciaPageBloc = IncidenciaPageBloc(incidenciasService);
    incidenciaPageBloc.add(GetIncidencias());
    _initialized = true;
  }

  @override
  void dispose() {
    incidenciaPageBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const Center(child: CircularProgressIndicator(color: Colors.black));
    }

    return BlocProvider.value(
      value: incidenciaPageBloc,
      child: BlocListener<IncidenciaPageBloc, IncidenciaPageState>(
        listener: (context, state) {
          if (state is IncidenciaPageError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${state.message}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: BlocBuilder<IncidenciaPageBloc, IncidenciaPageState>(
          builder: (context, state) {
            if (state is IncidenciaPageInitial || state is IncidenciaPageLoading) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.black),
              );
            }

            if (state is IncidenciaPageError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      'Error al cargar las incidencias',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        color: const Color(0xFF374151),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => incidenciaPageBloc.add(GetIncidencias()),
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

            if (state is IncidenciaPageLoaded) {
              return _buildContent(state.incidencias);
            }

            return const SizedBox();
          },
        ),
      ),
    );
  }

  // ─── CONTENIDO ─────────────────────────────────────────────────────────────

  Widget _buildContent(List<IncidenciasResponse> incidencias) {
    final int pendientes = incidencias
        .where((i) => i.estado.toLowerCase() == 'pendiente')
        .length;
    final int enProceso = incidencias
        .where((i) => i.estado.toLowerCase() == 'en_proceso' ||
                      i.estado.toLowerCase() == 'en proceso')
        .length;
    final int resueltas = incidencias
        .where((i) => i.estado.toLowerCase() == 'resuelta' ||
                      i.estado.toLowerCase() == 'resuelto')
        .length;

    return RefreshIndicator(
      color: Colors.black,
      onRefresh: () async {
        incidenciaPageBloc.add(GetIncidencias());
        await incidenciaPageBloc.stream.firstWhere(
          (state) =>
              state is IncidenciaPageLoaded || state is IncidenciaPageError,
        );
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Gestión de Incidencias',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Reporta y gestiona problemas de la comunidad',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: const Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add, color: Colors.white, size: 20),
                label: Text(
                  'Nueva Incidencia',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF111827),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                    child: _buildStatusCounter('Pendientes', '$pendientes')),
                const SizedBox(width: 12),
                Expanded(
                    child: _buildStatusCounter('En Proceso', '$enProceso')),
                const SizedBox(width: 12),
                Expanded(
                    child: _buildStatusCounter('Resueltas', '$resueltas')),
              ],
            ),
            const SizedBox(height: 32),
            ...incidencias.map((incidencia) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildIncidenceCard(incidencia),
                )),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ─── WIDGETS ───────────────────────────────────────────────────────────────

  Widget _buildStatusCounter(String label, String count) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF3F4F6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            label.toUpperCase(),
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF9CA3AF),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            count,
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1F2937),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIncidenceCard(IncidenciasResponse incidencia) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF3F4F6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        incidencia.titulo,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF111827),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        incidencia.categoria.toUpperCase(),
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF475569),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _getEstadoColor(incidencia.estado),
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            incidencia.descripcion,
            style: GoogleFonts.inter(
                fontSize: 12, color: const Color(0xFF6B7280)),
          ),
          const SizedBox(height: 24),
          Column(
            children: [
              Row(
                children: [
                  Expanded(
                      child: _buildInfoItem(
                          'Categoría:', incidencia.categoria)),
                  Expanded(
                      child: _buildInfoItem('Ubicación:', incidencia.ubicacion,
                          alignRight: true)),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                      child: _buildInfoItem(
                          'Estado:', incidencia.estado)),
                  Expanded(
                      child: _buildInfoItem(
                        'Fecha:',
                        '${incidencia.createdAt.day}/${incidencia.createdAt.month}/${incidencia.createdAt.year}',
                        alignRight: true,
                      )),
                ],
              ),
            ],
          ),
          if (incidencia.fechaResolucion != null) ...[
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFF3F4F6)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Fecha de resolución:',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${incidencia.fechaResolucion!.day}/${incidencia.fechaResolucion!.month}/${incidencia.fechaResolucion!.year}',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: const Color(0xFF4B5563),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ─── HELPERS ───────────────────────────────────────────────────────────────

  Widget _buildInfoItem(String label, String value,
      {bool alignRight = false}) {
    return Column(
      crossAxisAlignment:
          alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.inter(
                fontSize: 11, color: const Color(0xFF9CA3AF))),
        const SizedBox(height: 2),
        Text(value,
            style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF374151))),
      ],
    );
  }

  Color _getEstadoColor(String estado) {
    switch (estado.toLowerCase()) {
      case 'pendiente':
        return Colors.orange;
      case 'en_proceso':
      case 'en proceso':
        return Colors.blue;
      case 'resuelta':
      case 'resuelto':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
