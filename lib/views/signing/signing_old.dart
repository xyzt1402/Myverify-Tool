import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:ui';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:learningdart/services/auth/auth_services.dart';
import 'package:learningdart/services/cloud/firebase_cloud_storage.dart';
import 'package:open_file_plus/open_file_plus.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:pointycastle/digests/sha256.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:syncfusion_flutter_signaturepad/signaturepad.dart';
import 'package:pdf_render/pdf_render.dart';
import 'package:image/image.dart' as imglib;
import 'package:syncfusion_flutter_pdf/pdf.dart' as spdf;
import 'dart:developer' show log;

class SignatureView extends StatefulWidget {
  const SignatureView({super.key});

  @override
  State<SignatureView> createState() => _SignatureViewState();
}

class _SignatureViewState extends State<SignatureView> {
  late final TextEditingController _fullName;
  late final TextEditingController _location;
  late final TextEditingController _reason;
  late final FirebaseCloudStorage _tokenService;

  final GlobalKey<SfSignaturePadState> _signaturePadStateKey = GlobalKey();
  static final GlobalKey _repaintKey = GlobalKey();

  String? filePath;
  String? hashValue;
  FilePickerResult? resultfile;
  PlatformFile? filetype;
  String? imgSelectedPath;
  File? qrCodeFile;
  File? padSignFile;
  File? fSignPath;

  String get userId => AuthService.firebase().currentUser!.id;

  @override
  void initState() {
    _fullName = TextEditingController();
    _location = TextEditingController();
    _reason = TextEditingController();
    _tokenService = FirebaseCloudStorage();
    super.initState();
  }

  @override
  void dispose() {
    _fullName.dispose();
    _location.dispose();
    _reason.dispose();
    super.dispose();
  }

  Future<String> getFilePath() async {
    Directory appDocumentsDirectory = await getApplicationDocumentsDirectory();
    String appDocumentsPath = appDocumentsDirectory.path;

    return appDocumentsPath;
  }

  Future<void> pickFile() async {
    resultfile = await FilePicker.platform.pickFiles();
    if (resultfile == null || resultfile!.files.isEmpty) return;
    filetype = resultfile!.files.first;
    filePath = resultfile!.files.single.path;

    File file = File(resultfile!.files.single.path!);
    final doc = await PdfDocument.openFile(filePath!);
    List<imglib.Image> images = [];
    // get images from all the pages

    var page = await doc.getPage(1);
    var imgPDF = await page.render();
    var img = await imgPDF.createImageDetached();
    var imgBytes = await img.toByteData(format: ImageByteFormat.png);
    var libImage = imglib.decodeImage(imgBytes?.buffer.asUint8List(
        imgBytes.offsetInBytes, imgBytes.lengthInBytes) as List<int>);
    images.add(libImage!);

    // Save image as a file
    final documentDirectory = await getExternalStorageDirectory();

    File firstImg = File('${documentDirectory?.path}/firstpage.jpg');
    File(firstImg.path).writeAsBytes(imglib.encodeJpg(images[0]));
    imgSelectedPath = '${documentDirectory?.path}/firstpage.jpg';
    // Hash document

    final sha256 = SHA256Digest();
    final hash256 = sha256.process(file.readAsBytesSync());
    hashValue = base64Url.encode(hash256);
    await Future.delayed(const Duration(milliseconds: 200));
    setState(() {});
  }

  Future<File> saveAsImage() async {
    ui.Image image = await _signaturePadStateKey.currentState!.toImage();
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final Uint8List imageBytes = byteData!.buffer.asUint8List(
      byteData.offsetInBytes,
      byteData.lengthInBytes,
    );
    late final currentUser = AuthService.firebase().currentUser!;
    final String path = (await getApplicationSupportDirectory()).path;
    final String filename = '$path/${currentUser.email}.signature.png}';
    final File file = File(filename);

    await file.writeAsBytes(imageBytes, flush: true);
    return file;
  }

  Future<String> createFolderInAppDocDir(String folderName) async {
    //Get this App Document Directory

    final Directory appDocDir = await getApplicationDocumentsDirectory();
    //App Document Directory + folder name
    final Directory appDocDirFolder =
        Directory('${appDocDir.path}/$folderName/');

    if (await appDocDirFolder.exists()) {
      //if folder already exists return path
      return appDocDirFolder.path;
    } else {
      //if folder not exists create folder and then return its path
      final Directory appDocDirNewFolder =
          await appDocDirFolder.create(recursive: true);
      return appDocDirNewFolder.path;
    }
  }

  Future<File> createQrCode(
    String fullname,
    String location,
    String reason,
  ) async {
    late final currentUser = AuthService.firebase().currentUser!;

    // Load the private key from the PEM file
    File file =
        File('${await getFilePath()}/${currentUser.email}.privatekey.pem');
    final pem = file.readAsStringSync();
    final key = ECPrivateKey(pem);

    // Create the JWT payload with information

    final jwt = JWT({
      'FullName': fullname,
      'Location': location,
      'Reason': reason,
      'Contact': currentUser.email,
      'HashDoc': hashValue,
      'Time': DateTime.now().millisecondsSinceEpoch ~/ 1000
    }, issuer: 'QRCodeVerify');
    final token = jwt.sign(key, algorithm: JWTAlgorithm.ES256);
    //Upload Token to secret place to get doc id for shorter qrcode
    final newToken = await _tokenService.uploadNewToken(
        ownerUserId: userId, tokenValue: token);
    // Create a QR code and save it as an image file
    final painter = await QrPainter(
      data: newToken.documentId,
      version: QrVersions.auto,
      gapless: false,
      emptyColor: Colors.white,
      color: const Color(0xFF000000),
      embeddedImageStyle: null,
      embeddedImage: null,
    ).toImageData(200.0);
    // Save the bytes to a file
    final qrCodePath =
        '${await getFilePath()}/${currentUser.email}.qrcode.png}';
    File qrfile = await File(qrCodePath).create();
    await qrfile.writeAsBytes(painter!.buffer.asUint8List());
    return qrfile;
  }

  Future<void> modifyPDf() async {
    final spdf.PdfDocument document =
        spdf.PdfDocument(inputBytes: File(filePath!).readAsBytesSync());
    final Uint8List imageData = fSignPath!.readAsBytesSync();
    //Load the image using PdfBitmap.
    final spdf.PdfBitmap image = spdf.PdfBitmap(imageData);
    //Draw the image to the PDF page.
    document.pages
        .add()
        .graphics
        .drawImage(image, const Rect.fromLTWH(0, 0, 380, 300));
    // Save the document.
    final expath = await createFolderInAppDocDir('pdf-signed-storage');
    File file = File('$expath/${filetype!.name}-signed.pdf');
    await File(file.path).writeAsBytes(await document.save());
    document.dispose();

    OpenFile.open(file.path);
  }

  Future<File> takeScreenShot() async {
    RenderRepaintBoundary boundary =
        _repaintKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage();
    ByteData byteData =
        await image.toByteData(format: ui.ImageByteFormat.png) as ByteData;
    Uint8List pngBytes = byteData.buffer.asUint8List();
    final path =
        join((await getTemporaryDirectory()).path, "screenshotnow.png");
    File imgFile = File(path);
    imgFile.writeAsBytes(pngBytes);
    return imgFile;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(title: const Text('Sign PDF document')),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const Text('Please add YOUR information to sign a document.'),
                ElevatedButton(
                    onPressed: pickFile,
                    child: const Text('Pick a pdf to sign')),
                if (filetype != null) buildFile(filetype!),
                TextField(
                  controller: _fullName,
                  enableSuggestions: false,
                  autocorrect: false,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    hintText: 'Enter your name here',
                  ),
                ),
                TextField(
                  controller: _location,
                  enableSuggestions: false,
                  autocorrect: false,
                  decoration: const InputDecoration(
                    hintText: 'Enter your location here',
                  ),
                ),
                TextField(
                  controller: _reason,
                  enableSuggestions: false,
                  autocorrect: false,
                  decoration: const InputDecoration(
                    hintText: 'Enter your reason to sign here',
                  ),
                ),
                SfSignaturePad(
                  key: _signaturePadStateKey,
                  backgroundColor: const Color.fromARGB(255, 222, 218, 217),
                  strokeColor: Colors.black,
                  minimumStrokeWidth: 4.0,
                  maximumStrokeWidth: 6.0,
                ),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SizedBox(
                        width: 125,
                        child: ElevatedButton(
                          onPressed: () async {
                            _signaturePadStateKey.currentState!.clear();
                          },
                          child: const Text('Clear'),
                        ),
                      ),
                      SizedBox(
                          width: 110,
                          child: ElevatedButton(
                              onPressed: () async {
                                final fullName = _fullName.text;
                                final location = _location.text;
                                final reason = _reason.text;
                                qrCodeFile = await createQrCode(
                                    fullName, location, reason);
                                padSignFile = await saveAsImage();
                                setState(() {});

                                fSignPath = await takeScreenShot();
                                await Future.delayed(
                                    const Duration(milliseconds: 200));
                                fSignPath = await takeScreenShot();
                              },
                              child: const Text('Show Sign'))),
                    ]),
                RepaintBoundary(
                  key: _repaintKey,
                  child: Stack(
                    children: [
                      Image.network(
                          'https://images.unsplash.com/photo-1612538498456-e861df91d4d0?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1074&q=80',
                          height: 300,
                          width: 800,
                          fit: BoxFit.cover),
                      Positioned.fill(
                          child: Align(
                        alignment: const Alignment(0, -0.95),
                        child: Text(
                          'Fullname: ${_fullName.text}',
                          style: const TextStyle(
                              color: ui.Color.fromARGB(255, 0, 0, 0),
                              fontSize: 16),
                        ),
                      )),
                      Positioned.fill(
                          child: Align(
                        alignment: const Alignment(0, -0.78),
                        child: Text(
                          'Location: ${_location.text}',
                          style: const TextStyle(
                              color: ui.Color.fromARGB(255, 0, 0, 0),
                              fontSize: 16),
                        ),
                      )),
                      Positioned.fill(
                          child: Align(
                        alignment: const Alignment(0, -0.61),
                        child: Text(
                          'Reason: ${_reason.text}',
                          style: const TextStyle(
                              color: ui.Color.fromARGB(255, 0, 0, 0),
                              fontSize: 16),
                        ),
                      )),
                      Positioned.fill(
                          child: Align(
                        alignment: const Alignment(0, -0.44),
                        child: Text(
                          'Time Signed: ${DateTime.now()}',
                          style: const TextStyle(
                              color: ui.Color.fromARGB(255, 0, 0, 0),
                              fontSize: 16),
                        ),
                      )),
                      if (qrCodeFile != null)
                        Positioned.fill(
                            child: Align(
                                alignment: const Alignment(0.87, 0.80),
                                child: Image.memory(
                                  qrCodeFile!.readAsBytesSync(),
                                  height: 180,
                                  width: 180,
                                  fit: BoxFit.cover,
                                ))),
                      if (padSignFile != null)
                        Positioned.fill(
                            child: Align(
                                alignment: const Alignment(-0.93, 0.45),
                                child: Image.memory(
                                  padSignFile!.readAsBytesSync(),
                                  height: 160,
                                  width: 160,
                                  fit: BoxFit.contain,
                                ))),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(
                      width: 110,
                      child: ElevatedButton(
                          onPressed: () {
                            modifyPDf();
                          },
                          child: const Text('Save to pdf')),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildFile(PlatformFile file) {
    final kb = file.size / 1024;
    final mb = kb / 1024;
    final size = (mb >= 1)
        ? '${mb.toStringAsFixed(2)} MB'
        : '${kb.toStringAsFixed(2)} KB';
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: InkWell(
        child: ListTile(
          leading: Image.memory(
            File(imgSelectedPath!).readAsBytesSync(),
            width: 80,
            height: 80,
          ),
          title: Text(file.name),
          subtitle: Text('${file.extension}'),
          trailing: Text(
            size,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }
}
