import 'package:app_mobile/core/config/api_constants.dart';
import 'package:app_mobile/core/models/incidencias_response.dart';
import 'package:app_mobile/core/service/incidencias_service.dart';
import 'package:app_mobile/core/service/token_storage.dart';
import 'package:app_mobile/features/incidencias/ui/bloc/incidencia_page_bloc.dart';
import 'package:app_mobile/features/incidencias/ui/crear_incidencia_modal.dart';
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
  int? _currentUserId;

  @override
  void initState() {
    super.initState();
    const secureStorage = FlutterSecureStorage();
    final tokenStorage = TokenStorage(secureStorage);
    final incidenciasService = IncidenciasService(tokenStorage);
    incidenciaPageBloc = IncidenciaPageBloc(incidenciasService);
    _loadUserId(tokenStorage);
  }

  Future<void> _loadUserId(TokenStorage tokenStorage) async {
    final id = await tokenStorage.getUserId();
    if (!mounted) return;
    setState(() {
      _currentUserId = id;
      _initialized = true;
    });
    incidenciaPageBloc.add(GetIncidencias());
  }

  @override
  void dispose() {
    incidenciaPageBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.black),
      );
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
          if (state is IncidenciaDeleted) {
            incidenciaPageBloc.add(GetIncidencias());
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Incidencia eliminada correctamente'),
                backgroundColor: Colors.green,
              ),
            );
          }
          if (state is IncidenciaDeleteError) {
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
            if (state is IncidenciaPageInitial ||
                state is IncidenciaPageLoading ||
                state is IncidenciaDeleting) {
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
                          fontSize: 16, color: const Color(0xFF374151)),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => incidenciaPageBloc.add(GetIncidencias()),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                      child: Text('Reintentar',
                          style: GoogleFonts.inter(color: Colors.white)),
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
    final int pendientes =
        incidencias.where((i) => i.estado.toLowerCase() == 'pendiente').length;
    final int enProceso = incidencias
        .where((i) =>
            i.estado.toLowerCase() == 'en_proceso' ||
            i.estado.toLowerCase() == 'en proceso')
        .length;
    final int resueltas = incidencias
        .where((i) =>
            i.estado.toLowerCase() == 'resuelta' ||
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
                  fontSize: 12, color: const Color(0xFF6B7280)),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final creada = await showModalBottomSheet<bool>(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.white,
                    shape: const RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    builder: (_) => BlocProvider.value(
                      value: incidenciaPageBloc,
                      child: const CrearIncidenciaModal(),
                    ),
                  );
                  if (creada == true) incidenciaPageBloc.add(GetIncidencias());
                },
                icon: const Icon(Icons.add, color: Colors.white, size: 20),
                label: Text(
                  'Nueva Incidencia',
                  style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF111827),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(child: _buildStatusCounter('Pendientes', '$pendientes')),
                const SizedBox(width: 12),
                Expanded(child: _buildStatusCounter('En Proceso', '$enProceso')),
                const SizedBox(width: 12),
                Expanded(child: _buildStatusCounter('Resueltas', '$resueltas')),
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
    final esMia = incidencia.usuarioId == _currentUserId;

    return GestureDetector(
      onTap: () => _mostrarOpciones(context, incidencia, esMia),
      child: Container(
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
            
            // ── Foto (solo si existe) ────────────────────────────────────
            if (incidencia.foto != null)
            
              ClipRRect(
                
                borderRadius:
                
                    const BorderRadius.vertical(top: Radius.circular(16)),
                    
                child: Image.network(
                  '${ApiConstants.storageUrl}/${incidencia.foto}',
                  width: double.infinity,
                  height: 180,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return Container(
                      height: 180,
                      color: const Color(0xFFF3F4F6),
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: Colors.black,
                          strokeWidth: 2,
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stack) => Container(
                    height: 100,
                    color: const Color(0xFFF3F4F6),
                    child: const Center(
                      child: Icon(Icons.broken_image_outlined,
                          color: Color(0xFF9CA3AF), size: 32),
                    ),
                  ),
                ),
              ),

            // ── Contenido de la tarjeta ──────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(20),
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
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _getEstadoColor(incidencia.estado),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.more_vert,
                            size: 18,
                            color: esMia
                                ? const Color(0xFF9CA3AF)
                                : const Color(0xFFD1D5DB),
                          ),
                        ],
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
                              child: _buildInfoItem(
                            'Ubicación:',
                            incidencia.ubicacion,
                            alignRight: true,
                          )),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                              child:
                                  _buildInfoItem('Estado:', incidencia.estado)),
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
            ),
          ],
        ),
      ),
    );
  }

  // ─── HELPERS ───────────────────────────────────────────────────────────────

  void _mostrarOpciones(
    BuildContext context,
    IncidenciasResponse incidencia,
    bool esMia,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              incidencia.titulo,
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF111827),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              incidencia.categoria[0].toUpperCase() +
                  incidencia.categoria.substring(1),
              style: GoogleFonts.inter(
                  fontSize: 12, color: const Color(0xFF6B7280)),
            ),
            const SizedBox(height: 24),
            if (esMia) ...[
              ListTile(
                onTap: () {
                  Navigator.pop(context);
                  _abrirEditar(context, incidencia);
                },
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.edit_outlined,
                      color: Color(0xFF111827), size: 20),
                ),
                title: Text('Editar incidencia',
                    style: GoogleFonts.inter(
                        fontSize: 14, fontWeight: FontWeight.w500)),
                subtitle: Text('Modifica los datos de esta incidencia',
                    style: GoogleFonts.inter(
                        fontSize: 12, color: const Color(0xFF9CA3AF))),
                contentPadding: EdgeInsets.zero,
              ),
              const Divider(height: 1, color: Color(0xFFF3F4F6)),
              ListTile(
                onTap: () {
                  Navigator.pop(context);
                  _confirmarEliminar(context, incidencia);
                },
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEE2E2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.delete_outline,
                      color: Colors.red, size: 20),
                ),
                title: Text('Eliminar incidencia',
                    style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.red)),
                subtitle: Text('Esta acción no se puede deshacer',
                    style: GoogleFonts.inter(
                        fontSize: 12, color: const Color(0xFF9CA3AF))),
                contentPadding: EdgeInsets.zero,
              ),
            ] else ...[
              Row(
                children: [
                  const Icon(Icons.info_outline,
                      color: Color(0xFF9CA3AF), size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Esta incidencia pertenece a otro vecino',
                    style: GoogleFonts.inter(
                        fontSize: 13, color: const Color(0xFF9CA3AF)),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _abrirEditar(
      BuildContext context, IncidenciasResponse incidencia) async {
    final editada = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => BlocProvider.value(
        value: incidenciaPageBloc,
        child: CrearIncidenciaModal(incidencia: incidencia),
      ),
    );
    if (editada == true) incidenciaPageBloc.add(GetIncidencias());
  }

  void _confirmarEliminar(
      BuildContext context, IncidenciasResponse incidencia) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Eliminar incidencia',
            style: GoogleFonts.inter(
                fontWeight: FontWeight.bold, fontSize: 16)),
        content: Text(
          '¿Estás seguro de que quieres eliminar "${incidencia.titulo}"? Esta acción no se puede deshacer.',
          style: GoogleFonts.inter(
              fontSize: 14, color: const Color(0xFF6B7280)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancelar',
                style: GoogleFonts.inter(color: const Color(0xFF6B7280))),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              incidenciaPageBloc.add(DeleteIncidencia(incidencia.id));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: Text('Eliminar',
                style: GoogleFonts.inter(color: Colors.white)),
          ),
        ],
      ),
    );
  }

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
