// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:gemini_chat_app_tutorial/controller/controller.dart';
// import 'package:gemini_chat_app_tutorial/firebase_options.dart';
// import 'package:gemini_chat_app_tutorial/pages/splash_screen.dart';
// import 'package:get/get.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
//   Get.lazyPut(() => ChatController());

//   runApp(const GenerativeAISample());
// }

// class GenerativeAISample extends StatelessWidget {
//   const GenerativeAISample({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return ScreenUtilInit(
//       minTextAdapt: true,
//       splitScreenMode: true,
//       child: GetMaterialApp(
//         title: 'Gemini Chat App',
//         debugShowCheckedModeBanner: false,
//         theme: ThemeData(
//           colorScheme: ColorScheme.fromSeed(
//             brightness: Brightness.dark,
//             seedColor: const Color.fromARGB(255, 171, 222, 244),
//           ),
//           useMaterial3: true,
//         ),
//         home: const SplashScreen(),
//       ),
//     );
//   }
// }
import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_3d_controller/flutter_3d_controller.dart';
import 'package:gemini_chat_app_tutorial/firebase_options.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(MyHomePage());
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Flutter3DController controller = Flutter3DController();
  String? firebaseGlbUrl;

  @override
  void initState() {
    super.initState();
    _downloadAndUploadGlb();
  }

  Future<void> _downloadAndUploadGlb() async {
    try {
      // Download the GLB file dynamically in-memory (without saving to file)
      String fileUrl =
          'https://assets.meshy.ai/bdddb4f3-2c9a-441f-ad51-4e9f46f9fa37/tasks/0191e4e2-4d5e-76a6-a964-3024011c98e0/output/model.glb?Expires=4879699200&Signature=eV-sA30NothJsISbfsoBnuV7lSQgJ0Q7hjFwXCiogs31U4tg4gxC3z-Cc8dbOu6Bs8vuK9wA-TwgS2MsYcup09Uid7fLL1Lu0pRMnOt8aRmLayWbohy9nJapB4MaCC67hXGP3TVdmyCctZ7iRRtyjnpvgq5QPpUBp7S6ZevxSnxz8bOXaOa-VZ0t6vShYGK7QNVrTvsgxPd7scQMmz9Qi5eT6sEXHYKQnawLIVRN5vxP9kgJCw7Qqwplbs0egSkUWXGAkMyTVMXKeNwManAxpjsp8pGpneMBKE-Ivfc09gFcjfSs82FdXecIVYaxSAfLnNsbZxOmlnVH9NxWJSSsnA__&Key-Pair-Id=KL5I0C8H7HX83'; // Your GLB URL
      http.Response response = await http.get(Uri.parse(fileUrl));

      if (response.statusCode == 200) {
        Uint8List fileBytes = response.bodyBytes;

        // Upload to Firebase Storage
        FirebaseStorage storage = FirebaseStorage.instance;
        String storagePath =
            'models/model_${DateTime.now().millisecondsSinceEpoch}.glb';

        // Upload the file bytes directly to Firebase Storage
        TaskSnapshot snapshot =
            await storage.ref(storagePath).putData(fileBytes);

        // Get the URL from Firebase
        String downloadUrl = await snapshot.ref.getDownloadURL();

        setState(() {
          firebaseGlbUrl =
              downloadUrl; // This URL can be used to display the model
        });
      } else {
        throw Exception("Failed to download the file");
      }
    } catch (e) {
      print("Error occurred while downloading or uploading: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("GLB Viewer"),
      ),
      body: firebaseGlbUrl == null
          ? Center(
              child: CircularProgressIndicator()) // Show a loading indicator
          : Container(
              color: Colors.grey,
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: Flutter3DViewer(
                controller: controller,
                src:
                    firebaseGlbUrl!, // Load the model from Firebase Storage URL
              ),
            ),
    );
  }
}
