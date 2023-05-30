import 'package:flutter/material.dart';
import 'package:realm/realm.dart';

part 'main.g.dart';

@RealmModel()
class _Person {
  @PrimaryKey()
  late ObjectId id;

  late String name;
  late int age;
}

late Realm database;

void main() {
  final config = Configuration.local([Person.schema]);
  database = Realm(config);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const MyHomePage(),
        '/details': (context) => const DetailsPage(),
      },
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('MongoDB')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () => _create(context),
              child: const Text('Create'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => _read(context),
              child: const Text('Read'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => _update(context),
              child: const Text('Update'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => _delete(context),
              child: const Text('Delete'),
            ),
          ],
        ),
      ),
    );
  }

  void _create(BuildContext context) {
    database.write(() {
      final person = Person(ObjectId(), 'Bob', 23);
      database.add(person);
    });
    debugPrint('Inserted Bob');
  }

  void _read(BuildContext context) {
    Navigator.pushNamed(context, '/details');
  }

  void _update(BuildContext context) {
    final people = database.all<Person>();
    final person = people.last;
    database.write(() {
      database.add(Person(person.id, 'Mary', 32), update: true);
    });
    debugPrint('Updated to Mary');
  }

  void _delete(BuildContext context) {
    final people = database.all<Person>();
    final person = people.last;
    database.write(() {
      database.delete(person);
    });
    debugPrint('Deleted person');
  }
}

class DetailsPage extends StatelessWidget {
  const DetailsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final people = database.all<Person>();
    return Scaffold(
      appBar: AppBar(title: const Text('Details')),
      body: ListView.builder(
        itemCount: people.length,
        itemBuilder: (context, index) {
          final person = people[index];
          return ListTile(
            title: Text(person.name),
            subtitle: Text('Age: ${person.age}'),
          );
        },
      ),
    );
  }
}
