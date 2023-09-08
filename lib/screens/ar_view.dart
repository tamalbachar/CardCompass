// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:arcore_flutter_plugin/arcore_flutter_plugin.dart';
import 'package:vector_math/vector_math_64.dart' as vector;

class ARScene extends StatefulWidget {
  const ARScene({super.key});

  @override
  State<ARScene> createState() => _ARSceneState();
}

class _ARSceneState extends State<ARScene> {
  Widget arView() {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('AR View'),
        ),
        body: ArCoreView(
          onArCoreViewCreated: _onArCoreViewCreated,
        ),
      ),
    );
  }

  void _onArCoreViewCreated(ArCoreController controller) {
    // Add a node with a 3D model
    final node = ArCoreReferenceNode(
      name: 'Earth',
      objectUrl: './Assets/Earth.zip',
      position: vector.Vector3(0, 0, -1),
    );
    controller.addArCoreNode(node);

    // Handle tap events
    controller.onNodeTap = (name) {
      print('Tapped on $name');
    };
  }

  @override
  Widget build(BuildContext context) {
    return arView();
  }
}
