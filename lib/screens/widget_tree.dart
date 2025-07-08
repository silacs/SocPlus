import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:socplus/pages/home_page.dart';
import 'package:socplus/pages/profile_page.dart';
import 'package:socplus/screens/upload_post_screen.dart';
import 'package:socplus/widgets/styled_text_field.dart';

List<Widget> pages = [HomePage(), ProfilePage()];

class WidgetTree extends StatefulWidget {
  const WidgetTree({super.key});

  @override
  State<WidgetTree> createState() => _WidgetTreeState();
}

class _WidgetTreeState extends State<WidgetTree> {
  final searchController = TextEditingController();

  Widget selectedPage = pages[0];
  PreferredSize? get appBar {
    if (selectedPage == pages[0]) {
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
          statusBarColor: Theme.of(context).colorScheme.surface,
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor:
              Theme.of(context).colorScheme.surfaceContainer,
          systemNavigationBarIconBrightness: Brightness.light,
        ),
      );
      return PreferredSize(
        preferredSize: Size(MediaQuery.of(context).size.width, 65),
        child: SafeArea(
          child: Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(10),
                bottomRight: Radius.circular(10),
              ),
            ),
            child: Row(
              spacing: 10,
              children: [
                Expanded(child: StyledTextField(hint: "Search...")),
                FilledButton(
                  onPressed: () {},
                  style: FilledButton.styleFrom(
                    padding: EdgeInsets.all(16),
                    minimumSize: Size(48, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Center(child: Icon(Icons.search, size: 20)),
                ),
              ],
            ),
          ),
        ),
      );
    } else if (selectedPage == pages[1]) {
      return PreferredSize(
        preferredSize: Size(MediaQuery.of(context).size.width, 65),
        child: Container(
          height: double.infinity,
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 20),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(10),
              bottomRight: Radius.circular(10),
            ),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text("Profile Page", style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500
            ),),
          ),
        ),
      );
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      body: selectedPage,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) {
                return UploadPostScreen();
              },
            ),
          );
        },
        child: Icon(Icons.add),
      ),
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (value) {
          selectedPage = pages[value];
          setState(() {});
        },
        selectedIndex: pages.indexOf(selectedPage),
        destinations: [
          NavigationDestination(icon: Icon(Icons.home), label: "Home"),
          NavigationDestination(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}
