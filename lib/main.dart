import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  // Vamos a inizializar la configuracion, eso incluye los datos de coneccion con
  // nuestra app en la nube
  WidgetsFlutterBinding.ensureInitialized();
  // Vamos a esperar que el async obtenga su promise lo que quiere decir que
  // la configuracion esta echa
  await Firebase.initializeApp();
  // Correr la app
  runApp(const LDSWApp());
}

class LDSWApp extends StatelessWidget {
  const LDSWApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
      ),
      home: const MoviesHomePage(title: 'Coleccion de Peliculas'),
    );
  }
}

// Usamos un stateful widget para poder cambiar el estado de cada objeto de \
// pelicula
class MoviesHomePage extends StatefulWidget {
  const MoviesHomePage({super.key, required this.title});
  final String title;

  @override
  State<MoviesHomePage> createState() => _MoviesHomePageState();
}

class _MoviesHomePageState extends State<MoviesHomePage> {
  // Input de texto para nuevos capturar datos
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();

  // Poder leer y crear nuevos documentos a nuestra coleccion en firebase
  final CollectionReference _movies = FirebaseFirestore.instance.collection(
    'movies',
  );

  // Leer peliculas que existen
  Stream<QuerySnapshot> getMoviesStream() {
    return _movies.snapshots();
  }

  // Agrega nueva pelicula
  void _addMovie() {
    final title = _titleController.text.trim();
    final year = _yearController.text.trim();

    // Si no estan vacios, los agregamos
    if (title.isNotEmpty && year.isNotEmpty) {
      _movies.add({'title': title, 'year': year});
      _titleController.clear();
      _yearController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          children: [
            // Texto en el top
            Padding(
              padding: EdgeInsets.all(12), // Espaciado uniforme
              child: Column(
                children: [
                  Text('Ingresa los datos que quieras capturar'),
                  TextField(
                    controller: _titleController,
                    decoration: InputDecoration(labelText: 'Ingresa titulo'),
                  ),
                  TextField(
                    controller: _yearController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: 'Ingresa Año'),
                  ),
                  Text('Películas en la colección.'),
                  SizedBox(height: 10),
                  ElevatedButton.icon(
                    icon: Icon(Icons.add),
                    label: Text('Add Movie'),
                    onPressed: _addMovie,
                  ),
                ],
              ),
            ),
            // Cargar peliculas en la coleccion
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: getMoviesStream(), // Obtenemos nuestras peliculas
                builder: (context, snapshot) {
                  // En caso de que no se hayan cargado todavia los datos
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  // En caso de estear vacio
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text('No hay peliculas aun'));
                  }

                  // Obtenemos la lista de documentos desde el snapshot
                  List<QueryDocumentSnapshot> movieDocuments =
                      snapshot.data!.docs;

                  return ListView.builder(
                    // Total de items
                    itemCount: movieDocuments.length,
                    // Creamos cada item
                    itemBuilder: (context, index) {
                      // Leemos el documento actual
                      final document = movieDocuments[index];
                      // Vamos a mapear los datos
                      final data = document.data() as Map<String, dynamic>;
                      // Cargamos los datos y los renderisamos usando ListTitle
                      final title = data['title'] ?? '-';
                      final year = data['year'] ?? '-';
                      return ListTile(
                        leading: Text(index.toString()),
                        title: Text(title),
                        subtitle: Text(year.toString()),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
