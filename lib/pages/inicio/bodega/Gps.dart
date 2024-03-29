// ignore_for_file: prefer_typing_uninitialized_variables, non_constant_identifier_names, sort_child_properties_last, unnecessary_null_comparison, no_leading_underscores_for_local_identifiers, use_build_context_synchronously, unused_local_variable, unnecessary_cast, avoid_function_literals_in_foreach_calls, prefer_collection_literals, file_names

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geocoding/geocoding.dart';
import 'package:apphormi/pages/inicio/bodega/bodeguero.dart';
import 'package:intl/intl.dart';

void main() {
  var GlobalMaterialLocalizations;
  var GlobalWidgetsLocalizations;
  runApp(
    MaterialApp(
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ec', 'EC'),
      ],
      home: const GeolocatorWidget(),
    ),
  );
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
    _updateTableFromFirestore();
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
                backgroundColor: Colors.blue,
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
                backgroundColor: Colors.green,
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
                    DataColumn(label: Text('Fecha de Orden')),
                    DataColumn(label: Text('Latitud')),
                    DataColumn(label: Text('Longitud')),
                  ],
                  rows: _idpedidos.map((idpedido) {
                    final ubicacion = _ubicacion[idpedido] ?? [];
                    final firstLocation =
                        ubicacion.isNotEmpty ? ubicacion.first : null;
                    final fechaEntrega = firstLocation != null &&
                            firstLocation['fecha_entrega'] != null
                        ? (firstLocation['fecha_entrega'] as Timestamp).toDate()
                        : DateTime.now();
                    final fechaOrden = firstLocation != null &&
                            firstLocation['fecha_orden'] != null
                        ? (firstLocation['fecha_orden'] as Timestamp).toDate()
                        : null;

                    return DataRow(cells: [
                      DataCell(Text(idpedido)),
                      DataCell(
                        Text(fechaEntrega != null
                            ? DateFormat('dd/MM/yyyy').format(fechaEntrega
                                .subtract(const Duration(days: 1))
                                .toLocal())
                            : 'N/A'),
                      ),
                      DataCell(
                        Text(fechaOrden != null
                            ? DateFormat('dd/MM/yyyy').format(fechaOrden
                                .subtract(const Duration(days: 1))
                                .toLocal())
                            : 'N/A'),
                      ),
                      DataCell(Text(firstLocation != null
                          ? DateFormat('dd/MM/yyyy').format(
                              (firstLocation['fecha_entrega'] as Timestamp)
                                  .toDate()
                                  .subtract(const Duration(days: 1))
                                  .toLocal())
                          : 'N/A')),
                      DataCell(Text(firstLocation != null
                          ? DateFormat('dd/MM/yyyy').format(
                              (firstLocation['fecha_orden'] as Timestamp)
                                  .toDate()
                                  .subtract(const Duration(days: 1))
                                  .toLocal())
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
    DateTime? selectedDate;

    showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        TextEditingController _textController = TextEditingController();
        return StatefulBuilder(
          builder: (context, setState) {
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
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Text('Fecha de Entrega: '),
                      Expanded(
                        child: TextFormField(
                          readOnly: true,
                          controller: TextEditingController(
                            text: selectedDate != null
                                ? DateFormat('dd/MM/yyyy').format(selectedDate!)
                                : '',
                          ),
                          decoration: const InputDecoration(
                            hintText: 'Seleccione la fecha de entrega',
                            suffixIcon: Icon(Icons.calendar_today),
                          ),
                          onTap: () async {
                            DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate: DateTime(2101),
                            );
                            if (pickedDate != null) {
                              setState(() {
                                selectedDate = pickedDate;
                              });
                            }
                          },
                        ),
                      ),
                    ],
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
        );
      },
    ).then((value) {
      if (value != null && value.isNotEmpty && selectedDate != null) {
        _idpedidoController.text = value;
        _getCurrentPosition(selectedDate!);
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
    });

    for (var doc in querySnapshot.docs) {
      final data = doc.data();
      final idPedido = data['id_pedido'] as String;
      final ubicacionData = {
        'latitude': data['latitude'],
        'longitude': data['longitude'],
        'fecha_entrega': data['fecha_entrega'],
        'fecha_orden': data['fecha_orden'],
      };

      setState(() {
        _idpedidos.add(idPedido);
        if (_ubicacion.containsKey(idPedido)) {
          _ubicacion[idPedido]![0]['fecha_entrega'] =
              ubicacionData['fecha_entrega'];
        } else {
          _ubicacion[idPedido] = [ubicacionData];
        }
      });
    }
  }

  Future<String?> _showDestinationInputDialog() async {
    List<String> idOrdenes = await _getIdOrdenes();
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
    Set<String> idOrdenesSet = Set();

    querySnapshot.docs.forEach((doc) {
      final data = doc.data() as Map<String, dynamic>;
      idOrdenesSet.add(data['idOrden']);
    });

    return idOrdenesSet.toList();
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
      double latitude, double longitude, DateTime selectedDate) async {
    final firestoreInstance = FirebaseFirestore.instance;
    final idPedido = _idpedidoController.text;
    final querySnapshot = await firestoreInstance
        .collection('ubicacion')
        .where('id_pedido', isEqualTo: idPedido)
        .get();
    if (querySnapshot.docs.isNotEmpty) {
      final docId = querySnapshot.docs.first.id;
      await firestoreInstance.collection('ubicacion').doc(docId).update({
        'latitude': latitude.toStringAsFixed(7),
        'longitude': longitude.toStringAsFixed(7),
        'fecha_entrega': Timestamp.fromDate(selectedDate.toUtc()),
        'fecha_orden': Timestamp.now(),
      });
    } else {
      await firestoreInstance.collection('ubicacion').add({
        'id_pedido': idPedido,
        'latitude': latitude.toStringAsFixed(7),
        'longitude': longitude.toStringAsFixed(7),
        'fecha_entrega': Timestamp.fromDate(selectedDate.toUtc()),
        'fecha_orden': Timestamp.now(),
      });
    }
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

  Future<void> _getCurrentPosition(DateTime selectedDate) async {
    final status = await Permission.location.request();
    if (status == PermissionStatus.granted) {
      try {
        final position = await Geolocator.getCurrentPosition();
        _updateMapWithLocation(position.latitude, position.longitude);
        _saveLocationToFirestore(
            position.latitude, position.longitude, selectedDate);
      } catch (e) {
        _showErrorDialog('Error al obtener la ubicación: $e');
      }
    } else {
      _showPermissionDeniedDialog();
    }
  }
}
