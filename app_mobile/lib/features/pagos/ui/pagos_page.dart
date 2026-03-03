import 'package:app_mobile/core/models/pago_response.dart';
import 'package:app_mobile/core/service/pago_service.dart';
import 'package:app_mobile/core/service/token_storage.dart';
import 'package:app_mobile/features/pagos/bloc/pago_page_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';

class PagosPage extends StatefulWidget {
  const PagosPage({super.key});

  @override
  State<PagosPage> createState() => _PagosPageState();
}

class _PagosPageState extends State<PagosPage> {
  late final PagoPageBloc pagoPageBloc;

  @override
  void initState() {
    super.initState();
    const secureStorage = FlutterSecureStorage();
    final tokenStorage = TokenStorage(secureStorage);
    final pagoService = PagoService(tokenStorage);
    pagoPageBloc = PagoPageBloc(pagoService);
    pagoPageBloc.add(GetPagos());
  }

  @override
  void dispose() {
    pagoPageBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: pagoPageBloc,
      child: BlocBuilder<PagoPageBloc, PagoPageState>(
        builder: (context, state) {
          if (state is PagoPageInitial || state is PagoPageLoading) {
            return const Center(
                child: CircularProgressIndicator(color: Colors.black));
          }

          if (state is PagoPageError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error al cargar los pagos',
                      style: GoogleFonts.inter(
                          fontSize: 16, color: const Color(0xFF374151))),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => pagoPageBloc.add(GetPagos()),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black),
                    child: Text('Reintentar',
                        style: GoogleFonts.inter(color: Colors.white)),
                  ),
                ],
              ),
            );
          }

          if (state is PagoPageLoaded) {
            return _buildContent(state.pagos);
          }

          return const SizedBox();
        },
      ),
    );
  }

  // ─── CONTENIDO ─────────────────────────────────────────────────────────────

  Widget _buildContent(List<PagoResponse> pagos) {
    final tieneVencidos   = pagos.any((p) => p.estado == 'vencido');
    final tienePendientes = pagos.any((p) => p.estado == 'pendiente');
    final alDia           = !tieneVencidos && !tienePendientes;

    return RefreshIndicator(
      color: Colors.black,
      onRefresh: () async => pagoPageBloc.add(GetPagos()),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────────────────────────
            Text('Mis Pagos',
                style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF111827))),
            const SizedBox(height: 4),
            Text('Historial de cuotas y derramas',
                style: GoogleFonts.inter(
                    fontSize: 12, color: const Color(0xFF6B7280))),
            const SizedBox(height: 24),

            // ── Banner estado general ────────────────────────────────────────
            _buildBannerEstado(alDia, tieneVencidos),
            const SizedBox(height: 16),

            // ── Resumen numérico ─────────────────────────────────────────────
            _buildResumen(pagos),
            const SizedBox(height: 24),

            // ── Lista ────────────────────────────────────────────────────────
            Text('Detalle',
                style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF111827))),
            const SizedBox(height: 12),
            ...pagos.map((p) => _buildPagoCard(p)),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  // ─── BANNER ────────────────────────────────────────────────────────────────

  Widget _buildBannerEstado(bool alDia, bool tieneVencidos) {
    final color       = alDia ? const Color(0xFF16A34A) : tieneVencidos ? Colors.red : const Color(0xFFD97706);
    final bgColor     = alDia ? const Color(0xFFF0FDF4) : tieneVencidos ? const Color(0xFFFEF2F2) : const Color(0xFFFFFBEB);
    final borderColor = alDia ? const Color(0xFFBBF7D0) : tieneVencidos ? const Color(0xFFFECACA) : const Color(0xFFFDE68A);
    final icon        = alDia ? Icons.check_circle_outline : tieneVencidos ? Icons.cancel_outlined : Icons.warning_amber_outlined;
    final texto       = alDia ? 'Estás al día con todos tus pagos' : tieneVencidos ? 'Tienes pagos vencidos sin abonar' : 'Tienes pagos pendientes';
    final subtexto    = alDia ? 'No tienes ningún importe pendiente' : tieneVencidos ? 'Contacta con la administración' : 'Recuerda abonarlos antes del vencimiento';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(texto,
                    style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: color)),
                const SizedBox(height: 2),
                Text(subtexto,
                    style: GoogleFonts.inter(
                        fontSize: 12, color: color.withOpacity(0.8))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── RESUMEN ───────────────────────────────────────────────────────────────

  Widget _buildResumen(List<PagoResponse> pagos) {
    final pagados    = pagos.where((p) => p.estado == 'pagado').length;
    final pendientes = pagos.where((p) => p.estado == 'pendiente').length;
    final vencidos   = pagos.where((p) => p.estado == 'vencido').length;

    return Row(
      children: [
        Expanded(child: _buildResumenItem('Pagados',    '$pagados',    const Color(0xFF16A34A), const Color(0xFFF0FDF4))),
        const SizedBox(width: 10),
        Expanded(child: _buildResumenItem('Pendientes', '$pendientes', const Color(0xFFD97706), const Color(0xFFFFFBEB))),
        const SizedBox(width: 10),
        Expanded(child: _buildResumenItem('Vencidos',   '$vencidos',   Colors.red,              const Color(0xFFFEF2F2))),
      ],
    );
  }

  Widget _buildResumenItem(String label, String value, Color color, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
          color: bg, borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Text(value,
              style: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: color)),
          const SizedBox(height: 2),
          Text(label,
              style: GoogleFonts.inter(
                  fontSize: 11, color: color.withOpacity(0.8))),
        ],
      ),
    );
  }

  // ─── PAGO CARD ─────────────────────────────────────────────────────────────

  Widget _buildPagoCard(PagoResponse pago) {
    final config = _estadoConfig(pago.estado);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF3F4F6)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 2,
              offset: const Offset(0, 1)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: config['bg'] as Color,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(config['icon'] as IconData,
                color: config['color'] as Color, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${pago.concepto} · ${pago.periodo}',
                        style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF111827))),
                    Text('${pago.importe.toStringAsFixed(2)} €',
                        style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF111827))),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      pago.fechaPago != null
                          ? 'Pagado el ${_formatFecha(pago.fechaPago!)}'
                          : 'Vence el ${_formatFecha(pago.fechaVencimiento)}',
                      style: GoogleFonts.inter(
                          fontSize: 11, color: const Color(0xFF9CA3AF)),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: config['bg'] as Color,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        (config['label'] as String).toUpperCase(),
                        style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: config['color'] as Color),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── HELPERS ───────────────────────────────────────────────────────────────

  Map<String, dynamic> _estadoConfig(String estado) {
    switch (estado) {
      case 'pagado':
        return {
          'color': const Color(0xFF16A34A),
          'bg':    const Color(0xFFF0FDF4),
          'icon':  Icons.check_circle_outline,
          'label': 'Pagado',
        };
      case 'vencido':
        return {
          'color': Colors.red,
          'bg':    const Color(0xFFFEF2F2),
          'icon':  Icons.cancel_outlined,
          'label': 'Vencido',
        };
      default:
        return {
          'color': const Color(0xFFD97706),
          'bg':    const Color(0xFFFFFBEB),
          'icon':  Icons.access_time_outlined,
          'label': 'Pendiente',
        };
    }
  }

  String _formatFecha(DateTime fecha) {
    return '${fecha.day.toString().padLeft(2, '0')}/'
        '${fecha.month.toString().padLeft(2, '0')}/'
        '${fecha.year}';
  }
}
