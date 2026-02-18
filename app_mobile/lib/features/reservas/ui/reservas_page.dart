import 'package:app_mobile/core/models/reserva_response.dart';
import 'package:app_mobile/core/service/reserva_service.dart';
import 'package:app_mobile/core/service/token_storage.dart';
import 'package:app_mobile/features/reservas/ui/bloc/reserva_page_bloc.dart';
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

  @override
  void initState() {
    super.initState();
    const secureStorage = FlutterSecureStorage();
    final tokenStorage = TokenStorage(secureStorage);
    final reservaService = ReservaService(tokenStorage);
    reservaPageBloc = ReservaPageBloc(reservaService);
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

          // ✅ Refresca la lista y muestra snackbar al crear
          if (state is ReservaPageCreada) {
            reservaPageBloc.add(GetReservas());
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Reserva creada correctamente'),
                backgroundColor: Colors.green,
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
            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // Título
                  Text('Reserva de Instalaciones',
                      style: GoogleFonts.inter(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('Gestiona las reservas de las áreas comunes',
                      style: GoogleFonts.inter(
                          fontSize: 14, color: Colors.grey[500])),
                  const SizedBox(height: 24),

                  // ✅ Sin await, el BlocListener gestiona el refresco
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

                  // Grid instalaciones
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

                  // Header Mis Reservas
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Mis Reservas',
                          style: GoogleFonts.inter(
                              fontSize: 14, fontWeight: FontWeight.bold)),
                      Text('Tus reservas activas',
                          style: GoogleFonts.inter(
                              fontSize: 12, color: Colors.grey[400])),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Lista dinámica
                  if (state is ReservaPageLoading)
                    const Center(child: CircularProgressIndicator())
                  else if (state is ReservaPageLoaded)
                    _buildLista(state.reservas)
                  else
                    const Center(child: Text('No hay reservas disponibles')),

                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLista(List<ReservaResponse> reservas) {
    if (reservas.isEmpty) {
      return const Center(child: Text('No tienes reservas activas'));
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: reservas.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final reserva = reservas[index];
        return Card(
          child: ListTile(
            leading: const Icon(Icons.calendar_month),
            title: Text(reserva.nombreEspacio),
            subtitle: Text(
                '${reserva.fechaReserva} · ${reserva.horaInicio} - ${reserva.horaFin}'),
            trailing: Chip(
              label: Text(reserva.estado),
              backgroundColor: reserva.estado == 'pendiente'
                  ? Colors.orange[100]
                  : Colors.green[100],
            ),
          ),
        );
      },
    );
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
