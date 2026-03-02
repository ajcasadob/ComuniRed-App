import 'package:app_mobile/core/dtos/incidencia_request.dart';
import 'package:app_mobile/core/service/token_storage.dart';
import 'package:app_mobile/features/incidencias/ui/bloc/incidencia_page_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';

class CrearIncidenciaModal extends StatefulWidget {
  const CrearIncidenciaModal({super.key});

  @override
  State<CrearIncidenciaModal> createState() => _CrearIncidenciaModalState();
}

class _CrearIncidenciaModalState extends State<CrearIncidenciaModal> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _ubicacionController = TextEditingController();

  String _categoriaSeleccionada = 'fontaneria';
  int? _usuarioId;
  int? _viviendaId;
  bool _loadingUser = true;

  static const List<String> _categorias = [
    'fontaneria',
    'electricidad',
    'limpieza',
    'albanileria',
    'carpinteria',
    'otro',
  ];

  @override
  void initState() {
    super.initState();
    _loadIds();
  }

  Future<void> _loadIds() async {
    const secureStorage = FlutterSecureStorage();
    final tokenStorage = TokenStorage(secureStorage);
    final userId = await tokenStorage.getUserId();
    final viviendaId = await tokenStorage.getViviendaId();
    setState(() {
      _usuarioId = userId;
      _viviendaId = viviendaId;
      _loadingUser = false;
    });
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descripcionController.dispose();
    _ubicacionController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) return;
    if (_usuarioId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo obtener el usuario. Vuelve a iniciar sesión.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    context.read<IncidenciaPageBloc>().add(
          CreateIncidencia(
            IncidenciaRequest(
              titulo: _tituloController.text.trim(),
              descripcion: _descripcionController.text.trim(),
              ubicacion: _ubicacionController.text.trim(),
              categoria: _categoriaSeleccionada,
              usuarioId: _usuarioId!,
              viviendaId: _viviendaId,
            ),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<IncidenciaPageBloc, IncidenciaPageState>(
      listener: (context, state) {
        if (state is IncidenciaCreated) {
          Navigator.pop(context, true);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Incidencia "${state.incidencia.titulo}" creada correctamente'),
              backgroundColor: Colors.green,
            ),
          );
        }
        if (state is IncidenciaCreateError) {
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
          final isLoading = state is IncidenciaCreating || _loadingUser;

          return Padding(
            // Sube el modal cuando aparece el teclado
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ── Handle ──────────────────────────────────────────────
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
                      'Nueva Incidencia',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildField(
                      label: 'Título',
                      controller: _tituloController,
                      hint: 'Ej: Fuga de agua en portal',
                      validator: (v) =>
                          v == null || v.isEmpty ? 'El título es obligatorio' : null,
                    ),
                    const SizedBox(height: 16),
                    _buildField(
                      label: 'Descripción',
                      controller: _descripcionController,
                      hint: 'Describe el problema con detalle',
                      maxLines: 3,
                      validator: (v) =>
                          v == null || v.isEmpty ? 'La descripción es obligatoria' : null,
                    ),
                    const SizedBox(height: 16),
                    _buildField(
                      label: 'Ubicación',
                      controller: _ubicacionController,
                      hint: 'Ej: Portal A, Escalera 2...',
                      validator: (v) =>
                          v == null || v.isEmpty ? 'La ubicación es obligatoria' : null,
                    ),
                    const SizedBox(height: 16),
                    _buildDropdown(),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF111827),
                          disabledBackgroundColor: const Color(0xFF6B7280),
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
                                'Crear Incidencia',
                                style: GoogleFonts.inter(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ─── WIDGETS ──────────────────────────────────────────────────────────────

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    String? hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: validator,
          style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF111827)),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF9CA3AF)),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF111827), width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Categoría',
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: _categoriaSeleccionada,
          onChanged: (value) => setState(() => _categoriaSeleccionada = value!),
          items: _categorias
              .map((cat) => DropdownMenuItem(
                    value: cat,
                    child: Text(
                      cat[0].toUpperCase() + cat.substring(1),
                      style: GoogleFonts.inter(fontSize: 14),
                    ),
                  ))
              .toList(),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF111827), width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
