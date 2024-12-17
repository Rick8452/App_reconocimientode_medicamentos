
import 'dart:io';

import 'package:tflite_v2/tflite_v2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';




void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late List _outputs;
  late File? _image;
  bool isLoading = false;
  final picker = ImagePicker();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    isLoading = true;
    loadModel().then((value) {
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Teacheable Machine"),
        centerTitle: true,
      ),
      body: isLoading
          ? Container(
        alignment: Alignment.center,
        child: CircularProgressIndicator(),
      )
          : Container(
        width: MediaQuery.of(context).size.width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _image == null ? Container() : Image.file(_image!),
            SizedBox(
              height: 20,
            ),
            _outputs != null
                ? Text(
              "${_outputs[0]["label"]}",
              style: TextStyle(
                color: Colors.black,
                fontSize: 30.0,
                background: Paint()..color = Colors.white,
              ),
            )
                : Container()
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: pickImage,
        child: Icon(Icons.image),
      ),
    );
  }

  //cargar modelo
  loadModel() async {
    await Tflite.loadModel(
        model: "assets/model_unquant.tflite",
        labels: ".idea/assets/labels.txt");
  }

  // cargar imagen
  pickImage() async {
    var image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) {
      return null;
    }
    setState(() {
      isLoading = true;
      _image = File (image.path);
    });
    classifyImage(_image);
  }

  classifyImage(image) async {
    var output = await Tflite.runModelOnImage(
        path: image.path,
        numResults: 5,
        threshold: 0.5,
        imageMean: 127.5,
        imageStd: 127.5);
    setState(() {
      isLoading = false;
      _outputs = output!;
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    Tflite.close();
    super.dispose();
  }
}
