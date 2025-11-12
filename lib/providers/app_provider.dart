import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/note_service.dart';

class AppProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final NoteService _noteService = NoteService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  List<dynamic> _notes = [];
  List<dynamic> get notes => _notes;

  dynamic _currentUser;
  dynamic get currentUser => _currentUser;

  // Auth
  Future<void> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _authService.login(email, password);
      _currentUser = await _authService.getCurrentUser();
    } catch (e) {
      _error = 'Login error: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> register(String name, String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _authService.register(email, password, name);
      await login(email, password);
    } catch (e) {
      _error = 'Registration error: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _currentUser = null;
    _notes = [];
    notifyListeners();
  }

  Future<void> fetchNotes() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final fetchedNotes = await _noteService.getNotes();
      _notes = fetchedNotes;
    } catch (e) {
      _error = 'Failed to load notes: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void addNote(dynamic note) {
    _notes = [note, ..._notes];
    notifyListeners();
  }

  void updateNote(dynamic note) {
    _notes = _notes.map((n) => n.$id == note.$id ? note : n).toList();
    notifyListeners();
  }

  void deleteNote(String noteId) {
    _notes = _notes.where((n) => n.$id != noteId).toList();
    notifyListeners();
  }
}
