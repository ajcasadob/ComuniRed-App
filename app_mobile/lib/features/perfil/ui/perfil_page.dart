import 'package:app_mobile/core/models/usuario_response.dart';
import 'package:app_mobile/core/service/perfil_service.dart';
import 'package:app_mobile/core/service/token_storage.dart';
import 'package:app_mobile/features/perfil/bloc/perfil_page_bloc.dart';
import 'package:app_mobile/features/perfil/ui/editar_perfil_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';

class PerfilPage extends StatefulWidget {
  const PerfilPage({super.key});

  @override
  State<PerfilPage> createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  late final PerfilPageBloc perfilPageBloc;

  @override
  void initState() {
    super.initState();
    const secureStorage = FlutterSecureStorage();
    final tokenStorage = TokenStorage(secureStorage);
    final perfilService = PerfilService(tokenStorage);
    perfilPageBloc = PerfilPageBloc(perfilService, tokenStorage);
    perfilPageBloc.add(GetPerfil());
  }

  @override
  void dispose() {
    perfilPageBloc.close();
    super.dispose();
  }

  // ─── CERRAR SESIÓN ─────────────────────────────────────────────────────────

  Future<void> _cerrarSesion() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Cerrar sesión',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
        content: Text(
          '¿Estás seguro de que quieres cerrar sesión?',
          style: GoogleFonts.inter(
              fontSize: 14, color: const Color(0xFF6B7280)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Cancelar',
              style: GoogleFonts.inter(color: const Color(0xFF6B7280)),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'Cerrar sesión',
              style: GoogleFonts.inter(
                  color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (confirmar == true && mounted) {
      const secureStorage = FlutterSecureStorage();
      final tokenStorage = TokenStorage(secureStorage);
      await tokenStorage.deleteToken();

      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
      }
    }
  }

  // ─── BUILD ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: perfilPageBloc,
      child: BlocListener<PerfilPageBloc, PerfilPageState>(
        listener: (context, state) {
          if (state is PerfilUpdated) {
            perfilPageBloc.add(GetPerfil());
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Perfil actualizado correctamente'),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
        child: BlocBuilder<PerfilPageBloc, PerfilPageState>(
          builder: (context, state) {
            if (state is PerfilPageInitial || state is PerfilPageLoading) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.black),
              );
            }

            if (state is PerfilPageError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline,
                        size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      'Error al cargar el perfil',
                      style: GoogleFonts.inter(
                          fontSize: 16, color: const Color(0xFF374151)),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => perfilPageBloc.add(GetPerfil()),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black),
                      child: Text('Reintentar',
                          style: GoogleFonts.inter(color: Colors.white)),
                    ),
                  ],
                ),
              );
            }

            if (state is PerfilPageLoaded) {
              return _buildContent(state.usuario);
            }

            return const SizedBox();
          },
        ),
      ),
    );
  }

  // ─── CONTENIDO ─────────────────────────────────────────────────────────────

  Widget _buildContent(UsuarioResponse usuario) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ────────────────────────────────────────────────────────
          Text(
            'Mi Perfil',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Consulta y edita tu información personal',
            style: GoogleFonts.inter(
                fontSize: 12, color: const Color(0xFF6B7280)),
          ),
          const SizedBox(height: 32),

          // ── Avatar + nombre ───────────────────────────────────────────────
          Center(
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFF111827),
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: Center(
                    child: Text(
                      usuario.name[0].toUpperCase(),
                      style: GoogleFonts.inter(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  usuario.name,
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: usuario.role == 'admin'
                        ? const Color(0xFF111827)
                        : const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    usuario.role.toUpperCase(),
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: usuario.role == 'admin'
                          ? Colors.white
                          : const Color(0xFF475569),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // ── Datos personales ──────────────────────────────────────────────
          _buildSeccion('Datos Personales', [
            _buildInfoRow(Icons.person_outline, 'Nombre', usuario.name),
            _buildInfoRow(Icons.email_outlined, 'Correo', usuario.email),
          ]),
          const SizedBox(height: 16),

          // ── Vivienda ──────────────────────────────────────────────────────
          if (usuario.vivienda != null)
            _buildSeccion('Mi Vivienda', [
              _buildInfoRow(Icons.home_outlined, 'Número',
                  usuario.vivienda!.numeroVivienda),
              _buildInfoRow(Icons.location_on_outlined, 'Bloque',
                  usuario.vivienda!.bloque),
              _buildInfoRow(Icons.stairs_outlined, 'Piso',
                  '${usuario.vivienda!.piso}º ${usuario.vivienda!.puerta}'),
              _buildInfoRow(Icons.square_foot_outlined, 'Superficie',
                  '${usuario.vivienda!.metrosCuadrados} m²'),
              _buildInfoRow(
                  Icons.house_outlined, 'Tipo', usuario.vivienda!.tipo),
            ]),
          const SizedBox(height: 32),

          // ── Botón editar ──────────────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditarPerfilPage(
                      bloc: perfilPageBloc,
                      usuario: usuario,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.edit_outlined,
                  color: Colors.white, size: 18),
              label: Text(
                'Editar perfil',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF111827),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // ── Botón cerrar sesión ───────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _cerrarSesion,
              icon: const Icon(Icons.logout, color: Colors.red, size: 18),
              label: Text(
                'Cerrar sesión',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.red,
                ),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: const BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── WIDGETS ───────────────────────────────────────────────────────────────

  Widget _buildSeccion(String titulo, List<Widget> items) {
    return Container(
      width: double.infinity,
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
          Text(
            titulo,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 16),
          ...items,
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: const Color(0xFF4B5563)),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                    fontSize: 11, color: const Color(0xFF9CA3AF)),
              ),
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF111827),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
