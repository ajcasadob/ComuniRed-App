import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PagosPage extends StatefulWidget {
  const PagosPage({super.key});

  @override
  State<PagosPage> createState() => _PagosPageState();
}

class _PagosPageState extends State<PagosPage> {
  @override
  Widget build(BuildContext context) {
    // ✅ Sin Scaffold, sin AppBar, sin BottomNav
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryCard('Total Recaudado', '256.50 €', isSmall: false),
          const SizedBox(height: 16),
          _buildSummaryCard('Pendiente de Cobro', '171.00 €', isSmall: true),
          const SizedBox(height: 16),
          _buildCollectionRateCard(),
          const SizedBox(height: 16),
          _buildFeesManagementCard(),
          const SizedBox(height: 16),
          _buildPaymentInfoCard(),
          const SizedBox(height: 20), // ✅ reducido, ya no hay BottomNav propio
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, String amount, {required bool isSmall}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[500])),
          const SizedBox(height: 4),
          Text(amount,
              style: GoogleFonts.inter(
                  fontSize: isSmall ? 20 : 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black)),
        ],
      ),
    );
  }

  Widget _buildCollectionRateCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Tasa de Cobro',
                  style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[500])),
              Text('60.0%',
                  style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black)),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: 0.6,
              backgroundColor: const Color(0xFFE5E7EB),
              color: const Color(0xFF1F2937),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeesManagementCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Gestión de Cuotas y Pagos',
              style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black)),
          const SizedBox(height: 4),
          Text('Tus pagos y recibos',
              style: GoogleFonts.inter(
                  fontSize: 12, color: Colors.grey[500])),
          const SizedBox(height: 16),
          Table(
            columnWidths: const {
              0: FlexColumnWidth(2),
              1: FlexColumnWidth(3),
              2: FlexColumnWidth(2),
            },
            children: [
              TableRow(
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: Color(0xFFF3F4F6))),
                ),
                children: [
                  _buildTableHeader('Periodo'),
                  _buildTableHeader('Concepto'),
                  _buildTableHeader('Importe', textAlign: TextAlign.right),
                ],
              ),
              _buildTableRow('Octubre 2025', 'Cuota ordinaria', '85.50 €'),
              _buildTableRow('Septiembre 2025', 'Cuota ordinaria', '85.50 €'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Información de Pago',
              style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black)),
          const SizedBox(height: 16),
          _buildInfoItem('Método de pago', 'Domiciliación bancaria'),
          const SizedBox(height: 16),
          _buildInfoItem('Cuenta bancaria', 'ES** **** **** **** **** 1234'),
          const SizedBox(height: 16),
          _buildInfoItem('Cuota mensual', '85.50 €'),
          const SizedBox(height: 16),
          _buildInfoItem('Día de cargo', '1 de cada mes'),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFF3F4F6)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Nota:',
                    style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[600])),
                const SizedBox(height: 4),
                Text(
                  'Los pagos se realizan automáticamente mediante domiciliación bancaria. Si necesitas cambiar tu método de pago, contacta con la administración.',
                  style: GoogleFonts.inter(
                      fontSize: 10, color: Colors.grey[500], height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader(String text,
      {TextAlign textAlign = TextAlign.left}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(text,
          style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey[400]),
          textAlign: textAlign),
    );
  }

  TableRow _buildTableRow(String p, String c, String i) {
    return TableRow(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF9FAFB))),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(p,
              style: GoogleFonts.inter(
                  fontSize: 12, fontWeight: FontWeight.w500)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(c,
              style: GoogleFonts.inter(
                  fontSize: 12, color: Colors.grey[600])),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(i,
              style: GoogleFonts.inter(
                  fontSize: 12, fontWeight: FontWeight.w500),
              textAlign: TextAlign.right),
        ),
      ],
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(),
            style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.grey[400],
                letterSpacing: 0.5)),
        const SizedBox(height: 4),
        Text(value,
            style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black)),
      ],
    );
  }
}
