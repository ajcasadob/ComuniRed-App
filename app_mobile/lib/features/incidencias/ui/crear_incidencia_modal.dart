import 'dart:io';

import 'package:app_mobile/core/dtos/incidencia_request.dart';
import 'package:app_mobile/core/models/incidencias_response.dart';
import 'package:app_mobile/core/service/token_storage.dart';
import 'package:app_mobile/features/incidencias/ui/bloc/incidencia_page_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class CrearIncidenciaModal extends StatefulWidget {
  final IncidenciasResponse? incidencia;
  const CrearIncidenciaModal({super.key, this.incidencia});

  @override
  State<CrearIncidenciaModal> createState() => _CrearIncidenciaModalState();
}

class _CrearIncidenciaModalState extends State<CrearIncidenciaModal> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _tituloController;
  late final TextEditingController _descripcionController;
  late final TextEditingController _ubicacionController;

  late String _categoriaSeleccionada;
  late String _prioridadSeleccionada;
  int? _usuarioId;
  int? _viviendaId;
  bool _loadingUser = true;

  // ── Foto ──────────────────────────────────────────────────────────────────
  File? _fotoSeleccionada;
  final ImagePicker _picker = ImagePicker();

  bool get _esEdicion => widget.incidencia != null;

  static const List<String> _categorias = [
    'fontaneria', 'electricidad', 'limpieza',
    'albanileria', 'carpinteria', 'otro',
  ];

  static const List<String> _prioridades = ['baja', 'media', 'alta'];

  @override
  void initState() {
    super.initState();
    final inc = widget.incidencia;
    _tituloController     = TextEditingController(text: inc?.titulo ?? '');
    _descripcionController = TextEditingController(text: inc?.descripcion ?? '');
    _ubicacionController  = TextEditingController(text: inc?.ubicacion ?? '');

    final categoriaRaw = inc?.categoria.toLowerCase().trim() ?? 'fontaneria';
    _categoriaSeleccionada = _categorias.contains(categoriaRaw)
        ? categoriaRaw
        : 'fontaneria';

    final prioridadRaw = inc?.prioridad.toLowerCase().trim() ?? 'baja';
    _prioridadSeleccionada = _prioridades.contains(prioridadRaw)
        ? prioridadRaw
        : 'baja';

    _loadIds();
  }

  Future<void> _loadIds() async {
    const secureStorage = FlutterSecureStorage();
    final tokenStorage = TokenStorage(secureStorage);
    final userId    = await tokenStorage.getUserId();
    final viviendaId = await tokenStorage.getViviendaId();
    setState(() {
      _usuarioId  = widget.incidencia?.usuarioId ?? userId;
      _viviendaId = widget.incidencia?.viviendaId ?? viviendaId;
      _loadingUser = false;
    });
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked != null) {
      setState(() => _fotoSeleccionada = File(picked.path));
    }
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

  final request = IncidenciaRequest(
    titulo:       _tituloController.text.trim(),
    descripcion:  _descripcionController.text.trim(),  
    ubicacion:    _ubicacionController.text.trim(),
    categoria:    _categoriaSeleccionada,
    prioridad:    _prioridadSeleccionada,
    usuarioId:    _usuarioId!,
    viviendaId:   _viviendaId,
    foto:         _fotoSeleccionada,
  );

  if (_esEdicion) {
    context.read<IncidenciaPageBloc>().add(
          UpdateIncidencia(widget.incidencia!.id, request),
        );
  } else {
    context.read<IncidenciaPageBloc>().add(CreateIncidencia(request));
  }
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
        if (state is IncidenciaUpdated) {
          Navigator.pop(context, true);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Incidencia "${state.incidencia.titulo}" actualizada correctamente'),
              backgroundColor: Colors.green,
            ),
          );
        }
        if (state is IncidenciaCreateError || state is IncidenciaUpdateError) {
          final message = state is IncidenciaCreateError
              ? state.message
              : (state as IncidenciaUpdateError).message;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $message'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: BlocBuilder<IncidenciaPageBloc, IncidenciaPageState>(
        builder: (context, state) {
          final isLoading = state is IncidenciaCreating ||
              state is IncidenciaUpdating ||
              _loadingUser;

          return Padding(
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
                    // Handle
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
                      _esEdicion ? 'Editar Incidencia' : 'Nueva Incidencia',
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
                      validator: (v) => v == null || v.isEmpty
                          ? 'El título es obligatorio'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    _buildField(
                      label: 'Descripción',
                      controller: _descripcionController,
                      hint: 'Describe el problema con detalle',
                      maxLines: 3,
                      validator: (v) => v == null || v.isEmpty
                          ? 'La descripción es obligatoria'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    _buildField(
                      label: 'Ubicación',
                      controller: _ubicacionController,
                      hint: 'Ej: Portal A, Escalera 2...',
                      validator: (v) => v == null || v.isEmpty
                          ? 'La ubicación es obligatoria'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _buildCategoriaDropdown()),
                        const SizedBox(width: 12),
                        Expanded(child: _buildPrioridadDropdown()),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildFotoPicker(), // ← nuevo
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
                                _esEdicion ? 'Guardar Cambios' : 'Crear Incidencia',
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

  Widget _buildFotoPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Foto (opcional)',
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            width: double.infinity,
            height: _fotoSeleccionada != null ? 180 : 80,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: _fotoSeleccionada != null
                ? Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          _fotoSeleccionada!,
                          width: double.infinity,
                          height: 180,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: () => setState(() => _fotoSeleccionada = null),
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            padding: const EdgeInsets.all(4),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.add_photo_alternate_outlined,
                        color: Color(0xFF9CA3AF),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Añadir foto',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: const Color(0xFF9CA3AF),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

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
        Text(label,
            style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF374151))),
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
                borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF111827), width: 1.5)),
            errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.red)),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoriaDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Categoría',
            style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF374151))),
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
          decoration: _dropdownDecoration(),
        ),
      ],
    );
  }

  Widget _buildPrioridadDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Prioridad',
            style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF374151))),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: _prioridadSeleccionada,
          onChanged: (value) => setState(() => _prioridadSeleccionada = value!),
          items: _prioridades
              .map((p) => DropdownMenuItem(
                    value: p,
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: _getPrioridadColor(p),
                            shape: BoxShape.circle,
                          ),
                        ),
                        Text(
                          p[0].toUpperCase() + p.substring(1),
                          style: GoogleFonts.inter(fontSize: 14),
                        ),
                      ],
                    ),
                  ))
              .toList(),
          decoration: _dropdownDecoration(),
        ),
      ],
    );
  }

  Color _getPrioridadColor(String prioridad) {
    switch (prioridad) {
      case 'alta':  return const Color(0xFFEF4444);
      case 'media': return const Color(0xFFCA8A04);
      default:      return const Color(0xFF6B7280);
    }
  }

  InputDecoration _dropdownDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF111827), width: 1.5)),
    );
  }
}
