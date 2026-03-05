import 'package:app_mobile/core/dtos/update_usuario_request.dart';
import 'package:app_mobile/core/models/usuario_response.dart';
import 'package:app_mobile/features/perfil/bloc/perfil_page_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class EditarPerfilPage extends StatefulWidget {
  final PerfilPageBloc bloc;
  final UsuarioResponse usuario;

  const EditarPerfilPage({
    super.key,
    required this.bloc,
    required this.usuario,
  });

  @override
  State<EditarPerfilPage> createState() => _EditarPerfilPageState();
}

class _EditarPerfilPageState extends State<EditarPerfilPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordConfirmController = TextEditingController();

  bool _cambiarPassword = false;
  bool _obscureCurrent = true;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.usuario.name);
    _emailController = TextEditingController(text: widget.usuario.email);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _currentPasswordController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    super.dispose();
  }

  void _guardarCambios() {
    if (!_formKey.currentState!.validate()) return;

    widget.bloc.add(
      UpdatePerfil(
        UpdateUsuarioRequest(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          currentPassword: _cambiarPassword && _currentPasswordController.text.isNotEmpty
              ? _currentPasswordController.text
              : null,
          password: _cambiarPassword && _passwordController.text.isNotEmpty
              ? _passwordController.text
              : null,
          passwordConfirmation: _cambiarPassword && _passwordConfirmController.text.isNotEmpty
              ? _passwordConfirmController.text
              : null,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: widget.bloc,
      child: BlocListener<PerfilPageBloc, PerfilPageState>(
        listener: (context, state) {
          if (state is PerfilUpdated) {
            Navigator.pop(context);
          }
          if (state is PerfilUpdateError) {
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
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: const BackButton(color: Colors.black),
            title: Text(
              'Editar Perfil',
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
          body: BlocBuilder<PerfilPageBloc, PerfilPageState>(
            builder: (context, state) {
              final isLoading = state is PerfilUpdating;
              return SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Datos personales ─────────────────────
                      _buildField(
                        label: 'Nombre',
                        controller: _nameController,
                        icon: Icons.person_outline,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'El nombre es obligatorio';
                          if (v.trim().length < 4) return 'El nombre debe tener al menos 4 caracteres';
                          if (v.trim().length > 60) return 'El nombre no puede superar los 60 caracteres';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildField(
                        label: 'Correo electrónico',
                        controller: _emailController,
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'El correo es obligatorio';
                          final emailRegex = RegExp(r'^[\w\.-]+@[\w\.-]+\.[a-zA-Z]{2,}$');
                          if (!emailRegex.hasMatch(v.trim())) return 'Introduce un correo válido';
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      // ── Toggle cambiar contraseña ─────────────
                      GestureDetector(
                        onTap: () => setState(
                            () => _cambiarPassword = !_cambiarPassword),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _cambiarPassword
                                  ? const Color(0xFF111827)
                                  : const Color(0xFFE5E7EB),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.lock_outline,
                                size: 18,
                                color: _cambiarPassword
                                    ? const Color(0xFF111827)
                                    : const Color(0xFF9CA3AF),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Cambiar contraseña',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: _cambiarPassword
                                        ? const Color(0xFF111827)
                                        : const Color(0xFF6B7280),
                                  ),
                                ),
                              ),
                              Icon(
                                _cambiarPassword
                                    ? Icons.keyboard_arrow_up
                                    : Icons.keyboard_arrow_down,
                                color: const Color(0xFF9CA3AF),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // ── Campos contraseña (si activo) ────────
                      if (_cambiarPassword) ...[
                        const SizedBox(height: 16),

                        // Contraseña actual
                        _buildPasswordField(
                          label: 'Contraseña actual',
                          controller: _currentPasswordController,
                          obscure: _obscureCurrent,
                          onToggle: () => setState(
                              () => _obscureCurrent = !_obscureCurrent),
                          validator: (v) {
                            if (!_cambiarPassword) return null;
                            if (v == null || v.isEmpty) {
                              return 'Introduce tu contraseña actual';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Nueva contraseña
                        _buildPasswordField(
                          label: 'Nueva contraseña',
                          controller: _passwordController,
                          obscure: _obscurePassword,
                          onToggle: () => setState(
                              () => _obscurePassword = !_obscurePassword),
                          validator: (v) {
                            if (!_cambiarPassword) return null;
                            if (v == null || v.isEmpty) {
                              return 'Introduce la nueva contraseña';
                            }
                            if (v.length < 8) return 'Mínimo 8 caracteres';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Confirmar nueva contraseña
                        _buildPasswordField(
                          label: 'Confirmar nueva contraseña',
                          controller: _passwordConfirmController,
                          obscure: _obscureConfirm,
                          onToggle: () => setState(
                              () => _obscureConfirm = !_obscureConfirm),
                          validator: (v) {
                            if (!_cambiarPassword) return null;
                            if (v != _passwordController.text) {
                              return 'Las contraseñas no coinciden';
                            }
                            return null;
                          },
                        ),
                      ],
                      const SizedBox(height: 32),

                      // ── Botón guardar ────────────────────────
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _guardarCambios,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF111827),
                            disabledBackgroundColor: const Color(0xFF6B7280),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
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
                                  'Guardar cambios',
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
              );
            },
          ),
        ),
      ),
    );
  }

  // ─── WIDGETS ───────────────────────────────────────────────────────────────

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
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
          keyboardType: keyboardType,
          validator: validator,
          style: GoogleFonts.inter(
              fontSize: 14, color: const Color(0xFF111827)),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 18, color: const Color(0xFF9CA3AF)),
            filled: true,
            fillColor: Colors.white,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: Color(0xFF111827), width: 1.5)),
            errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.red)),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required bool obscure,
    required VoidCallback onToggle,
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
          obscureText: obscure,
          validator: validator,
          style: GoogleFonts.inter(
              fontSize: 14, color: const Color(0xFF111827)),
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.lock_outline,
                size: 18, color: Color(0xFF9CA3AF)),
            suffixIcon: IconButton(
              icon: Icon(
                obscure
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                size: 18,
                color: const Color(0xFF9CA3AF),
              ),
              onPressed: onToggle,
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: Color(0xFF111827), width: 1.5)),
            errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.red)),
          ),
        ),
      ],
    );
  }
}
