import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;

class TasksScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tasks'),
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Daily Tasks',
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            _buildTaskItem(
                context, 'Take a Photo', 'Earn 50 EcoCoins', Icons.camera_alt),
            _buildTaskItem(context, 'Public Transport', 'Earn 30 EcoCoins',
                Icons.directions_bus),
            _buildTaskItem(context, 'Reusable Bag', 'Earn 20 EcoCoins',
                Icons.shopping_bag),
            // Add more tasks as needed
          ],
        ),
      ),
    );
  }

  Future<void> _handleTaskCompletion(BuildContext context) async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TakePictureScreen(camera: firstCamera),
      ),
    );
  }

  Widget _buildTaskItem(BuildContext context, String title, String description,
      IconData iconData) {
    return ListTile(
      leading: Icon(iconData),
      title: Text(title),
      subtitle: Text(description),
      onTap: () {
        _handleTaskCompletion(context);
      },
    );
  }
}

class TakePictureScreen extends StatefulWidget {
  final CameraDescription camera;

  const TakePictureScreen({Key? key, required this.camera}) : super(key: key);

  @override
  _TakePictureScreenState createState() => _TakePictureScreenState();
}

class _TakePictureScreenState extends State<TakePictureScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.medium,
    );
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Take a Picture')),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return CameraPreview(_controller);
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.camera),
        onPressed: () async {
          try {
            await _initializeControllerFuture;
            final image = await _controller.takePicture();
            // Handle image upload to server
            _uploadImage(image.path);
            Navigator.pop(context);
          } catch (e) {
            print('Error: $e');
          }
        },
      ),
    );
  }

  void _uploadImage(String imagePath) async {
    File imageFile = File(imagePath);
    try {
      var response = await http.post(
        Uri.parse('http://localhost:3000/fileupload'),
        body: {'file': imageFile},
      );
      if (response.statusCode == 200) {
        // File uploaded successfully
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('File uploaded successfully!'),
          ),
        );
      } else {
        // Error uploading file
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error uploading file!'),
          ),
        );
      }
    } catch (e) {
      // Error handling request
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
        ),
      );
    }
  }
}
