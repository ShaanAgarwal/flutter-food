import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';  // Import the http_parser for MediaType

class DonatePage extends StatefulWidget {
  const DonatePage({super.key});

  @override
  _DonatePageState createState() => _DonatePageState();
}

class _DonatePageState extends State<DonatePage> {
  final _foodNameController = TextEditingController();
  final _sharingSizeController = TextEditingController();
  List<File> _images = []; // List to store multiple selected images
  Set<String> _imagePaths = {}; // Set to track selected image paths
  final int _maxImages = 5; // Limit for maximum number of images

  // Method to pick multiple images from the gallery with validation
  Future<void> _pickImagesFromGallery() async {
    if (_images.length >= _maxImages) {
      Fluttertoast.showToast(
        msg: "You can only select up to $_maxImages images.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return;
    }

    try {
      final pickedFiles = await ImagePicker().pickMultiImage(); // Pick multiple images
      if (pickedFiles == null || pickedFiles.isEmpty) return;

      setState(() {
        for (var pickedFile in pickedFiles) {
          if (_imagePaths.contains(pickedFile.path)) {
            // Skip images that are already selected
            Fluttertoast.showToast(
              msg: "Image already selected: ${pickedFile.path}",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              backgroundColor: Colors.orange,
              textColor: Colors.white,
            );
            continue;
          }
          if (_images.length < _maxImages) {
            _images.add(File(pickedFile.path));
            _imagePaths.add(pickedFile.path);
          }
        }
      });
    } catch (e) {
      print('Error picking images: $e');
    }
  }

  // Method to capture an image from the camera with validation
  Future<void> _captureImageFromCamera() async {
    if (_images.length >= _maxImages) {
      Fluttertoast.showToast(
        msg: "You can only select up to $_maxImages images.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return;
    }

    try {
      final pickedFile = await ImagePicker().pickImage(source: ImageSource.camera); // Capture image from camera
      if (pickedFile == null) return;

      setState(() {
        if (_imagePaths.contains(pickedFile.path)) {
          Fluttertoast.showToast(
            msg: "Image already selected: ${pickedFile.path}",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            backgroundColor: Colors.orange,
            textColor: Colors.white,
          );
          return;
        }
        _images.add(File(pickedFile.path));
        _imagePaths.add(pickedFile.path);
      });
    } catch (e) {
      print('Error capturing image: $e');
    }
  }

  // Method to remove a specific image
  void _removeImage(int index) {
    setState(() {
      _imagePaths.remove(_images[index].path);
      _images.removeAt(index);
    });
  }

  // Method to clear all images
  void _clearAllImages() {
    setState(() {
      _images.clear();
      _imagePaths.clear();
    });
  }

  // Method to submit the form and send POST request with images
  Future<void> _submitForm() async {
    if (_foodNameController.text.isNotEmpty &&
        _sharingSizeController.text.isNotEmpty &&
        _images.isNotEmpty) {
      // Prepare multipart request
      var uri = Uri.parse('https://your-backend-url.com/donate'); // Replace with your API endpoint

      var request = http.MultipartRequest('POST', uri);

      // Add text fields to the request
      request.fields['food_name'] = _foodNameController.text;
      request.fields['sharing_size'] = _sharingSizeController.text;

      // Add images to the request
      for (var image in _images) {
        var imageBytes = await image.readAsBytes();
        var multipartFile = http.MultipartFile.fromBytes(
          'images[]',  // The name of the field for images on your server
          imageBytes,
          filename: image.path.split('/').last, // The file name
          contentType: MediaType('image', 'jpeg'), // Use http_parser's MediaType
        );
        request.files.add(multipartFile);
      }

      try {
        // Send the request and wait for the response
        var response = await request.send();
        print('Response: ${response}');

        // Check if the response is successful
        if (response.statusCode == 200) {
          Fluttertoast.showToast(
            msg: "Donation Submitted Successfully!",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            fontSize: 16.0,
          );
          _foodNameController.clear();
          _sharingSizeController.clear();
          _clearAllImages();
        } else {
          Fluttertoast.showToast(
            msg: "Failed to submit donation. Please try again.",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0,
          );
        }
      } catch (e) {
        print('Error submitting donation: $e');
        Fluttertoast.showToast(
          msg: "An error occurred while submitting donation.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    } else {
      Fluttertoast.showToast(
        msg: "Please fill in all fields and add images.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Donate Food'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Text(
                'Donation Page',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              // Food Name TextField
              TextField(
                controller: _foodNameController,
                decoration: const InputDecoration(
                  labelText: 'Food Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              // Sharing Size TextField
              TextField(
                controller: _sharingSizeController,
                decoration: const InputDecoration(
                  labelText: 'Sharing Size',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              // Image Picker Button for picking multiple images from gallery
              ElevatedButton(
                onPressed: _pickImagesFromGallery,
                child: const Text('Pick Images from Gallery'),
              ),
              const SizedBox(height: 10),
              // Camera Button for capturing an image
              ElevatedButton(
                onPressed: _captureImageFromCamera,
                child: const Text('Capture Image from Camera'),
              ),
              const SizedBox(height: 20),
              // Clear All Images Button
              _images.isNotEmpty
                  ? ElevatedButton(
                onPressed: _clearAllImages,
                child: const Text('Clear All Images'),
              )
                  : const SizedBox(),
              const SizedBox(height: 20),
              // Display selected images with individual delete buttons
              _images.isNotEmpty
                  ? GridView.builder(
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, // Display images in a 3-column grid
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: _images.length,
                itemBuilder: (context, index) {
                  return Stack(
                    children: [
                      Image.file(
                        _images[index],
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () => _removeImage(index),
                          child: const CircleAvatar(
                            backgroundColor: Colors.red,
                            radius: 12,
                            child: Icon(
                              Icons.close,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              )
                  : const Text('No images selected'),
              const SizedBox(height: 20),
              // Submit Button
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Submit Donation'),
              ),
              const SizedBox(height: 35),
            ],
          ),
        ),
      ),
    );
  }
}
