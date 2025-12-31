import 'package:flutter/material.dart';
import '../../../core/api/quote_repository.dart';

class QuoteFormScreen extends StatefulWidget {
  const QuoteFormScreen({super.key});

  @override
  State<QuoteFormScreen> createState() => _QuoteFormScreenState();
}

class _QuoteFormScreenState extends State<QuoteFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final QuoteRepository _repository = QuoteRepository();
  
  // Controladores para los campos
  final TextEditingController _commodityCtrl = TextEditingController();
  final TextEditingController _weightCtrl = TextEditingController();
  final TextEditingController _volumeCtrl = TextEditingController();
  final TextEditingController _fobCtrl = TextEditingController();

  // Valores temporales para puertos (luego los haremos dinámicos)
  final int _selectedPolId = 1; // ID Puerto Origen
  final int _selectedPodId = 1; // ID Puerto Destino

  bool _isLoading = false;
  String? _resultMessage;

  void _calculateQuote() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _resultMessage = null;
    });

    try {
      final result = await _repository.calculateQuote(
        polId: _selectedPolId,
        podId: _selectedPodId,
        commodity: _commodityCtrl.text,
        weight: double.parse(_weightCtrl.text),
        volume: double.parse(_volumeCtrl.text),
        fobValue: double.parse(_fobCtrl.text),
      );

      // Si llegamos aquí, ¡Python respondió!
      setState(() {
        _resultMessage = "¡Cálculo Exitoso!\nTotal CIF: ${result['total_cif'] ?? 'N/A'}";
      });
      
    } catch (e) {
      setState(() {
        // Es normal que falle ahora si no hay tarifas en la BD, 
        // pero queremos ver QUE error nos da Python.
        _resultMessage = "Respuesta del Servidor: $e";
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Nueva Cotización")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Text("Detalles de la Carga", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              
              // Tipo de Producto
              TextFormField(
                controller: _commodityCtrl,
                decoration: const InputDecoration(labelText: 'Producto (Commodity)', border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 15),

              // Peso y Volumen
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _weightCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Peso (Kg)', border: OutlineInputBorder()),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _volumeCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Volumen (CBM)', border: OutlineInputBorder()),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),

              // Valor FOB
              TextFormField(
                controller: _fobCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Valor FOB (USD)', 
                  border: OutlineInputBorder(),
                  prefixText: '\$ ',
                ),
              ),
              const SizedBox(height: 30),

              // Botón Calcular
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _calculateQuote,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
                  child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white) 
                    : const Text("CALCULAR COTIZACIÓN"),
                ),
              ),

              const SizedBox(height: 20),
              
              // Área de Resultados
              if (_resultMessage != null)
                Container(
                  padding: const EdgeInsets.all(15),
                  color: Colors.grey[200],
                  width: double.infinity,
                  child: Text(_resultMessage!, style: const TextStyle(fontWeight: FontWeight.bold)),
                )
            ],
          ),
        ),
      ),
    );
  }
}