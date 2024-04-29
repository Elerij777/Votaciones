import 'package:flutter/material.dart';

import 'agregar_banda.dart';
import 'centro_votaciones.dart';

class Menu extends StatelessWidget {
  const Menu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar Album'),
      ),
      body: Center(
        child: Column(
          children: [
            const Text(
              'No nos hacemos responsables si se va la luz si no va ganando nuestro album favorito y se revierten las votaciones a su favor',
              textAlign: TextAlign.center,
              style: TextStyle(),
            ),
            Container(
              height: 1,
              color: Color.fromARGB(255, 144, 58, 255),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CentroDeVotaciones(),
                  ),
                );
              },
              child: Text('Ir a votar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AgregarAlbum(),
                  ),
                );
              },
              child: Text('Agregar banda'),
            ),
          ],
        ),
      ),
    );
  }
}
