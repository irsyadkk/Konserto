import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PickLocationPage extends StatefulWidget {
  final LatLng initLatLng;
  const PickLocationPage({super.key, required this.initLatLng});

  @override
  State<PickLocationPage> createState() => _PickLocationPageState();
}

class _PickLocationPageState extends State<PickLocationPage> {
  LatLng? _selectedPosition;

  @override
  void initState() {
    super.initState();
    _selectedPosition = widget.initLatLng;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Pilih Lokasi Konser"),
        backgroundColor: Colors.black,
        foregroundColor: Colors.yellowAccent,
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: widget.initLatLng,
          zoom: 14.0,
        ),
        onTap: (position) {
          setState(() {
            _selectedPosition = position;
          });
        },
        markers: _selectedPosition != null
            ? {
                Marker(
                    markerId: MarkerId("selected"),
                    position: _selectedPosition!,
                    draggable: true,
                    onDragEnd: (newPosition) {
                      setState(() {
                        _selectedPosition = newPosition;
                      });
                    })
              }
            : {},
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () async {
            if (_selectedPosition != null) {
              List<Placemark> placemarks = await placemarkFromCoordinates(
                _selectedPosition!.latitude,
                _selectedPosition!.longitude,
              );
              Placemark place = placemarks.first;

              String address =
                  "${place.street}, ${place.subLocality}, ${place.locality}, ${place.administrativeArea}";

              Navigator.pop(context, {
                'latlng': _selectedPosition,
                'address': address,
              });
            } else {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text("Silakan pilih lokasi dengan tap di peta"),
              ));
            }
          },
          child: Icon(
            Icons.check,
            color: Colors.black,
          ),
          backgroundColor: Colors.amber),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
