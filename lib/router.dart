import 'package:flutter/material.dart';

import 'agregar_banda.dart';
import 'centro_votaciones.dart';
import 'menu.dart';
import 'routes.dart';

final Map<String, WidgetBuilder> routes = {
  MyRoutes.AgregarBanda.name: (context) => const AgregarAlbum(),
  MyRoutes.Menu.name: (context) => const Menu(),
  MyRoutes.CentroDeVotaciones.name: (context) => const CentroDeVotaciones(),
};
