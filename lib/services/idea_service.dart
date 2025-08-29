import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/idea.dart';

class IdeaService {
  static const String _storageKey = 'ideas_storage';
  static IdeaService? _instance;
  
  IdeaService._();
  
  static IdeaService get instance {
    _instance ??= IdeaService._();
    return _instance!;
  }

  // حفظ قائمة الأفكار
  Future<void> _saveIdeas(List<Idea> ideas) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = ideas.map((idea) => idea.toJson()).toList();
    await prefs.setString(_storageKey, jsonEncode(jsonList));
  }

  // تحميل قائمة الأفكار
  Future<List<Idea>> loadIdeas() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_storageKey);
      
      if (jsonString == null) {
        return [];
      }

      final jsonList = jsonDecode(jsonString) as List<dynamic>;
      return jsonList
          .map((json) => Idea.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('خطأ في تحميل الأفكار: $e');
      return [];
    }
  }

  // إضافة فكرة جديدة
  Future<bool> addIdea(String content) async {
    try {
      if (content.trim().isEmpty) {
        return false;
      }

      final ideas = await loadIdeas();
      final newIdea = Idea.create(content.trim());
      ideas.insert(0, newIdea); // إضافة في المقدمة
      
      await _saveIdeas(ideas);
      return true;
    } catch (e) {
      print('خطأ في إضافة الفكرة: $e');
      return false;
    }
  }

  // تحديث فكرة
  Future<bool> updateIdea(String id, String newContent) async {
    try {
      if (newContent.trim().isEmpty) {
        return false;
      }

      final ideas = await loadIdeas();
      final index = ideas.indexWhere((idea) => idea.id == id);
      
      if (index == -1) {
        return false;
      }

      ideas[index] = ideas[index].updateContent(newContent.trim());
      await _saveIdeas(ideas);
      return true;
    } catch (e) {
      print('خطأ في تحديث الفكرة: $e');
      return false;
    }
  }

  // حذف فكرة
  Future<bool> deleteIdea(String id) async {
    try {
      final ideas = await loadIdeas();
      final initialLength = ideas.length;
      ideas.removeWhere((idea) => idea.id == id);
      
      if (ideas.length == initialLength) {
        return false; // لم يتم العثور على الفكرة
      }

      await _saveIdeas(ideas);
      return true;
    } catch (e) {
      print('خطأ في حذف الفكرة: $e');
      return false;
    }
  }

  // البحث في الأفكار
  Future<List<Idea>> searchIdeas(String query) async {
    try {
      if (query.trim().isEmpty) {
        return await loadIdeas();
      }

      final ideas = await loadIdeas();
      final searchQuery = query.trim().toLowerCase();
      
      return ideas.where((idea) {
        return idea.content.toLowerCase().contains(searchQuery);
      }).toList();
    } catch (e) {
      print('خطأ في البحث: $e');
      return [];
    }
  }

  // الحصول على فكرة بالمعرف
  Future<Idea?> getIdeaById(String id) async {
    try {
      final ideas = await loadIdeas();
      return ideas.firstWhere(
        (idea) => idea.id == id,
        orElse: () => throw StateError('لم يتم العثور على الفكرة'),
      );
    } catch (e) {
      print('خطأ في الحصول على الفكرة: $e');
      return null;
    }
  }

  // حذف جميع الأفكار
  Future<bool> clearAllIdeas() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_storageKey);
      return true;
    } catch (e) {
      print('خطأ في حذف جميع الأفكار: $e');
      return false;
    }
  }

  // الحصول على عدد الأفكار
  Future<int> getIdeasCount() async {
    try {
      final ideas = await loadIdeas();
      return ideas.length;
    } catch (e) {
      print('خطأ في الحصول على عدد الأفكار: $e');
      return 0;
    }
  }
}

