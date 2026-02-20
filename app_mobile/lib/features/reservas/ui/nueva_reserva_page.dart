import 'package:app_mobile/core/dtos/reserva_request_dto.dart';
import 'package:app_mobile/core/service/token_storage.dart';
import 'package:app_mobile/features/reservas/bloc/reserva_page_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';

class NuevaReservaPage extends StatefulWidget {
  final ReservaPageBloc bloc;
  const NuevaReservaPage({super.key, required this.bloc});

  @override
  State<NuevaReservaPage> createState() => _NuevaReservaPageState();
}

class _NuevaReservaPageState extends State<NuevaReservaPage> {
  final _formKey = GlobalKey<FormState>();

  final List<String> _instalaciones = [
    'Pista de Pádel 1',
    'Pista de Pádel 2',
    'Mesa de Ping Pong',
    'Sala Gourmet',
    'Gimnasio',
  ];

  String? _instalacionSeleccionada;
  DateTime? _fechaSeleccionada;
  TimeOfDay? _horaInicio;
  TimeOfDay? _horaFin;

  String _formatFecha(DateTime fecha) =>
      '${fecha.year}-${fecha.month.toString().padLeft(2, '0')}-${fecha.day.toString().padLeft(2, '0')}';

  String _formatHora(TimeOfDay hora) =>
      '${hora.hour.toString().padLeft(2, '0')}:${hora.minute.toString().padLeft(2, '0')}';

  Future<void> _seleccionarFecha() async {
    final hoy = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: hoy,
      firstDate: hoy,
      lastDate: DateTime(hoy.year + 1),
    );
    if (picked != null) setState(() => _fechaSeleccionada = picked);
  }

  Future<void> _seleccionarHoraInicio() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
    );
    if (picked != null) setState(() => _horaInicio = picked);
  }

  Future<void> _seleccionarHoraFin() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 10, minute: 0),
    );
    if (picked != null) setState(() => _horaFin = picked);
  }

  void _crearReserva() async {
    if (_formKey.currentState!.validate()) {
      const secureStorage = FlutterSecureStorage();
      final tokenStorage = TokenStorage(secureStorage);
      final usuarioId = await tokenStorage.getUserId();

      if (!mounted) return;

      if (usuarioId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sesión no válida, inicia sesión de nuevo'),
          ),
        );
        return;
      }

      widget.bloc.add(
        CrearReserva(
          CrearReservaRequest(
            nombreEspacio: _instalacionSeleccionada!,
            usuarioId: usuarioId,
            fechaReserva: _formatFecha(_fechaSeleccionada!),
            horaInicio: _formatHora(_horaInicio!),
            horaFin: _formatHora(_horaFin!),
            estado: 'pendiente',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: widget.bloc,
      child: BlocListener<ReservaPageBloc, ReservaPageState>(
        listener: (context, state) {
          
          if (state is ReservaPageCreada) {
            Navigator.pop(context);
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

        child: Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),

          // ── AppBar igual que InicioPage ──────────────────
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: const BackButton(color: Colors.black),
            title: Text(
              'Nueva Reserva',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF111827),
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(color: const Color(0xFFF9FAFB), height: 1),
            ),
          ),

          body: BlocBuilder<ReservaPageBloc, ReservaPageState>(
            builder: (context, state) {
              final isLoading = state is ReservaPageLoading;
              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Instalación ──────────────────────────
                      _buildLabel('Instalación'),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _instalacionSeleccionada,
                        hint: Text(
                          'Selecciona una instalación',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: const Color(0xFF9CA3AF),
                          ),
                        ),
                        decoration: _inputDecoration(),
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: const Color(0xFF111827),
                        ),
                        items: _instalaciones
                            .map(
                              (e) => DropdownMenuItem(value: e, child: Text(e)),
                            )
                            .toList(),
                        onChanged: (value) =>
                            setState(() => _instalacionSeleccionada = value),
                        validator: (v) =>
                            v == null ? 'Selecciona una instalación' : null,
                      ),
                      const SizedBox(height: 20),

                      // ── Fecha ────────────────────────────────
                      _buildLabel('Fecha'),
                      const SizedBox(height: 8),
                      FormField<DateTime>(
                        validator: (_) => _fechaSeleccionada == null
                            ? 'Selecciona una fecha'
                            : null,
                        builder: (field) => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSelectorButton(
                              onPressed: _seleccionarFecha,
                              icon: Icons.calendar_today,
                              label: _fechaSeleccionada != null
                                  ? _formatFecha(_fechaSeleccionada!)
                                  : 'Elige una fecha',
                            ),
                            if (field.errorText != null)
                              _buildError(field.errorText!),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ── Horario ───────────────────────────────
                      _buildLabel('Horario'),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: FormField<TimeOfDay>(
                              validator: (_) => _horaInicio == null
                                  ? 'Elige hora inicio'
                                  : null,
                              builder: (field) => Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildSelectorButton(
                                    onPressed: _seleccionarHoraInicio,
                                    icon: Icons.access_time,
                                    label: _horaInicio != null
                                        ? _formatHora(_horaInicio!)
                                        : 'Hora inicio',
                                  ),
                                  if (field.errorText != null)
                                    _buildError(field.errorText!),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: FormField<TimeOfDay>(
                              validator: (_) =>
                                  _horaFin == null ? 'Elige hora fin' : null,
                              builder: (field) => Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildSelectorButton(
                                    onPressed: _seleccionarHoraFin,
                                    icon: Icons.access_time_filled,
                                    label: _horaFin != null
                                        ? _formatHora(_horaFin!)
                                        : 'Hora fin',
                                  ),
                                  if (field.errorText != null)
                                    _buildError(field.errorText!),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // ── Botón confirmar ──────────────────────
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _crearReserva,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0F172A),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  'Confirmar Reserva',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // ── Helpers de diseño ──────────────────────────────────

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF374151),
      ),
    );
  }

  InputDecoration _inputDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: const Color(0xFFF3F4F6),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF0F172A), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.red, width: 1),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  Widget _buildSelectorButton({
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
  }) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 16, color: const Color(0xFF374151)),
        label: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            color: const Color(0xFF374151),
          ),
        ),
        style: OutlinedButton.styleFrom(
          backgroundColor: const Color(0xFFF3F4F6),
          side: BorderSide.none,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          alignment: Alignment.centerLeft,
        ),
      ),
    );
  }

  Widget _buildError(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, top: 4),
      child: Text(
        text,
        style: GoogleFonts.inter(color: Colors.red, fontSize: 12),
      ),
    );
  }
}
