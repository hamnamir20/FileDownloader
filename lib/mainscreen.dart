import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
class Mainscreen extends StatefulWidget {
  const Mainscreen({super.key});

  @override
  State<Mainscreen> createState() => _MainscreenState();
}

class _MainscreenState extends State<Mainscreen> {
  final TextEditingController url = TextEditingController();
  double? progress;
  bool isDownloading = false;
  String status = '';
  String? filePath;
  bool isShown = false;
  bool isDownloaded = false;

  Future<void> requestPermissions() async {
    if (Platform.isAndroid) {
      await Permission.storage.request();
      await Permission.manageExternalStorage.request();
    }
  }

  @override
  void initState() {
    super.initState();
    requestPermissions();
    url.addListener(updateDownloadButtonVisibility);
  }

  @override
  void dispose() {
    url.removeListener(updateDownloadButtonVisibility);
    url.dispose();
    super.dispose();
  }

  void updateDownloadButtonVisibility() {
    setState(() {
      isShown = url.text.trim().isNotEmpty;
    });
  }

  String getFileNameFromUrl(String url) {
    Uri uri = Uri.parse(url);
    String fileName =
    uri.pathSegments.isNotEmpty ? uri.pathSegments.last : "downloaded_file";
    if (!fileName.contains('.')) {
      fileName += '.pdf';
    }
    return fileName;
  }

  Future<String> getDownloadDirectory() async {
    Directory? directory = await getExternalStorageDirectory();
    if (directory != null) {
      return directory.path;
    }
    return (await getApplicationDocumentsDirectory()).path;
  }
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop)
          return;
        else {
          SystemNavigator.pop();
        }
      },
      child: SafeArea(
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            title: const Text(
              'File Downloader',
              style: TextStyle(color: Color(0xff79A5FA)),
            ),
            centerTitle: true,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Divider(height: 1, color: Color(0xff79A5FA)),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.only(
              left: 16.0,
              right: 16,
              top: 56,
              bottom: 32,
            ),
            child: Column(
              children: [
                Image.asset(
                  'assets/logo.png',
                  height: 222,
                  width: 222,
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 48.0, top: 20),
                  child: Text(
                    'Download any file!',
                    style: TextStyle(
                      color: Color(0xff79A5FA),
                      fontWeight: FontWeight.w600,
                      fontSize: 30,
                    ),
                  ),
                ),
                TextField(
                  style: const TextStyle(color: Colors.white),
                  controller: url,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Color(0xff79A5FA).withOpacity(0.5),
                    suffixIcon: GestureDetector(
                      onTap: () {
                        url.clear();
                        setState(() {
                          progress = null;
                          status = '';
                          filePath = null;
                          isShown = false;
                          isDownloaded = false;
                        });
                      },
                      child: const Icon(Icons.clear, color: Colors.white),
                    ),
                    hintText: 'Enter URL',
                    hintStyle: const TextStyle(color: Colors.white),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xff79A5FA)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color:Color(0xff79A5FA)),
                    ),
                  ),
                  keyboardType: TextInputType.url,
                ),
                const SizedBox(height: 40),
                Spacer(),
        
                if (progress != null)
                  Column(
                    children: [
                      CircularProgressIndicator(value: progress),
                      const SizedBox(height: 10),
                      Text(
                        'Downloading: ${(progress! * 100).clamp(1, 100).toStringAsFixed(0)}%',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                SizedBox(height: 30),

                if (isShown)
                  GestureDetector(
                    onTap: !isDownloading && !isDownloaded ? startDownload : (isDownloaded ? openFile : null),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xff2563EB),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          isDownloaded ? 'Open File' : 'Download',
                          style: GoogleFonts.inter(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ),
        
                //  const SizedBox(height: 20),
        
                if (status.isNotEmpty)
                  Text(
                    status,
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                if (filePath != null && filePath!.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap:openFile,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 12,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xff2563EB),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          'Open File',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
  void startDownload() async {
    setState(() {
      isDownloading = true;
      progress = 0.0;
      status = '';
      filePath = null;
    });

    String fileName = getFileNameFromUrl(url.text.trim());
    String dirPath = await getDownloadDirectory();
    String fullPath = '$dirPath/$fileName';

    FileDownloader.downloadFile(
      url: url.text.trim(),
      name: fileName,
      downloadDestination: DownloadDestinations.publicDownloads,
      onProgress: (name, progress) {
        setState(() {
          progress = progress;
        });
      },
      onDownloadCompleted: (path) {
        setState(() {
          progress = null;
          isDownloading = false;
          status = 'Download completed';
          filePath = path;
          isDownloaded = true;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('File downloaded successfully')),
        );
      },
      onDownloadError: (errorMessage) {
        setState(() {
          progress = null;
          isDownloading = false;
          status = 'Download failed: $errorMessage';
          isDownloaded = false;
        });
      },
    );
  }

  void openFile() async {
    if (filePath == null || filePath!.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('File path is empty!')));
      return;
    }

    File file = File(filePath!);
    if (!file.existsSync()) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('File does not exist!')));
      return;
    }

    try {
      final result = await OpenFile.open(filePath!);
      if (result.type == ResultType.done) {
        setState(() {
          url.clear();
          isDownloaded = false;
          isShown = true;
          filePath = null;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Cannot open file: ${result.message}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error opening file: $e')));
    }
  }
}
