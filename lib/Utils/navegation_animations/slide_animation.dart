import 'package:flutter/material.dart';

PageRouteBuilder crearRuta(BuildContext context, Widget destino) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) {
      return Stack(
        children: [
          SlideTransition(
            position: Tween<Offset>(
              begin: Offset.zero,
              end: const Offset(-1.0, 0.0),
            ).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.easeInOut,
              ),
            ),
          ),
          SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.easeInOut,
              ),
            ),
            child: destino,
          ),
        ],
      );
    },
    transitionDuration: const Duration(milliseconds: 600),
  );
}
