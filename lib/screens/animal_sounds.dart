import 'package:flutter/material.dart';
import 'animal_sound_categories/birds.dart';
import 'animal_sound_categories/pet_animals.dart';
import 'animal_sound_categories/water_animals.dart';

class AnimalSoundsPage extends StatelessWidget {
  const AnimalSoundsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> categories = [
      {'name': 'Birds', 'page': const BirdsPage(), 'icon': Icons.flutter_dash},
      {'name': 'Pet Animals', 'page': const PetAnimalsPage(), 'icon': Icons.pets},
      {'name': 'Water Animals', 'page': const WaterAnimalsPage(), 'icon': Icons.water},
    ];

    return Scaffold(
      body: ListView.builder(
        itemCount: categories.length,
        padding: const EdgeInsets.all(16.0),
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              leading: Icon(categories[index]['icon'], size: 30),
              title: Text(categories[index]['name'], style: const TextStyle(fontSize: 18)),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => categories[index]['page']),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
