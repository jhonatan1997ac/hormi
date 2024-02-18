// ignore_for_file: no_leading_underscores_for_local_identifiers, use_build_context_synchronously, unused_local_variable, unused_import

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geocoding/geocoding.dart';
import 'package:apphormi/pages/inicio/bodega/bodeguero.dart';
import 'package:intl/intl.dart'; // Importa el paquete de fecha y hora

void main() {
  runApp(const GeolocatorWidget());
}

class GeolocatorWidget extends StatefulWidget {
  const GeolocatorWidget({Key? key}) : super(key: key);

  @override
  State<GeolocatorWidget> createState() => _GeolocatorWidgetState();
}

class _GeolocatorWidgetState extends State<GeolocatorWidget> {
  GoogleMapController? _controller;
  LatLng _initialCameraPosition =
      const LatLng(-0.5731751905608471, -78.60171481441253);
  final Set<Marker> _markers = {};
  final List<String> _idpedidos = [];
  final Map<String, List<dynamic>> _ubicacion = {};
  LatLng? _destination;
  final TextEditingController _idpedidoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
    _updateTableFromFirestore(); // Para cargar los datos al inicio
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Datos de GPS',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontSize: 24.0,
          ),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const Bodeguero()),
            );
          },
          icon: const Icon(
            Icons.arrow_back_ios_rounded,
            color: Colors.black,
            size: 30.0,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 5,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: _showLocationInputDialog,
              child: const Text('Mostrar mi Ubicación'),
              style: ElevatedButton.styleFrom(
                primary: Colors.blue,
                textStyle: const TextStyle(fontSize: 18),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _searchDestination,
              child: const Text('Buscar Destino'),
              style: ElevatedButton.styleFrom(
                primary: Colors.green,
                textStyle: const TextStyle(fontSize: 18),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: _initialCameraPosition,
                  zoom: 14,
                ),
                markers: _buildMarkers(),
                onMapCreated: (GoogleMapController controller) {
                  _controller = controller;
                },
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('ID de Pedido')),
                    DataColumn(label: Text('Fecha de Entrega')),
                    DataColumn(label: Text('Latitud')),
                    DataColumn(label: Text('Longitud')),
                  ],
                  rows: _idpedidos.map((idpedido) {
                    final ubicacion = _ubicacion[idpedido] ?? [];
                    final firstLocation =
                        ubicacion.isNotEmpty ? ubicacion.first : null;
                    return DataRow(cells: [
                      DataCell(Text(idpedido)),
                      DataCell(Text(firstLocation != null
                          ? DateFormat('dd/MM/yyyy')
                              .format(firstLocation['fecha_entrega'].toDate())
                          : 'N/A')),
                      DataCell(Text(firstLocation != null
                          ? firstLocation['latitude']
                          : 'N/A')),
                      DataCell(Text(firstLocation != null
                          ? firstLocation['longitude']
                          : 'N/A')),
                    ]);
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              color: Colors.blueGrey[50],
              elevation: 4,
              child: SizedBox(
                height: 200,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListView.builder(
                    itemCount: _idpedidos.length,
                    itemBuilder: (BuildContext context, int index) {
                      return ListTile(
                        title: Text(
                          'ID de Pedido: ${_idpedidos[index]}',
                          style: const TextStyle(fontSize: 16),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Set<Marker> _buildMarkers() {
    _markers.add(
      Marker(
        markerId: const MarkerId('Hormibloque'),
        position: _initialCameraPosition,
        infoWindow: const InfoWindow(title: 'Hormibloque Ecuador S.A.'),
      ),
    );

    return _markers;
  }

  Future<void> _checkLocationPermission() async {
    final status = await Permission.location.request();
    if (status != PermissionStatus.granted) {
      _showPermissionDeniedDialog();
    }
  }

  Future<void> _showLocationInputDialog() async {
    List<String> idOrdenes = await _getIdOrdenes();
    String? selectedIdOrden;

    showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        TextEditingController _textController = TextEditingController();
        return AlertDialog(
          title: const Text('Mostrar mi Ubicación'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: selectedIdOrden,
                items: idOrdenes.map((String idOrden) {
                  return DropdownMenuItem<String>(
                    value: idOrden,
                    child: Text(idOrden),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedIdOrden = newValue!;
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Seleccionar ID de Pedido',
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context, selectedIdOrden);
              },
              child: const Text('Mostrar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancelar'),
            ),
          ],
        );
      },
    ).then((value) {
      if (value != null && value.isNotEmpty) {
        _idpedidoController.text = value;
        _getCurrentPosition();
      }
    });
  }

  Future<void> _searchDestination() async {
    String? destinationAddress = await _showDestinationInputDialog();
    if (destinationAddress != null && destinationAddress.isNotEmpty) {
      try {
        List<Location> locations =
            await locationFromAddress(destinationAddress);
        if (locations.isNotEmpty) {
          Location destinationLocation = locations.first;
          _destination = LatLng(
              destinationLocation.latitude, destinationLocation.longitude);
          _updateMapWithDestination();

          // Actualizar la lista de pedidos con los datos de la colección 'ordenes'
          await _updateTableFromFirestore();
        } else {
          _showErrorDialog(
              'No se encontraron resultados para la dirección ingresada');
        }
      } catch (e) {
        _showErrorDialog('Error al buscar la dirección: $e');
      }
    }
  }

  Future<void> _updateTableFromFirestore() async {
    final firestoreInstance = FirebaseFirestore.instance;
    final querySnapshot = await firestoreInstance.collection('ubicacion').get();

    setState(() {
      _idpedidos.clear();
      _ubicacion.clear();
    });

    for (var doc in querySnapshot.docs) {
      final data = doc.data();
      final idPedido = data['id_pedido'] as String;
      final ubicacionData = {
        'latitude': data['latitude'],
        'longitude': data['longitude'],
        'fecha_entrega': data['fecha_entrega'],
      };

      setState(() {
        _idpedidos.add(idPedido);
        _ubicacion[idPedido] = [ubicacionData];
      });
    }
  }

  Future<String?> _showDestinationInputDialog() async {
    List<String> idOrdenes =
        await _getIdOrdenes(); // Obtener los idOrden de la base de datos
    String? selectedIdOrden;

    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        TextEditingController _textController = TextEditingController();
        return AlertDialog(
          title: const Text('Buscar Destino'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: selectedIdOrden,
                items: idOrdenes.map((String idOrden) {
                  return DropdownMenuItem<String>(
                    value: idOrden,
                    child: Text(idOrden),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedIdOrden = newValue!;
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Seleccionar ID de Orden',
                ),
              ),
              TextField(
                controller: _textController,
                decoration: const InputDecoration(
                  hintText: 'Ingrese la dirección del destino',
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context, selectedIdOrden);
              },
              child: const Text('Buscar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }

  Future<List<String>> _getIdOrdenes() async {
    final firestoreInstance = FirebaseFirestore.instance;
    final querySnapshot = await firestoreInstance.collection('ordenes').get();
    Set<String> idOrdenesSet = Set(); // Usar un conjunto para evitar duplicados

    querySnapshot.docs.forEach((doc) {
      final data = doc.data() as Map<String, dynamic>;
      idOrdenesSet.add(data['idOrden']);
    });

    return idOrdenesSet
        .toList(); // Convertir el conjunto a lista antes de devolver
  }

  void _updateMapWithLocation(double latitude, double longitude) {
    setState(() {
      _initialCameraPosition = LatLng(latitude, longitude);
      _markers.clear();
      _markers.add(
        Marker(
          markerId: const MarkerId('currentLocation'),
          position: LatLng(latitude, longitude),
          infoWindow: const InfoWindow(title: 'Usted está aquí'),
        ),
      );
    });

    _controller?.animateCamera(CameraUpdate.newLatLng(_initialCameraPosition));
  }

  void _updateMapWithDestination() {
    setState(() {
      _markers.clear();
      if (_destination != null) {
        _markers.add(
          Marker(
            markerId: const MarkerId('destination'),
            position: _destination!,
            infoWindow: const InfoWindow(title: 'Destino'),
          ),
        );
      }
    });

    if (_destination != null) {
      _controller?.animateCamera(CameraUpdate.newLatLng(_destination!));
    }
  }

  Future<void> _saveLocationToFirestore(
      double latitude, double longitude) async {
    final firestoreInstance = FirebaseFirestore.instance;
    await firestoreInstance.collection('ubicacion').add({
      'id_pedido': _idpedidoController.text,
      'latitude': latitude.toStringAsFixed(7),
      'longitude': longitude.toStringAsFixed(7),
      'fecha_entrega': DateTime.now(),
    });
    _updateTableFromFirestore();
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Permiso Denegado'),
          content: const Text(
            'Por favor, otorgue permisos de ubicación para continuar.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _getCurrentPosition() async {
    final status = await Permission.location.request();
    if (status == PermissionStatus.granted) {
      try {
        final position = await Geolocator.getCurrentPosition();
        _updateMapWithLocation(position.latitude, position.longitude);
        _saveLocationToFirestore(position.latitude, position.longitude);
      } catch (e) {
        _showErrorDialog('Error al obtener la ubicación: $e');
      }
    } else {
      _showPermissionDeniedDialog();
    }
  }
}
