import 'package:flutter/material.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

const int appID = 962764942; // Replace with your actual App ID
const String appSign = "348b8344094a246cb79cf834c937aa6206444c06a3a18b50244385c9ef301f09"; // Replace with your actual App Sign

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Video Call App',
      theme: ThemeData(
        primaryColor: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Future<String?> _showRoomCodeDialog(BuildContext context, bool isCreate) async {
    final TextEditingController roomCodeController = TextEditingController();
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(isCreate ? 'Start Call' : 'Join Call'),
          content: TextField(
            controller: roomCodeController,
            decoration: InputDecoration(
              hintText: 'Enter call ID',
              border: const OutlineInputBorder(),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: Text(isCreate ? 'Start' : 'Join'),
              onPressed: () {
                final roomCode = roomCodeController.text.trim();
                if (roomCode.isNotEmpty) {
                  Navigator.pop(context, roomCode);
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _handleCallAccess(BuildContext context, bool isInitiator) async {
    final callID = await _showRoomCodeDialog(context, isInitiator);
    if (callID != null && callID.isNotEmpty) {
      // ignore: use_build_context_synchronously
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CallPage(callID: callID),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Call'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.video_camera_front, size: 80, color: Colors.blue),
              const SizedBox(height: 30),
              CustomCallButton(
                label: 'Start New Call',
                color: Colors.blue,
                onPressed: () => _handleCallAccess(context, true),
              ),
              const SizedBox(height: 20),
              CustomCallButton(
                label: 'Join Call',
                color: Colors.green,
                onPressed: () => _handleCallAccess(context, false),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomCallButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const CustomCallButton({
    Key? key,
    required this.label,
    required this.color,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: color),
        onPressed: onPressed,
        child: Text(
          label,
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}

class CallPage extends StatelessWidget {
  const CallPage({Key? key, required this.callID}) : super(key: key);

  final String callID;

  void _handleOnOnlySelfInRoom(BuildContext context) {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ZegoUIKitPrebuiltCall(
        appID: appID,
        appSign: appSign,
        userID: DateTime.now().millisecondsSinceEpoch.toString(),
        userName: "user_${DateTime.now().millisecondsSinceEpoch}",
        callID: callID,
        config: ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall()
           ..onOnlySelfInRoom = _handleOnOnlySelfInRoom
          ..turnOnCameraWhenJoining = true
          ..turnOnMicrophoneWhenJoining = true
          ..useSpeakerWhenJoining = true,
      ),
    );
  }
}

extension on ZegoUIKitPrebuiltCallConfig {
  set onOnlySelfInRoom(void Function(BuildContext context) onOnlySelfInRoom) {}
}
