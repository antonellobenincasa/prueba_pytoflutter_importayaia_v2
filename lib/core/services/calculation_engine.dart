import '../models/hs_code.dart';

class TaxResult {
  final double cif;
  final double adValorem;
  final double fodinfa;
  final double ice;
  final double iva;
  final double totalTaxes;
  final double totalImportCost; // CIF + Taxes

  TaxResult({
    required this.cif,
    required this.adValorem,
    required this.fodinfa,
    required this.ice,
    required this.iva,
    required this.totalTaxes,
    required this.totalImportCost,
  });
}

class CalculationEngine {
  // Pure logic, no side effects

  TaxResult calculatePreLiquidation({
    required double fob,
    required double freight,
    required double insurance,
    required HsCode hsCode,
    required double ivaRate, // 0.15
    required double fodinfaRate, // 0.005
    required double iceRate, // 0.0 or specific rate
  }) {
    // 1. Calculate CIF (Cost Insurance Freight)
    // CIF = FOB + Flete + Seguro
    final double cif = fob + freight + insurance;

    // 2. Calculate Ad Valorem (Arancel)
    // Base Imponible: CIF
    double adValorem = 0.0;

    // Handle Ad Valorem logic based on HS Code
    // "15%", "0%", "30%", "Mixto", "Consultar"
    // For this engine, we expect a clean percentage, or 0 if unknown/complex
    final double? avRate = hsCode.adValoremValue;
    if (avRate != null) {
      adValorem = cif * (avRate / 100);
    }

    // 3. Calculate FODINFA
    // Base Imponible: CIF
    final double fodinfa = cif * fodinfaRate;

    // 4. Calculate ICE (Impuesto Consumos Especiales)
    // Base Imponible: CIF + AdValorem + FODINFA
    // Only if applicable
    double ice = 0.0;
    if (iceRate > 0) {
      final double baseIce = cif + adValorem + fodinfa;
      ice = baseIce * iceRate;
    }

    // 5. Calculate IVA
    // Base Imponible: CIF + AdValorem + FODINFA + ICE
    final double baseIva = cif + adValorem + fodinfa + ice;
    final double iva = baseIva * ivaRate;

    // 6. Totals
    final double totalTaxes = adValorem + fodinfa + ice + iva;
    final double totalImportCost = cif + totalTaxes;

    return TaxResult(
      cif: cif,
      adValorem: adValorem,
      fodinfa: fodinfa,
      ice: ice,
      iva: iva,
      totalTaxes: totalTaxes,
      totalImportCost: totalImportCost,
    );
  }
}
