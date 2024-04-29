import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AgregarAlbum extends StatefulWidget {
  const AgregarAlbum({Key? key});

  @override
  _AgregarAlbumState createState() => _AgregarAlbumState();
}

class _AgregarAlbumState extends State<AgregarAlbum> {
  late File _image = File('No hay imagen');
  final picker = ImagePicker();
  final nombreController = TextEditingController();
  final generoController = TextEditingController();
  final anioController = TextEditingController();
  final artistaController = TextEditingController();

  Future getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            }),
        title: const Text('Agregar Álbum'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton(
                  onPressed: getImage,
                  child: Text('Seleccionar imagen'),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: nombreController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Nombre del álbum',
                  ),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: generoController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Género',
                  ),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: anioController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Año de lanzamiento',
                  ),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: artistaController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Artista',
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _guardarAlbum,
                  child: Text('Guardar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _guardarAlbum() async {
    if (nombreController.text.isEmpty ||
        generoController.text.isEmpty ||
        anioController.text.isEmpty ||
        artistaController.text.isEmpty ||
        _image == 'No hay imagen') {
      SnackBar(
        content: Text('Todos los campos son obligatorios'),
      );
      return;
    }
    CollectionReference Bandas =
        FirebaseFirestore.instance.collection('Bandas');

    // Construye el mapa para agregar a Firestore
    Map<String, dynamic> albumData = {
      'Nombre': nombreController.text,
      'Genero': generoController.text,
      'Anio': int.tryParse(anioController.text) ?? 0,
      'Artista': artistaController.text,
      'Votos': 0,
    };

    if (_image != 'No hay imagen') {
      // Sube la imagen al almacenamiento de Firebase y obtén la URL de descarga
      final arreglo = _image.path.split('/');
      final imageUrl = await subirFoto(_image.path, arreglo.last);
      albumData['Imagen'] = arreglo.last;
    } else {
      albumData['Imagen'] = 'No hay imagen';
    }
    SnackBar(
      content: Text('¡Banda guardada con exito!'),
      backgroundColor: Colors.green,
    );

    // Agrega los datos del álbum a Firestore
    Bandas.add(albumData).then((value) {
      print("Álbum guardado en Firebase con ID: ${value.id}");
    }).catchError((error) {
      print("Error al guardar el álbum: $error");
    });
  }

  Future<String> subirFoto(String path, String nombre) async {
    // Referencia a la instancia de Firebase Storage
    if (path == 'No hay imagen') {
      return 'No hay imagen';
    }
    final storageRef = FirebaseStorage.instance.ref();

    final imagen = File(path); // el archivo que voy a subir

    // la referencia donde voy a guardar
    final referenciaFotoPerfil = storageRef.child("imagenes/${nombre}.jpg");

    final uploadTask = await referenciaFotoPerfil.putFile(imagen);

    // Espera a que la tarea de carga se complete y luego obtén la URL de descarga
    final url = await uploadTask.ref.getDownloadURL();
    Navigator.pop(context);
    return url;
  }
}
