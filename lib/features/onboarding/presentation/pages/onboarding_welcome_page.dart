import 'package:flutter/material.dart';
import '../../../../core/theme/cyber_theme.dart';

class OnboardingWelcomePage extends StatefulWidget {
  final VoidCallback onNext;
  const OnboardingWelcomePage({super.key, required this.onNext});

  @override
  State<OnboardingWelcomePage> createState() => _OnboardingWelcomePageState();
}

class _OnboardingWelcomePageState extends State<OnboardingWelcomePage> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _slides = [
    {
      'title': 'Privacy First',
      'description': 'Your health data is encrypted and stored only on your device. We don\'t have access to it.',
      'icon': 'lock',
    },
    {
      'title': 'Local AI',
      'description': 'Processing happens locally. Your private information never leaves your phone.',
      'icon': 'memory',
    },
    {
      'title': 'Own Your Data',
      'description': 'You have full control. Export or delete your data at any time.',
      'icon': 'person',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: PageView.builder(
            controller: _controller,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: _slides.length,
            itemBuilder: (context, index) {
              final slide = _slides[index];
              return Padding(
                padding: const EdgeInsets.all(40.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _getIcon(slide['icon']!),
                      size: 100,
                      color: CyberTheme.primary,
                    ),
                    const SizedBox(height: 40),
                    Text(
                      slide['title']!,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: CyberTheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      slide['description']!,
                      style: Theme.of(context).textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _slides.length,
            (index) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _currentPage == index ? CyberTheme.primary : Colors.grey,
              ),
            ),
          ),
        ),
        const SizedBox(height: 40),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: ElevatedButton(
            onPressed: () {
              if (_currentPage < _slides.length - 1) {
                _controller.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              } else {
                widget.onNext();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: CyberTheme.primary,
              foregroundColor: CyberTheme.backgroundDark,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(_currentPage == _slides.length - 1 ? 'Get Started' : 'Next'),
          ),
        ),
        const SizedBox(height: 60),
      ],
    );
  }

  IconData _getIcon(String name) {
    switch (name) {
      case 'lock':
        return Icons.lock_outline;
      case 'memory':
        return Icons.memory;
      case 'person':
        return Icons.person_outline;
      default:
        return Icons.help_outline;
    }
  }
}
