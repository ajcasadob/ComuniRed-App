import 'package:app_mobile/core/models/avisos_response.dart';
import 'package:app_mobile/core/service/avisos_service.dart';
import 'package:app_mobile/core/service/token_storage.dart';
import 'package:app_mobile/features/avisos/bloc/aviso_page_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';

class AvisosPage extends StatefulWidget {
  const AvisosPage({super.key});

  @override
  State<AvisosPage> createState() => _AvisosPageState();
}

class _AvisosPageState extends State<AvisosPage> {
  late final AvisoPageBloc avisoPageBloc;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    const secureStorage = FlutterSecureStorage();
    final tokenStorage = TokenStorage(secureStorage);
    final avisosService = AvisosService(tokenStorage);
    avisoPageBloc = AvisoPageBloc(avisosService);
    avisoPageBloc.add(GetAvisos());
    _initialized = true;
  }

  @override
  void dispose() {
    avisoPageBloc.close();
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
      value: avisoPageBloc,
      child: BlocListener<AvisoPageBloc, AvisoPageState>(
        listener: (context, state) {
          if (state is AvisoPageError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${state.message}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: BlocBuilder<AvisoPageBloc, AvisoPageState>(
          builder: (context, state) {
            if (state is AvisoPageInitial || state is AvisoPageLoading) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.black),
              );
            }

            if (state is AvisoPageError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      'Error al cargar los avisos',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        color: const Color(0xFF374151),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => avisoPageBloc.add(GetAvisos()),
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

            if (state is AvisoPageLoaded) {
              return _buildContent(state.avisos);
            }

            return const SizedBox();
          },
        ),
      ),
    );
  }

  // ─── CONTENIDO ─────────────────────────────────────────────────────────────

  Widget _buildContent(List<AvisosResponse> avisos) {
    return RefreshIndicator(
      color: Colors.black,
      onRefresh: () async {
        avisoPageBloc.add(GetAvisos());
        await avisoPageBloc.stream.firstWhere(
          (state) => state is AvisoPageLoaded || state is AvisoPageError,
        );
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Comunicaciones y Anuncios',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Información importante para la comunidad',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: const Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 24),
            ...avisos.map((aviso) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildNoticeCard(aviso),
                )),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ─── CARD ──────────────────────────────────────────────────────────────────

  Widget _buildNoticeCard(AvisosResponse aviso) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _getCategoryColor(aviso.tipo),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  aviso.tipo.toUpperCase(),
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: _getCategoryTextColor(aviso.tipo),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.calendar_month, size: 12, color: Color(0xFF94A3B8)),
              const SizedBox(width: 4),
              Text(
                aviso.fechaPublicacion,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF94A3B8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            aviso.titulo,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            aviso.contenido,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: const Color(0xFF4B5563),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.only(top: 12),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Color(0xFFF8FAFC))),
            ),
            child: Text(
              'Publicado por Admin #${aviso.autorId}',
              style: GoogleFonts.inter(
                fontSize: 11,
                color: const Color(0xFF94A3B8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── HELPERS ───────────────────────────────────────────────────────────────
Color _getCategoryColor(String tipo) {
  switch (tipo.toLowerCase()) {
    case 'evento':
      return const Color(0xFF0F172A);
    case 'mantenimiento':
      return const Color(0xFF2563EB);
    case 'urgente':
      return const Color(0xFFDC2626);
    case 'general':
      return const Color(0xFFE5E7EB);
    case 'aviso':
      return const Color(0xFF059669);
    default:
      return const Color(0xFF0F172A);
  }
}

Color _getCategoryTextColor(String tipo) {
  switch (tipo.toLowerCase()) {
    case 'general':
      return const Color(0xFF6B7280);
    default:
      return Colors.white;
  }
}
}
