import 'package:flutter/material.dart';
import 'package:socplus/screens/search_screen.dart';
import 'package:socplus/widgets/styled_text_field.dart';

class SearchAppBar extends StatelessWidget implements PreferredSizeWidget {
  final searchController = TextEditingController();
  SearchAppBar({super.key});
  
  @override
  Size get preferredSize => Size.fromHeight(65);

  @override
  Widget build(BuildContext context) {
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
                Expanded(child: StyledTextField(hint: "Search...", controller: searchController,)),
                FilledButton(
                  onPressed: () {
                    if (searchController.text != '') {
                      Navigator.push(context, MaterialPageRoute(builder: (context) {
                        return SearchScreen(keywords: searchController.text,);
                      },));
                    }
                  },
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
  }
}