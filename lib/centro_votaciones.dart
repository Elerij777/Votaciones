import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class CentroDeVotaciones extends StatefulWidget {
  const CentroDeVotaciones({Key? key}) : super(key: key);

  @override
  _CentroDeVotacionesState createState() => _CentroDeVotacionesState();
}

class _CentroDeVotacionesState extends State<CentroDeVotaciones> {
  late Future<List<DocumentSnapshot>> _bandasFuture;

  @override
  void initState() {
    super.initState();
    initializeFirebase();
    _bandasFuture = obtenerBandas();
  }

  Future<void> initializeFirebase() async {
    try {
      await Firebase.initializeApp();
    } catch (e) {
      print('Error al inicializar Firebase: $e');
    }
  }

  Future<List<DocumentSnapshot>> obtenerBandas() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('Bandas').get();
    return querySnapshot.docs;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Elige a qué banda votar'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: FutureBuilder<List<DocumentSnapshot>>(
            future: _bandasFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Error al cargar los datos');
              } else if (snapshot.hasData) {
                List<DocumentSnapshot> bandas = snapshot.data!;
                return StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('Bandas')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData ||
                        snapshot.data!.docs.isEmpty) {
                      return Center(child: Text('No hay datos disponibles'));
                    } else {
                      return ListView.builder(
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          var bandData = snapshot.data!.docs[index].data()
                              as Map<String, dynamic>;
                          String nombreBanda = bandData['Nombre'] ?? '';
                          String genero = bandData['Genero'] ?? '';
                          int anio = bandData['Anio'] ?? '';
                          int votos = bandData['Votos'] ?? 0;

                          // Obtener el nombre de la imagen del mapa de datos
                          String imagenNombre = bandData['Imagen'] ?? '';

                          // Construir la URL de la imagen en Firebase Storage
                          String imageUrl = imagenNombre.isNotEmpty
                              ? 'https://firebasestorage.googleapis.com/v0/b/votaciones-de-rock.appspot.com/o/imagenes%2F$imagenNombre?alt=media'
                              : ''; // URL de la imagen de la banda o vacío si no hay imagen

                          return GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                              SnackBar(
                                content: Text('Votaste por $nombreBanda'),
                              );
                              try {
                                votarPorBanda(
                                  snapshot.data!.docs[index].reference,
                                  nombreBanda,
                                  votos,
                                  context,
                                );
                              } catch (error) {
                                print('Error al votar por la banda: $error');
                              }
                            },
                            child: ListTile(
                              /*leading: imageUrl.isNotEmpty
                                  ? Image.network(
                                      imageUrl,
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.cover,
                                    )
                                  : FlutterLogo(size: 50),*/
                              title: Text(nombreBanda),
                              subtitle: Text('$genero ($anio)'),
                              trailing: Text('Votos: $votos'),
                            ),
                          );
                        },
                      );
                    }
                  },
                );
              } else {
                return Text('No hay datos disponibles');
              }
            },
          ),
        ),
      ),
    );
  }

  Future<void> votarPorBanda(
    DocumentReference bandaRef,
    String nombreBanda,
    int votosActuales,
    BuildContext context,
  ) async {
    try {
      // Incrementar el contador de votos
      votosActuales++;

      await bandaRef.update({'Votos': votosActuales});
    } catch (error) {
      // Manejar cualquier error que pueda ocurrir
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al votar: $error'),
        ),
      );
    }
  }
}
