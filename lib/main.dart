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
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MoviesHomePage(title: 'Coleccion de Peliculas'),
    );
  }
}

// Usamos un stateful widget para poder cambiar el estado de cada objeto de \
// pelicula
class MoviesHomePage extends StatefulWidget {
  const MoviesHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MoviesHomePage> createState() => _MoviesHomePageState();
}

class _MoviesHomePageState extends State<MoviesHomePage> {
  // Input de texto para nuevos capturar datos
  final TextEditingController _controller = TextEditingController();
  // Poder leer y crear nuevos documentos a nuestra coleccion en firebase
  final CollectionReference _movies = FirebaseFirestore.instance.collection(
    'movies',
  );

  // Leer peliculas que existen
  Stream<QuerySnapshot> getMoviesStream() {
    return _movies.snapshots();
  }

  // Agrega nueva pelicula
  void _addMovie(String title) {
    if (title.trim().isNotEmpty) {
      _movies.add({'title': title.trim()});
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MoviesHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          children: [
            // Texto en el top
            Padding(
              padding: EdgeInsets.all(24.24), // Espaciado uniforme
              child: Text('Ingresa los datos que quieras capturar'),
            ),
            // Agregar mas peliculas
            Padding(
              padding: EdgeInsets.all(24.24), // Espaciado uniforme
              child: TextField(),
            ),
            Padding(
              padding: EdgeInsets.all(24.24), // Espaciado uniforme
              child:  Text('Peliculas en la coleccion.'),,
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
                      final title = data['title'] ?? 'Untitled';
                      return ListTile(
                        leading: Text(index.toString()),
                        title: Text(title),
                        subtitle: Text(title),
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
