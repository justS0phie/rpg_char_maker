import 'package:flutter/material.dart';

import '../models/character.dart';
import '../models/template.dart';
import '../services/template_service.dart';
import 'character_editor_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  final templateService = TemplateService();

  List<Template> templates = [];
  List<Character> characters = [];

  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadTemplates();
  }

  Future<void> loadTemplates() async {
    templates = await templateService.fetchTemplates();

    setState(() {
      loading = false;
    });
  }

  void createCharacter(Template template) {

    final character = Character(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: "New Character",
      templateId: template.id,
    );

    characters.add(character);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CharacterEditorScreen(
          character: character,
          template: template,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Characters"),
      ),

      body: ListView(
        children: characters.map((character) {

          final template = templates.firstWhere(
                (t) => t.id == character.templateId,
          );

          return ListTile(
            title: Text(character.name),
            subtitle: Text(template.name),

            onTap: () {

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CharacterEditorScreen(
                    character: character,
                    template: template,
                  ),
                ),
              );

            },
          );

        }).toList(),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () => _showTemplatePicker(),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showTemplatePicker() {

    showModalBottomSheet(
      context: context,
      builder: (context) {

        return ListView(
          children: templates.map((template) {

            return ListTile(
              title: Text(template.name),
              subtitle: Text(template.system),

              onTap: () {

                Navigator.pop(context);
                createCharacter(template);

              },
            );

          }).toList(),
        );
      },
    );
  }
}