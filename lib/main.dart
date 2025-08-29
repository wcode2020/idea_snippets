import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'models/idea.dart';
import 'services/idea_service.dart';
import 'widgets/swipeable_card_stack.dart';

void main() {
  runApp(const IdeaSnippetsApp());
}

class IdeaSnippetsApp extends StatelessWidget {
  const IdeaSnippetsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'قصاصات الأفكار',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Arial',
      ),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  void _refreshIdeas() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: [
          IdeasListScreen(onRefresh: _refreshIdeas),
          AddIdeaScreen(onIdeaAdded: _refreshIdeas),
          SearchScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.lightbulb_outline),
            activeIcon: Icon(Icons.lightbulb),
            label: 'الأفكار',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            activeIcon: Icon(Icons.add_circle),
            label: 'إضافة',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search_outlined),
            activeIcon: Icon(Icons.search),
            label: 'البحث',
          ),
        ],
      ),
    );
  }
}

// شاشة عرض الأفكار
class IdeasListScreen extends StatefulWidget {
  final VoidCallback? onRefresh;

  const IdeasListScreen({super.key, this.onRefresh});

  @override
  State<IdeasListScreen> createState() => _IdeasListScreenState();
}

class _IdeasListScreenState extends State<IdeasListScreen> {
  final IdeaService _ideaService = IdeaService.instance;

  Future<void> _deleteIdea(String id) async {
    final success = await _ideaService.deleteIdea(id);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم حذف الفكرة بنجاح'),
          backgroundColor: Colors.green,
        ),
      );
      setState(() {});
    }
  }

  void _editIdea(Idea idea) {
    showDialog(
      context: context,
      builder: (context) => EditIdeaDialog(
        idea: idea,
        onSaved: () {
          setState(() {});
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'قصاصات الأفكار',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 0,
      ),
      body: FutureBuilder<List<Idea>>(
        future: _ideaService.loadIdeas(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text('حدث خطأ في تحميل الأفكار'),
            );
          }

          final ideas = snapshot.data ?? [];
          return SwipeableCardStack(
            ideas: ideas,
            onDelete: _deleteIdea,
            onEdit: _editIdea,
          );
        },
      ),
    );
  }
}

// حوار تعديل الفكرة
class EditIdeaDialog extends StatefulWidget {
  final Idea idea;
  final VoidCallback? onSaved;

  const EditIdeaDialog({
    super.key,
    required this.idea,
    this.onSaved,
  });

  @override
  State<EditIdeaDialog> createState() => _EditIdeaDialogState();
}

class _EditIdeaDialogState extends State<EditIdeaDialog> {
  late TextEditingController _controller;
  final IdeaService _ideaService = IdeaService.instance;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.idea.content);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (_controller.text.trim().isNotEmpty) {
      final success = await _ideaService.updateIdea(
        widget.idea.id,
        _controller.text.trim(),
      );
      
      if (success && mounted) {
        Navigator.pop(context);
        widget.onSaved?.call();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم تحديث الفكرة بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('تعديل الفكرة'),
      content: TextField(
        controller: _controller,
        maxLines: 5,
        decoration: const InputDecoration(
          hintText: 'اكتب فكرتك هنا...',
          border: OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إلغاء'),
        ),
        ElevatedButton(
          onPressed: _saveChanges,
          child: const Text('حفظ'),
        ),
      ],
    );
  }
}

// شاشة إضافة فكرة جديدة
class AddIdeaScreen extends StatefulWidget {
  final VoidCallback? onIdeaAdded;

  const AddIdeaScreen({super.key, this.onIdeaAdded});

  @override
  State<AddIdeaScreen> createState() => _AddIdeaScreenState();
}

class _AddIdeaScreenState extends State<AddIdeaScreen> {
  final TextEditingController _ideaController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final IdeaService _ideaService = IdeaService.instance;

  @override
  void dispose() {
    _ideaController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _saveIdea() async {
    if (_ideaController.text.trim().isNotEmpty) {
      final success = await _ideaService.addIdea(_ideaController.text.trim());
      
      if (success && mounted) {
        HapticFeedback.lightImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم حفظ الفكرة بنجاح!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        _ideaController.clear();
        widget.onIdeaAdded?.call();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('حدث خطأ في حفظ الفكرة'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'إضافة فكرة جديدة',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'اكتب فكرتك هنا:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey.shade300,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _ideaController,
                  focusNode: _focusNode,
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  decoration: const InputDecoration(
                    hintText: 'مثال: تطبيق لتتبع العادات اليومية...',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(16),
                  ),
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _saveIdea,
              icon: const Icon(Icons.save),
              label: const Text(
                'حفظ الفكرة',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// شاشة البحث
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final IdeaService _ideaService = IdeaService.instance;
  List<Idea> _searchResults = [];
  bool _isSearching = false;
  bool _hasSearched = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _hasSearched = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      final results = await _ideaService.searchIdeas(query);
      setState(() {
        _searchResults = results;
        _hasSearched = true;
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _searchResults = [];
        _hasSearched = true;
        _isSearching = false;
      });
    }
  }

  Future<void> _deleteIdea(String id) async {
    final success = await _ideaService.deleteIdea(id);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم حذف الفكرة بنجاح'),
          backgroundColor: Colors.green,
        ),
      );
      // إعادة البحث لتحديث النتائج
      _performSearch(_searchController.text);
    }
  }

  void _editIdea(Idea idea) {
    showDialog(
      context: context,
      builder: (context) => EditIdeaDialog(
        idea: idea,
        onSaved: () {
          // إعادة البحث لتحديث النتائج
          _performSearch(_searchController.text);
        },
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_isSearching) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (!_hasSearched) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              size: 80,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'ابحث عن أفكارك المحفوظة',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    if (_searchResults.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 80,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'لم يتم العثور على نتائج',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'جرب كلمات مختلفة للبحث',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'النتائج (${_searchResults.length})',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _searchResults.length,
            itemBuilder: (context, index) {
              final idea = _searchResults[index];
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: Text(
                      idea.content,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.4,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatDate(idea.createdAt),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        switch (value) {
                          case 'copy':
                            Clipboard.setData(ClipboardData(text: idea.content));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('تم نسخ النص'),
                                duration: Duration(seconds: 1),
                              ),
                            );
                            break;
                          case 'edit':
                            _editIdea(idea);
                            break;
                          case 'delete':
                            _showDeleteConfirmation(idea.id);
                            break;
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'copy',
                          child: Row(
                            children: [
                              Icon(Icons.copy, size: 18),
                              SizedBox(width: 8),
                              Text('نسخ'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, size: 18),
                              SizedBox(width: 8),
                              Text('تعديل'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, size: 18, color: Colors.red),
                              SizedBox(width: 8),
                              Text('حذف', style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showDeleteConfirmation(String ideaId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text('هل أنت متأكد من حذف هذه الفكرة؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteIdea(ideaId);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays} يوم مضى';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ساعة مضت';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} دقيقة مضت';
    } else {
      return 'الآن';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'البحث في الأفكار',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'ابحث عن فكرة...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _performSearch('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
              onChanged: (value) {
                _performSearch(value);
              },
            ),
          ),
          Expanded(
            child: _buildSearchResults(),
          ),
        ],
      ),
    );
  }
}

