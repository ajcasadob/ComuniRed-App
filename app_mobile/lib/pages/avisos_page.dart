import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AvisosPage extends StatefulWidget {
  const AvisosPage({super.key});

  @override
  State<AvisosPage> createState() => _AvisosPageState();
}

class _AvisosPageState extends State<AvisosPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
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
            _buildNoticeCard(
              category: 'EVENTO',
              categoryColor: const Color(0xFF0F172A),
              date: '5/10/2025',
              title: 'Reunión de vecinos - 15 de Octubre',
              content: 'Se convoca reunión ordinaria de vecinos el próximo 15 de octubre a las 19:00h en la sala gourmet. Orden del día: Aprobación de presupuesto de obras y renovación de zonas comunes.',
              author: 'Admin Principal',
            ),
            const SizedBox(height: 16),
            _buildNoticeCard(
              category: 'MANTENIMIENTO',
              categoryColor: const Color(0xFF2563EB),
              date: '6/10/2025',
              title: 'Mantenimiento ascensores',
              content: 'El próximo martes 10 de octubre se realizará el mantenimiento preventivo de los ascensores. Estarán fuera de servicio de 9:00 a 13:00h.',
              author: 'Admin Principal',
            ),
            const SizedBox(height: 16),
            _buildNoticeCard(
              category: 'GENERAL',
              categoryColor: const Color(0xFFE5E7EB),
              categoryTextColor: const Color(0xFF6B7280),
              date: '4/10/2025',
              title: 'Nuevo sistema de reciclaje',
              content: 'A partir del 1 de noviembre implementaremos un nuevo sistema de reciclaje en la comunidad. Se instalarán contenedores específicos en el sótano. Por favor, separen correctamente los residuos.',
              author: 'Admin Principal',
            ),
            const SizedBox(height: 100), // Space for bottom nav
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B), // slate-800
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.business, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Comunidad Vecinal',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF111827),
                ),
              ),
              Text(
                '3B',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.person_outline, color: Color(0xFF94A3B8)),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(color: const Color(0xFFF1F5F9), height: 1),
      ),
    );
  }

  Widget _buildNoticeCard({
    required String category,
    required Color categoryColor,
    Color categoryTextColor = Colors.white,
    required String date,
    required String title,
    required String content,
    required String author,
  }) {
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
                  color: categoryColor,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  category,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: categoryTextColor,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.calendar_month, size: 12, color: Color(0xFF94A3B8)),
              const SizedBox(width: 4),
              Text(
                date,
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
            title,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
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
              'Publicado por $author',
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

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: const Color(0xFFE2E8F0))),
      ),
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.home_outlined, 'Inicio', false),
          _buildNavItem(Icons.calendar_month_outlined, 'Reservas', false),
          _buildNavItem(Icons.error_outline, 'Incidencias', false),
          _buildNavItem(Icons.notifications, 'Avisos', true),
          _buildNavItem(Icons.credit_card, 'Pagos', false),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: isActive ? const Color(0xFF0F172A) : const Color(0xFF94A3B8),
          size: 22,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
            color: isActive ? const Color(0xFF0F172A) : const Color(0xFF94A3B8),
          ),
        ),
      ],
    );
  }
}
