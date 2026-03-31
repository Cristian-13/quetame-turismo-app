import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  // Asegura que el motor de Flutter esté listo antes de arrancar Firebase
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa Firebase con la configuración automática que creamos
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const QuetameTurismoApp());
}

class QuetameTurismoApp extends StatelessWidget {
  const QuetameTurismoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quetame Turismo Bicentenario',
      theme: ThemeData(
        // Le puse verde por defecto pensando en los senderos, ¡pero luego lo cambiamos!
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const Scaffold(
        body: Center(child: Text('¡Conexión a Firebase Exitosa!')),
      ),
    );
  }
}
