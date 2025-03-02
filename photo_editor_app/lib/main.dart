import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_editor_app/config/graphql_config.dart';
import 'package:photo_editor_app/screens/gallery_screen.dart';
import 'package:photo_editor_app/services/graphql_api.dart';
import 'package:photo_editor_app/services/rust_bridge.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeHiveForGraphQL();
  
  runApp(MyApp());
}

Future<void> initializeHiveForGraphQL() async {
  await initHiveForFlutter();
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GraphQLProvider(
      client: GraphQLConfig.initializeClient(),
      child: MaterialApp(
        title: 'Filtri foto con Rust',
        theme: ThemeData(
          primarySwatch: Colors.deepPurple,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          textTheme: GoogleFonts.poppinsTextTheme(),
        ),
        home: EditorPage(),
      ),
    );
  }
}

class EditorPage extends StatefulWidget {
  @override
  _EditorPageState createState() => _EditorPageState();
}

class _EditorPageState extends State<EditorPage> {
  File? _selectedImage;
  String? _base64Image;
  String? _processedImageBase64;
  bool _isProcessing = false;
  
  final ImagePicker _picker = ImagePicker();
  
  @override
  void initState() {
    super.initState();
    _initializeWasm();
  }
  
  Future<void> _initializeWasm() async {
    try {
      await RustWasmBridge.initialize();
    } catch (e) {
      print('Errore inizializzazione WASM: $e');
    }
  }
  
  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
      maxHeight: 1200,
    );
    
    if (pickedFile != null) {
      final imageBytes = await pickedFile.readAsBytes();
      final base64String = 'data:image/jpeg;base64,${base64Encode(imageBytes)}';
      
      setState(() {
        _selectedImage = File(pickedFile.path);
        _base64Image = base64String;
        _processedImageBase64 = null; // Reset immagine processata
      });
    }
  }
  
  Future<void> _applyFilter(String filterType) async {
    if (_base64Image == null) return;
    
    setState(() {
      _isProcessing = true;
    });
    
    try {
      String? result;
      
      switch (filterType) {
        case 'grayscale':
          result = await RustWasmBridge.applyGrayscale(_base64Image!);
          break;
        case 'blur':
          result = await RustWasmBridge.applyBlur(_base64Image!, 5.0);
          break;
        case 'edge':
          result = await RustWasmBridge.applyEdgeDetection(_base64Image!);
          break;
        default:
          break;
      }
      
      if (result != null) {
        setState(() {
          _processedImageBase64 = result;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Errore nell\'applicare il filtro: $e')),
      );
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Rust Photo Editor'),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.photo_library),
            tooltip: 'Gallery',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => GalleryScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Area immagine
              Container(
                height: 400,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _isProcessing
                    ? Center(child: CircularProgressIndicator())
                    : _processedImageBase64 != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.memory(
                              base64Decode(_processedImageBase64!.split(',').last),
                              fit: BoxFit.contain,
                            ),
                          )
                        : _selectedImage != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(
                                  _selectedImage!,
                                  fit: BoxFit.contain,
                                ),
                              )
                            : Center(
                                child: Text(
                                  'Seleziona un\'immagine per iniziare',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ),
              ),
              
              SizedBox(height: 24),
              
              // Pulsanti filtri
              Text(
                'Filtri powered by Rust & WebAssembly',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              
              SizedBox(height: 16),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _filterButton(
                    'Scala di grigi',
                    Icons.monochrome_photos,
                    () => _applyFilter('grayscale'),
                    _selectedImage == null || _isProcessing,
                  ),
                  _filterButton(
                    'Sfocatura',
                    Icons.blur_on,
                    () => _applyFilter('blur'),
                    _selectedImage == null || _isProcessing,
                  ),
                  _filterButton(
                    'Bordi',
                    Icons.timeline,
                    () => _applyFilter('edge'),
                    _selectedImage == null || _isProcessing,
                  ),
                ],
              ),
              
              SizedBox(height: 24),
              
              // Pulsante reset e salva
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: Icon(Icons.refresh),
                      label: Text('Reset'),
                      onPressed: _selectedImage == null || _isProcessing
                          ? null
                          : () {
                              setState(() {
                                _processedImageBase64 = null;
                              });
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[200],
                        foregroundColor: Colors.black87,
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: Icon(Icons.save_alt),
                      label: Text('Salva'),
                      onPressed: _processedImageBase64 == null || _isProcessing
                          ? null
                          : () {
                              _saveImage();
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 40),
              
              // Pulsante carica immagine
              OutlinedButton.icon(
                icon: Icon(Icons.add_photo_alternate),
                label: Text('Seleziona immagine'),
                onPressed: _isProcessing ? null : _pickImage,
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: Theme.of(context).colorScheme.primary),
                ),
              ),
              
              SizedBox(height: 30),
              
              // Grafici e statistiche (GraphQL)
              if (_selectedImage != null)
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Statistiche immagine',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Divider(),
                        ListTile(
                          leading: Icon(Icons.aspect_ratio),
                          title: Text('Dimensioni'),
                          subtitle: Text('${_selectedImage!.lengthSync()} bytes'),
                        ),
                        ListTile(
                          leading: Icon(Icons.folder),
                          title: Text('Percorso'),
                          subtitle: Text(_selectedImage!.path),
                        ),
                        // Qui potresti aggiungere dati da GraphQL
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _filterButton(String label, IconData icon, VoidCallback onPressed, bool disabled) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: disabled ? null : onPressed,
          child: Icon(icon, size: 30),
          style: ElevatedButton.styleFrom(
            shape: CircleBorder(),
            padding: EdgeInsets.all(16),
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
        SizedBox(height: 8),
        Text(label, style: TextStyle(fontSize: 12)),
      ],
    );
  }
  
  Future<void> _saveImage() async {
    if (_processedImageBase64 == null) return;

    // Mostra dialog per inserire il titolo
    final titleController = TextEditingController();
    final filterType = _processedImageBase64!.contains('grayscale') 
        ? 'Scala di grigi' 
        : _processedImageBase64!.contains('blur') 
            ? 'Sfocatura' 
            : 'Bordi';

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Salva immagine'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: 'Titolo',
                hintText: 'Inserisci un titolo per l\'immagine',
              ),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Annulla'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Salva'),
          ),
        ],
      ),
    );

    if (result == true) {
      final title = titleController.text.isNotEmpty 
          ? titleController.text 
          : 'Immagine ${DateTime.now().millisecondsSinceEpoch}';
          
      try {
        setState(() {
          _isProcessing = true;
        });
        
        // Ottieni il client GraphQL
        final GraphQLClient client = GraphQLProvider.of(context).value;
        
        // Salva l'immagine
        await GraphQLAPI.saveImage(
          client,
          title: title,
          imageData: _processedImageBase64!,
          filter: filterType,
        );
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Immagine salvata con successo')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Errore nel salvataggio: $e')),
        );
      } finally {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }
}