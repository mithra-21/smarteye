import 'package:flutter/material.dart';
import '../utils/colors.dart';

class SlidingTabController extends StatefulWidget {
  final Function(int) onTabChanged;

  const SlidingTabController({Key? key, required this.onTabChanged})
      : super(key: key);

  @override
  _SlidingTabControllerState createState() => _SlidingTabControllerState();
}

class _SlidingTabControllerState extends State<SlidingTabController>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        widget.onTabChanged(_tabController.index);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 55,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(30),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final tabWidth = constraints.maxWidth / 2;
          return Stack(
            children: [
              AnimatedBuilder(
                animation: _tabController.animation!,
                builder: (context, child) {
                  return Positioned(
                    left: _tabController.animation!.value * tabWidth,
                    width: tabWidth,
                    height: 55,
                    child: child!,
                  );
                },
                child: Container(
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.5),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.pinkAccent.withOpacity(0.4),
                        blurRadius: 15,
                        spreadRadius: 2,
                      )
                    ],
                  ),
                ),
              ),
              TabBar(
                controller: _tabController,
                indicatorColor: Colors.transparent,
                dividerColor: Colors.transparent,
                tabs: const [
                  Tab(text: 'Sign Up'),
                  Tab(text: 'Sign In'),
                ],
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.white,
                ),
                unselectedLabelStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.5),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
