import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class PreviewPhoto extends StatefulWidget {
  final String imagePath;

  const PreviewPhoto({super.key, required this.imagePath});

  @override
  State<PreviewPhoto> createState() => _PreviewPhotoState();
}

class _PreviewPhotoState extends State<PreviewPhoto> {
  String _location = 'Loading...';
  bool _isLoadingLocation = true;
  late TextEditingController _locationController;
  final _platenumberController = TextEditingController(text: 'ABC123'); // Placeholder for plate number
  String? _selectedViolation; // For dropdown selection

  @override
  void initState() {
    super.initState();
    _locationController = TextEditingController(text: _location);
    _getCurrentLocation();
    //set fleeing as default
    _selectedViolation='Fleeing';
  }

  @override
  void dispose() {
    _locationController.dispose();
    _platenumberController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _location = 'Location services are disabled';
          _locationController.text = _location;
          _isLoadingLocation = false;
        });
        return;
      }

      // Check and request permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _location = 'Location permission denied';
            _locationController.text = _location;
            _isLoadingLocation = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _location = 'Location permissions are permanently denied';
          _locationController.text = _location;
          _isLoadingLocation = false;
        });
        return;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _location = 'Latitude: ${position.latitude}, Longitude: ${position.longitude}';
        _locationController.text = _location;
        _isLoadingLocation = false;
      });
    } catch (e) {
      setState(() {
        _location = 'Error getting location: $e';
        _locationController.text = _location;
        _isLoadingLocation = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Report')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.file(
                File(widget.imagePath),
                fit: BoxFit.contain,
                width: double.infinity,
                height: MediaQuery.of(context).size.height*0.25,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: TextEditingController(text: DateTime.now().toString()),
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Timestamp',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _locationController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Location',
                  border: const OutlineInputBorder(),
                  suffixIcon: _isLoadingLocation
                      ? const Padding(
                          padding: EdgeInsets.all(12.0),
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : const Icon(Icons.location_on, color: Colors.green),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _platenumberController,
                keyboardType: TextInputType.text,
                decoration: const InputDecoration(
                  labelText: 'Plate Number',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty){  
                      return 'Please enter the plate number';
                  };
                  return null;
                }
              ),
              const SizedBox(height: 20),
              // Dropdown menu for violation type
              DropdownButton<String>(
                value: _selectedViolation,
                isExpanded: true,
                borderRadius: BorderRadius.circular(10),
                items: const [
                  DropdownMenuItem<String>(
                    value: 'Fleeing',
                    child: Text('Fleeing'),
                  ),
                  DropdownMenuItem<String>(
                    value: 'Bad Parking',
                    child: Text('Bad Parking'),
                  ),
                ],
                onChanged: (String? value) {
                  setState(() {
                    _selectedViolation = value;
                  });
                },
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: 
                  MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white
                      ),
                      onPressed:(){
                      },
                      child: const Text('Send'))
                  ]
              ),
            ],
          ),
        ),
        ),
      ),
    );
  }
}
