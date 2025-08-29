import 'package:flutter/material.dart';
import '../models/idea.dart';
import 'idea_card.dart';

class SwipeableCardStack extends StatefulWidget {
  final List<Idea> ideas;
  final Function(String)? onDelete;
  final Function(Idea)? onEdit;

  const SwipeableCardStack({
    super.key,
    required this.ideas,
    this.onDelete,
    this.onEdit,
  });

  @override
  State<SwipeableCardStack> createState() => _SwipeableCardStackState();
}

class _SwipeableCardStackState extends State<SwipeableCardStack>
    with TickerProviderStateMixin {
  late PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextCard() {
    if (_currentIndex < widget.ideas.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousCard() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.ideas.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lightbulb_outline,
              size: 80,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'لا توجد أفكار بعد',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'اضغط على "إضافة" لحفظ فكرتك الأولى',
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
      children: [
        // مؤشر الموقع
        if (widget.ideas.length > 1)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${_currentIndex + 1} من ${widget.ideas.length}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

        // البطاقات
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemCount: widget.ideas.length,
            itemBuilder: (context, index) {
              final idea = widget.ideas[index];
              return IdeaCard(
                idea: idea,
                onDelete: () => widget.onDelete?.call(idea.id),
                onEdit: () => widget.onEdit?.call(idea),
              );
            },
          ),
        ),

        // أزرار التنقل
        if (widget.ideas.length > 1)
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // السابق
                FloatingActionButton(
                  heroTag: "previous",
                  onPressed: _currentIndex > 0 ? _previousCard : null,
                  backgroundColor: _currentIndex > 0
                      ? Theme.of(context).colorScheme.secondary
                      : Colors.grey.shade300,
                  child: Icon(
                    Icons.arrow_back_ios,
                    color: _currentIndex > 0 ? Colors.white : Colors.grey,
                  ),
                ),

                // مؤشر النقاط
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(
                    widget.ideas.length > 5 ? 5 : widget.ideas.length,
                    (index) {
                      int displayIndex = index;
                      if (widget.ideas.length > 5) {
                        if (_currentIndex < 2) {
                          displayIndex = index;
                        } else if (_currentIndex > widget.ideas.length - 3) {
                          displayIndex = widget.ideas.length - 5 + index;
                        } else {
                          displayIndex = _currentIndex - 2 + index;
                        }
                      }

                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: displayIndex == _currentIndex
                              ? Theme.of(context).colorScheme.primary
                              : Colors.grey.shade300,
                        ),
                      );
                    },
                  ),
                ),

                // التالي
                FloatingActionButton(
                  heroTag: "next",
                  onPressed: _currentIndex < widget.ideas.length - 1
                      ? _nextCard
                      : null,
                  backgroundColor: _currentIndex < widget.ideas.length - 1
                      ? Theme.of(context).colorScheme.secondary
                      : Colors.grey.shade300,
                  child: Icon(
                    Icons.arrow_forward_ios,
                    color: _currentIndex < widget.ideas.length - 1
                        ? Colors.white
                        : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

