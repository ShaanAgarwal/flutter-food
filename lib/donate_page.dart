import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';

class DonatePage extends StatefulWidget {
  const DonatePage({super.key});

  @override
  _DonatePageState createState() => _DonatePageState();
}

class _DonatePageState extends State<DonatePage> {
  final _foodNameController = TextEditingController();
  final _sharingSizeController = TextEditingController();
  File? _image;  // Store the image picked from the gallery

  // Method to pick an image from the gallery
  Future<void> _pickImage() async {
    try {
      // Pick image from gallery instead of camera
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image == null) return;
      setState(() {
        _image = File(image.path);
      });
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  // Method to submit the form
  void _submitForm() {
    if (_foodNameController.text.isNotEmpty &&
        _sharingSizeController.text.isNotEmpty &&
        _image != null) {
      // You can send this data to your backend if needed, here just showing a success message
      Fluttertoast.showToast(
        msg: "Donation Submitted Successfully!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      // Reset form fields after submission
      _foodNameController.clear();
      _sharingSizeController.clear();
      setState(() {
        _image = null;
      });
    } else {
      Fluttertoast.showToast(
        msg: "Please fill in all fields and add a photo.",
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
            // Image Picker Button (changed from "Take a Photo" to "Pick from Gallery")
            ElevatedButton(
              onPressed: _pickImage,
              child: const Text('Pick Image from Gallery'),
            ),
            const SizedBox(height: 20),
            // Display selected image if available
            _image != null
                ? Image.file(
              _image!,
              width: 150,
              height: 150,
              fit: BoxFit.cover,
            )
                : const Text('No image selected'),
            const SizedBox(height: 20),
            // Submit Button
            ElevatedButton(
              onPressed: _submitForm,
              child: const Text('Submit Donation'),
            ),
          ],
        ),
      ),
    );
  }
}
