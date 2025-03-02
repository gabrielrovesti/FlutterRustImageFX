# FlutterRustImageFX

App mobile cross-platform per l'applicazione di filtri ed effetti alle immagini, realizzata con Flutter per l'interfaccia utente e Rust/WebAssembly per l'elaborazione ad alte prestazioni.

## 🚀 Caratteristiche

- **Elaborazione immagini ad alte prestazioni** - Filtri implementati in Rust e compilati in WebAssembly
- **UI reattiva e moderna** - Interfaccia utente sviluppata con Flutter
- **Supporto multi-piattaforma** - Funziona su Android, iOS e web
- **Architettura avanzata** - Integrazione GraphQL per il salvataggio e la gestione delle immagini
- **Effetti multipli** - Scala di grigi, sfocatura, rilevamento dei bordi e altri filtri

## 🛠️ Tecnologie

- **Flutter** - Framework UI cross-platform
- **Rust** - Linguaggio per elaborazione immagini ad alte prestazioni
- **WebAssembly** - Per eseguire codice Rust nel contesto mobile/web
- **GraphQL** - Per la gestione e sincronizzazione delle immagini elaborate

## ⚙️ Installazione

### Prerequisiti

- Flutter SDK (versione ≥ 3.0.0)
- Rust e Cargo
- wasm-pack
- Visual Studio con supporto C++ (su Windows)

### Setup

1. **Clona la repository**

```bash
git clone https://github.com/tuo-username/FlutterRustImageFX.git
cd FlutterRustImageFX
```

2. **Compila la libreria Rust**

```bash
cd image_processor_wasm/image-processor
wasm-pack build --target bundler
```

3. **Configura l'app Flutter**

```bash
cd ../../photo_editor_app
flutter pub get
```

4. **Esegui l'applicazione**

```bash
flutter run
```

## 🏗️ Architettura

Il progetto è strutturato in due componenti principali:

- **`image_processor_wasm/`**: Libreria Rust che implementa algoritmi di elaborazione delle immagini
- **`photo_editor_app/`**: Applicazione Flutter che fornisce l'interfaccia utente e integra la libreria WebAssembly

La comunicazione tra Flutter e Rust avviene tramite un bridge WebAssembly, consentendo prestazioni native mantenendo la semplicità dello sviluppo Flutter.

## 📜 Licenza

Questo progetto è distribuito con licenza MIT. Consulta il file `LICENSE` per ulteriori dettagli.

## 🤝 Contributi

I contributi sono benvenuti! Sentiti libero di aprire issue o inviare pull request per migliorare questo progetto.

---

Sviluppato con ❤️ da Gabriel Rovesti