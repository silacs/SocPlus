import 'dart:io';
import 'package:flutter/material.dart';
import 'package:socplus/services/auth_service.dart';
import 'package:socplus/services/post_service.dart';
import 'package:socplus/widgets/styled_text_area.dart';

class UploadPostScreen extends StatefulWidget {
  const UploadPostScreen({super.key});

  @override
  State<UploadPostScreen> createState() => _UploadPostScreenState();
}

class _UploadPostScreenState extends State<UploadPostScreen> {
  final _formKey = GlobalKey<FormState>();
  final textController = TextEditingController();
  List<File> selectedImages = [];
  int selectedPrivacy = 0;
  bool pending = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Upload Post")),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 10,
              children: [
                StyledTextArea(label: Text("Text"), controller: textController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "This field is required";
                  } else {
                    return null;
                  }
                },),
                DropdownButtonFormField<int>(
                  hint: Text("Visibility"),
                  decoration: InputDecoration(border: OutlineInputBorder()),
                  value: 0,
                  items: [
                    DropdownMenuItem(value: 0, child: Text("Public")),
                    DropdownMenuItem(value: 1, child: Text("Friends")),
                    DropdownMenuItem(value: 2, child: Text("Private")),
                  ],
                  onChanged: (value) {
                    selectedPrivacy = value ?? 0;
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        selectedImages = await PostService.pickImages();
                        if (mounted) setState(() {});
                      },
                      child: Text("Select Images"),
                    ),
                    FilledButton(
                      onPressed: pending ? null : () async {
                        if (!_formKey.currentState!.validate()) return;
                        await AuthService.refreshIfExpired(context);
                        setState(() {pending = true;});
                        var response = await PostService.uploadPost(
                          textController.text,
                          selectedPrivacy,
                          selectedImages,
                        );
                        setState(() {pending = false;});
                        if (!mounted) return;
                        if (response.success && context.mounted) {
                          selectedImages = [];
                          textController.text = '';
                          _formKey.currentState!.reset();
                          setState(() {});
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Successfully uploaded post"),
                            ),
                          );
                        } else if (!response.success && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Something went wrong.")),
                          );
                        }
                      },
                      child: Text("Upload Post"),
                    ),
                  ],
                ),
                GridView.builder(
                  shrinkWrap: true,
                  itemCount: selectedImages.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 4,
                    mainAxisSpacing: 4,
                  ),
                  itemBuilder: (context, index) {
                    return Image.file(
                      selectedImages[index],
                      fit: BoxFit.cover,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
