import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:js/js.dart';
import 'package:js/js_util.dart';
import 'package:wasm_interop/wasm_interop.dart';

@JS('WebAssembly.instantiateStreaming')
external Future<dynamic> instantiateStreaming(
  dynamic response, 
  dynamic importObject
);

class RustWasmBridge {
  static Instance? _wasmInstance;
  static Memory? _wasmMemory;
  static bool _isInitialized = false;

  static Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      final module = await Module.fromUrl('assets/wasm/image_processor_bg.wasm');
      final instance = Instance(module, {});
      
      _wasmInstance = instance;
      _wasmMemory = instance.exports['memory'] as Memory;
      
      // Inizializza il modulo Rust (se previsto nella tua libreria)
      final initializeFunction = instance.exports['initialize'] as Function;
      initializeFunction();
      
      _isInitialized = true;
      debugPrint('WASM inizializzato con successo');
    } catch (e) {
      debugPrint('Errore nell\'inizializzazione WASM: $e');
      rethrow;
    }
  }

  static Future<String?> applyGrayscale(String base64Image) async {
    if (!_isInitialized) await initialize();
    
    try {
      final applyGrayscaleFunction = _wasmInstance!.exports['apply_grayscale'] as Function;
      
      // Alloca spazio in memoria WASM per la stringa
      final allocFunction = _wasmInstance!.exports['alloc'] as Function;
      final inputSize = base64Image.length;
      final inputPtr = allocFunction(inputSize) as int;
      
      // Scrivi la stringa nella memoria WASM
      final bytes = Uint8List.fromList(utf8.encode(base64Image));
      _wasmMemory!.buffer.asUint8List(inputPtr, inputSize).setAll(0, bytes);
      
      // Chiama la funzione WASM
      final resultPtr = applyGrayscaleFunction(inputPtr, inputSize) as int;
      
      // Leggi il risultato
      final resultBuffer = _wasmMemory!.buffer;
      final resultView = resultBuffer.asUint8List(resultPtr, resultBuffer.lengthInBytes - resultPtr);
      
      // Trova la fine della stringa
      int nullTerminator = resultView.indexOf(0);
      if (nullTerminator == -1) nullTerminator = resultView.length;
      
      // Converti in stringa
      final result = utf8.decode(resultView.sublist(0, nullTerminator));
      
      // Libera la memoria (se la tua libreria prevede questa funzione)
      final deallocFunction = _wasmInstance!.exports['dealloc'] as Function;
      deallocFunction(resultPtr);
      
      return result;
    } catch (e) {
      debugPrint('Errore nell\'applicare il grayscale: $e');
      return null;
    }
  }

  static Future<String?> applyBlur(String base64Image, double sigma) async {
    if (!_isInitialized) await initialize();
    
    try {
      final applyBlurFunction = _wasmInstance!.exports['apply_blur'] as Function;
      
      // Alloca spazio in memoria WASM per la stringa
      final allocFunction = _wasmInstance!.exports['alloc'] as Function;
      final inputSize = base64Image.length;
      final inputPtr = allocFunction(inputSize) as int;
      
      // Scrivi la stringa nella memoria WASM
      final bytes = Uint8List.fromList(utf8.encode(base64Image));
      _wasmMemory!.buffer.asUint8List(inputPtr, inputSize).setAll(0, bytes);
      
      // Chiama la funzione WASM
      final resultPtr = applyBlurFunction(inputPtr, inputSize, sigma) as int;
      
      // Leggi il risultato
      final resultBuffer = _wasmMemory!.buffer;
      final resultView = resultBuffer.asUint8List(resultPtr, resultBuffer.lengthInBytes - resultPtr);
      
      // Trova la fine della stringa
      int nullTerminator = resultView.indexOf(0);
      if (nullTerminator == -1) nullTerminator = resultView.length;
      
      // Converti in stringa
      final result = utf8.decode(resultView.sublist(0, nullTerminator));
      
      // Libera la memoria (se la tua libreria prevede questa funzione)
      final deallocFunction = _wasmInstance!.exports['dealloc'] as Function;
      deallocFunction(resultPtr);
      
      return result;
    } catch (e) {
      debugPrint('Errore nell\'applicare il blur: $e');
      return null;
    }
  }

  static Future<String?> applyEdgeDetection(String base64Image) async {
    if (!_isInitialized) await initialize();
    
    try {
      final applyEdgeDetectionFunction = _wasmInstance!.exports['apply_edge_detection'] as Function;
      
      // Alloca spazio in memoria WASM per la stringa
      final allocFunction = _wasmInstance!.exports['alloc'] as Function;
      final inputSize = base64Image.length;
      final inputPtr = allocFunction(inputSize) as int;
      
      // Scrivi la stringa nella memoria WASM
      final bytes = Uint8List.fromList(utf8.encode(base64Image));
      _wasmMemory!.buffer.asUint8List(inputPtr, inputSize).setAll(0, bytes);
      
      // Chiama la funzione WASM
      final resultPtr = applyEdgeDetectionFunction(inputPtr, inputSize) as int;
      
      // Leggi il risultato
      final resultBuffer = _wasmMemory!.buffer;
      final resultView = resultBuffer.asUint8List(resultPtr, resultBuffer.lengthInBytes - resultPtr);
      
      // Trova la fine della stringa
      int nullTerminator = resultView.indexOf(0);
      if (nullTerminator == -1) nullTerminator = resultView.length;
      
      // Converti in stringa
      final result = utf8.decode(resultView.sublist(0, nullTerminator));
      
      // Libera la memoria (se la tua libreria prevede questa funzione)
      final deallocFunction = _wasmInstance!.exports['dealloc'] as Function;
      deallocFunction(resultPtr);
      
      return result;
    } catch (e) {
      debugPrint('Errore nell\'applicare la rilevazione dei bordi: $e');
      return null;
    }
  }
}