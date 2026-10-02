import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../../../app/routes.dart';
import '../../room/data/firebase_room_service.dart';

class CreateRoomScreen extends StatefulWidget {
  const CreateRoomScreen({super.key});

  @override
  State<CreateRoomScreen> createState() => _CreateRoomScreenState();
}

class _CreateRoomScreenState extends State<CreateRoomScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSavedName();
  }

  Future<void> _loadSavedName() async {
    final prefs = await SharedPreferences.getInstance();
    final savedName = prefs.getString('last_player_name');
    if (savedName != null && savedName.isNotEmpty) {
      _nameController.text = savedName;
    }
  }

  Future<void> _createRoom() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final playerName = _nameController.text.trim();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('last_player_name', playerName);

      final playerId = const Uuid().v4();
      final roomService = FirebaseRoomService();
      
      final roomCode = await roomService.createRoom(
        playerId: playerId,
        playerName: playerName,
      );

      if (!mounted) return;
      Navigator.pushReplacementNamed(
        context,
        AppRoutes.waitingRoom,
        arguments: WaitingRoomArgs(
          roomCode: roomCode,
          playerId: playerId,
          playerName: playerName,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create room: $e')),
      );
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Room'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                maxLength: 20,
                decoration: const InputDecoration(
                  labelText: 'Your Name',
                  hintText: 'Enter your name',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _createRoom,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('CREATE ROOM'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
