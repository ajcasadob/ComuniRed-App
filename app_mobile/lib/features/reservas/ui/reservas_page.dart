import 'package:app_mobile/core/models/reserva_response.dart';
import 'package:app_mobile/core/service/reserva_service.dart';
import 'package:app_mobile/core/service/token_storage.dart';
import 'package:app_mobile/features/reservas/bloc/reserva_page_bloc.dart';
import 'package:app_mobile/features/reservas/ui/editar_reserva_page.dart';
import 'package:app_mobile/features/reservas/ui/nueva_reserva_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';

class ReservasPage extends StatefulWidget {
  const ReservasPage({super.key});

  @override
  State<ReservasPage> createState() => _ReservasPageState();
}

class _ReservasPageState extends State<ReservasPage> {
  late ReservaPageBloc reservaPageBloc;
  int? _currentUserId; 

  @override
  void initState() {
    super.initState();
    const secureStorage = FlutterSecureStorage();
    final tokenStorage = TokenStorage(secureStorage);
    final reservaService = ReservaService(tokenStorage);
    reservaPageBloc = ReservaPageBloc(reservaService);
    
    _loadUserId(tokenStorage); 
  }

  Future<void> _loadUserId(TokenStorage tokenStorage) async {
    final id = await tokenStorage.getUserId();
    if (mounted) setState(() => _currentUserId = id);
    reservaPageBloc.add(GetReservas());
  }

  @override
  void dispose() {
    reservaPageBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: reservaPageBloc,
      child: BlocListener<ReservaPageBloc, ReservaPageState>(
        listener: (context, state) {
          if (state is ReservaPageCreada) {
            reservaPageBloc.add(GetReservas());
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Reserva creada correctamente'),
                backgroundColor: Colors.green,
              ),
            );
          }
          if (state is ReservaDeleted) {
            reservaPageBloc.add(GetReservas());
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Reserva eliminada correctamente'),
                backgroundColor: Colors.green,
              ),
            );
          }
          if (state is ReservaDeleteError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
          if (state is ReservaPageError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: BlocBuilder<ReservaPageBloc, ReservaPageState>(
          builder: (context, state) {
            return RefreshIndicator(
              color: Colors.black,
              onRefresh: () async {
                reservaPageBloc.add(GetReservas());
                await reservaPageBloc.stream.firstWhere(
                  (s) => s is ReservaPageLoaded || s is ReservaPageError,
                );
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // ── Título ────────────────────────────────────────────
                    Text('Reserva de Instalaciones',
                        style: GoogleFonts.inter(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('Gestiona las reservas de las áreas comunes',
                        style: GoogleFonts.inter(
                            fontSize: 14, color: Colors.grey[500])),
                    const SizedBox(height: 24),

                    // ── Botón nueva reserva ───────────────────────────────
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  NuevaReservaPage(bloc: reservaPageBloc),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0F172A),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text('Nueva Reserva',
                            style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white)),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // ── Grid instalaciones ────────────────────────────────
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.2,
                      children: [
                        _buildFacilityItem('Pista de Pádel 1', Icons.sports_tennis),
                        _buildFacilityItem('Pista de Pádel 2', Icons.sports_tennis),
                        _buildFacilityItem('Mesa de Ping Pong', Icons.sports_kabaddi),
                        _buildFacilityItem('Sala Gourmet', Icons.restaurant),
                        _buildFacilityItem('Gimnasio', Icons.fitness_center),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // ── Header Reservas ───────────────────────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Reservas',
                            style: GoogleFonts.inter(
                                fontSize: 14, fontWeight: FontWeight.bold)),
                        Text('Todas las reservas activas',
                            style: GoogleFonts.inter(
                                fontSize: 12, color: Colors.grey[400])),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // ── Lista dinámica ────────────────────────────────────
                    if (state is ReservaPageLoading || state is ReservaDeleting)
                      const Center(
                          child: CircularProgressIndicator(color: Colors.black))
                    else if (state is ReservaPageLoaded)
                      _buildLista(state.reservas)
                    else
                      const Center(child: Text('No hay reservas disponibles')),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ─── LISTA ─────────────────────────────────────────────────────────────────

  Widget _buildLista(List<ReservaResponse> reservas) {
    if (reservas.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Text('No hay reservas activas',
              style: GoogleFonts.inter(fontSize: 14, color: Colors.grey[500])),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: reservas.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final reserva = reservas[index];
        final esMia = reserva.usuarioId == _currentUserId; // ← nuevo
        return GestureDetector(
          onTap: () => _mostrarOpciones(context, reserva, esMia), // ← nuevo
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFF3F4F6)),
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.calendar_month,
                      size: 20, color: Color(0xFF4B5563)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reserva.nombreEspacio,
                        style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF111827)),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${reserva.fechaReserva} · ${reserva.horaInicio} - ${reserva.horaFin}',
                        style: GoogleFonts.inter(
                            fontSize: 12, color: const Color(0xFF6B7280)),
                      ),
                      // ── Nombre del vecino si no es mía ────────────────
                      if (!esMia) ...[
                        const SizedBox(height: 2),
                        Text(
                          reserva.usuario.name,
                          style: GoogleFonts.inter(
                              fontSize: 11, color: const Color(0xFF9CA3AF)),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                _buildEstadoBadge(reserva.estado),
                const SizedBox(width: 6),
                Icon(
                  Icons.more_vert,
                  size: 18,
                  // ← Icono gris si no es mía
                  color: esMia
                      ? const Color(0xFF4B5563)
                      : const Color(0xFFD1D5DB),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ─── OPCIONES ──────────────────────────────────────────────────────────────

  void _mostrarOpciones(BuildContext context, ReservaResponse reserva, bool esMia) {
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
              reserva.nombreEspacio,
              style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF111827)),
            ),
            const SizedBox(height: 4),
            Text(
              '${reserva.fechaReserva} · ${reserva.horaInicio} - ${reserva.horaFin}',
              style: GoogleFonts.inter(
                  fontSize: 12, color: const Color(0xFF6B7280)),
            ),
            const SizedBox(height: 24),

            // ── Si es mía: editar y eliminar ──────────────────────────────
            if (esMia) ...[
              ListTile(
                onTap: () {
                  Navigator.pop(context);
                  _abrirEditar(context, reserva);
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
                title: Text('Editar reserva',
                    style: GoogleFonts.inter(
                        fontSize: 14, fontWeight: FontWeight.w500)),
                subtitle: Text('Modifica los datos de esta reserva',
                    style: GoogleFonts.inter(
                        fontSize: 12, color: const Color(0xFF9CA3AF))),
                contentPadding: EdgeInsets.zero,
              ),
              const Divider(height: 1, color: Color(0xFFF3F4F6)),
              ListTile(
                onTap: () {
                  Navigator.pop(context);
                  _confirmarEliminar(context, reserva);
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
                title: Text('Eliminar reserva',
                    style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.red)),
                subtitle: Text('Esta acción no se puede deshacer',
                    style: GoogleFonts.inter(
                        fontSize: 12, color: const Color(0xFF9CA3AF))),
                contentPadding: EdgeInsets.zero,
              ),

            // ── Si es de otro vecino: solo info ───────────────────────────
            ] else ...[
              Row(
                children: [
                  const Icon(Icons.person_outline,
                      color: Color(0xFF9CA3AF), size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Reservado por ${reserva.usuario.name}',
                    style: GoogleFonts.inter(
                        fontSize: 13, color: const Color(0xFF6B7280)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.info_outline,
                      color: Color(0xFF9CA3AF), size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'No puedes modificar esta reserva',
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

  void _abrirEditar(BuildContext context, ReservaResponse reserva) async {
    final editada = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => EditarReservaPage(
          bloc: reservaPageBloc,
          reserva: reserva,
        ),
      ),
    );
    if (editada == true) reservaPageBloc.add(GetReservas());
  }

  void _confirmarEliminar(BuildContext context, ReservaResponse reserva) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Eliminar reserva',
            style: GoogleFonts.inter(
                fontWeight: FontWeight.bold, fontSize: 16)),
        content: Text(
          '¿Estás seguro de que quieres eliminar la reserva de "${reserva.nombreEspacio}"? Esta acción no se puede deshacer.',
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
              reservaPageBloc.add(DeleteReserva(reserva.id));
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

  Widget _buildEstadoBadge(String estado) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _getEstadoColor(estado),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        estado,
        style: GoogleFonts.inter(
            fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white),
      ),
    );
  }

  Color _getEstadoColor(String estado) {
    switch (estado.toLowerCase()) {
      case 'confirmada': return const Color(0xFF16A34A);
      case 'pendiente':  return const Color(0xFFCA8A04);
      case 'cancelada':  return const Color(0xFFDC2626);
      case 'completada': return const Color(0xFF6B7280);
      default:           return const Color(0xFF6B7280);
    }
  }

  Widget _buildFacilityItem(String label, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[100]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.grey[600], size: 28),
          const SizedBox(height: 12),
          Text(label,
              style: GoogleFonts.inter(
                  fontSize: 12, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
