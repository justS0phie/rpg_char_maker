import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/v4.dart';

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

  Future<List<Character>> loadSavedCharacters() async {
    final dir = await getApplicationDocumentsDirectory();
    final files = dir.listSync();

    List<Character> characters = [];

    for (var file in files) {
      if (file is File && file.path.endsWith(".json")) {
        try {
          final jsonString = await file.readAsString();
          final jsonData = jsonDecode(jsonString);
          final character = Character.fromJson(jsonData);

          characters.add(character);
        } catch (e) {
          print("Failed to load character file: ${file.path}");
        }
      }
    }

    return characters;
  }

  Future<void> loadTemplates() async {
    templates = await templateService.fetchTemplates();

    setState(() {
      loading = false;
    });
  }

  void createCharacter(Template template) {
    final character = Character(
      id: UuidV4().generate(),
      name: "New Character",
      templateId: template.id,
    );

    characters.add(character);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            CharacterEditorScreen(character: character, template: template),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Characters")),

      body: ListView(
        children: characters.map((character) {
          final template = templates.firstWhere(
            (t) => t.id == character.templateId,
          );

          return ListTile(
            title: Text(character.name),
            subtitle: Text(template.name),

            onTap: () async {
              final fullTemplate = await TemplateService().loadTemplate(
                template.id,
              );

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CharacterEditorScreen(
                    character: character,
                    template: fullTemplate,
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

              onTap: () async {
                final fullTemplate = await TemplateService().loadTemplate(
                  template.id,
                );
                Navigator.pop(context);
                createCharacter(fullTemplate);
              },
            );
          }).toList(),
        );
      },
    );
  }
}
