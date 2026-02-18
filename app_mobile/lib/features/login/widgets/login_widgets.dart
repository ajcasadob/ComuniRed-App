import 'package:app_mobile/features/registro/ui/registro_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 80, height: 80,
          decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(16)),
          child: const Icon(Icons.apartment, color: Colors.white, size: 48),
        ),
        const SizedBox(height: 16),
        Text(
          'Comunidad Vecinal',
          style: GoogleFonts.inter(
            fontSize: 24, fontWeight: FontWeight.bold, color: const Color(0xFF1F2937)),
        ),
      ],
    );
  }
}


class LoginFooter extends StatelessWidget {
  const LoginFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('¿No tienes cuenta? ', style: GoogleFonts.inter(color: const Color(0xFF6B7280))),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const RegisterPage()),
            );
          },
          child: Text('Regístrate', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}