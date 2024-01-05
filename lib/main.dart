import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a blue toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => TestProvider()),
        ],
        child: MyHomePage(title: 'Flutter Demo Home Page'),
      ),
    );
  }
}

enum TypeComponent {
  container,
  text,
  image,
  none,
}

class MyHomePage extends StatefulWidget {
  MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Widget _buildComponent(Map<String, dynamic> component) {
    switch (component['type']) {
      case TypeComponent.container:
        return Positioned(
          top: component['y'],
          left: component['x'],
          child: Container(
            key: component['key'],
            decoration: BoxDecoration(
              color: Color.fromRGBO(component['color'][0], component['color'][1], component['color'][2], component['color'][3]),
              border: Border.all(
                color: component['id'] == context.watch<TestProvider>().selectedId ? Colors.blue : Colors.transparent,
/*
                component['isSelect'] ? Colors.blue : Colors.transparent,
*/
                width: 2,
              ),
            ),
            width: component['width'],
            height: component['height'],
          ),
        );
      case TypeComponent.text:
        return Positioned(
          top: component['y'],
          left: component['x'],
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: component['id'] == context.watch<TestProvider>().selectedId ? Colors.blue : Colors.transparent,
              ),
            ),
            key: component['key'],
            child: Text(
              component['text'],
              style: TextStyle(
                color: Color.fromRGBO(component['color'][0], component['color'][1], component['color'][2], component['color'][3]),
                fontSize: component['fontSize'],
              ),
            ),
          ),
        );
      default:
        return Container();
    }
  }

  final GlobalObjectKey _key = GlobalObjectKey('key');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            for (var type in TypeComponent.values)
              ListTile(
                selected: context.watch<TestProvider>().selectedType == type,
                title: Text(type.toString()),
                onTap: () {
                  context.read<TestProvider>().selectedType = type;
                },
              ),
          ],
        ),
      ),
      body: GestureDetector(
        key: _key,
        onTapDown: (details) {
          print('onTapDown');
          RenderBox box = _key.currentContext?.findRenderObject() as RenderBox;
          Offset local = box.globalToLocal(details.globalPosition);
          print(local);
          print(context.read<TestProvider>().test1['children']);
          int count = 1;
          int idOfClosestComponent = -1;
          // check if there is a component in this position
          for (var component in context.read<TestProvider>().test1['children']) {
            print(component);
            print(component['x']);
            print(component['y']);
            print(component['width']);
            print(component['height']);
            print(local.dx);
            print(local.dy);

            print('-' + count.toString());
            int id = component['id'];
            RenderBox box = context.read<TestProvider>().getRenderBoxWithGlobalKey(id);
            Offset localObj = box.globalToLocal(details.globalPosition);
            print(localObj);
            Size size = box.size;
            print(size);

            if (idOfClosestComponent == -1) {
              // check if the position is inside the component
              if (component['x'] <= local.dx && component['y'] <= local.dy) {
                if (component['type'] == TypeComponent.container) {
                  if (component['x'] + component['width'] >= local.dx && component['y'] + component['height'] >= local.dy) {
                    print('select component');
                    print(component['id']);
                    idOfClosestComponent = component['id'];
                  } else {
                    print('unselect component');
                    print(component['id']);
                  }
                } else if (component['type'] == TypeComponent.text) {
                  double textWidth = component['text'].length * component['fontSize'];
                  double textHeight = component['fontSize'];

                  if (component['x'] + textWidth >= local.dx && component['y'] + textHeight >= local.dy) {
                    print('select component');
                    print(component['id']);
                    idOfClosestComponent = component['id'];
                  } else {
                    print('unselect component');
                    print(component['id']);
                  }
                }
              } else {
                print('unselect component');
                print(component['id']);
              }
            } else {
              // check if this componeent is closer to the position than the previous one
              RenderBox box = context.read<TestProvider>().getRenderBoxWithGlobalKey(idOfClosestComponent);
              Offset localObj = box.globalToLocal(details.globalPosition);
              Size size = box.size;
              double distance = (localObj.dx - size.width / 2) * (localObj.dx - size.width / 2) + (localObj.dy - size.height / 2) * (localObj.dy - size.height / 2);
              print(distance);
              RenderBox box2 = context.read<TestProvider>().getRenderBoxWithGlobalKey(id);
              Offset localObj2 = box2.globalToLocal(details.globalPosition);
              Size size2 = box2.size;
              double distance2 = (localObj2.dx - size2.width / 2) * (localObj2.dx - size2.width / 2) + (localObj2.dy - size2.height / 2) * (localObj2.dy - size2.height / 2);
              print(distance2);
              if (distance2 < distance) {
                idOfClosestComponent = id;
              }
            }

            print('-');
            print('-');
            print(idOfClosestComponent);
            context.read<TestProvider>().selectedId = idOfClosestComponent;

            count++;

            // get position of the component with the global key
            /* RenderBox componentBox = component['key'].currentContext?.findRenderObject() as RenderBox;
            Offset componentLocal = componentBox.globalToLocal(details.globalPosition);
            print('-');

            print(componentLocal);*/

            /*if (component['x'] <= local.dx && component['y'] <= local.dy) {
              if (component['type'] == TypeComponent.container) {
                if (component['x'] + component['width'] >= local.dx && component['y'] + component['height'] >= local.dy) {
                  print('select component');
                  print(component['id']);
                  context.read<TestProvider>().selectedId = component['id'];
                } else {
                  print('unselect component');
                  print(component['id']);
                  context.read<TestProvider>().selectedId = -1;
                }
              } else if (component['type'] == TypeComponent.text) {
                double textWidth = component['text'].length * component['fontSize'];
                double textHeight = component['fontSize'];

                if (component['x'] + textWidth >= local.dx && component['y'] + textHeight >= local.dy) {
                  print('select component');
                  print(component['id']);
                  context.read<TestProvider>().selectedId = component['id'];
                } else {
                  print('unselect component');
                  print(component['id']);
                  context.read<TestProvider>().selectedId = -1;
                }
              }
            } else {
              print('unselect component');
              print(component['id']);
              context.read<TestProvider>().selectedId = -1;
            }*/

            /*if (component['x'] <= local.dx && component['x'] + component['width'] >= local.dx && component['y'] <= local.dy && component['y'] + component['height'] >= local.dy) {
              */ /* print('select component');
              print(component['id']);
              context.read<TestProvider>().selectedId = component['id'];*/ /*
            } else {
              print('unselect component');
              print(component['id']);
              context.read<TestProvider>().selectedId = -1;
            }*/
          }
        },
        onHorizontalDragUpdate: (details) {
          print('onHorizontalDragUpdate');
          RenderBox box = _key.currentContext!.findRenderObject() as RenderBox;
          Offset local = box.globalToLocal(details.globalPosition);
          print(local);
          // get the selected component

          context.read<TestProvider>().updatePositionX(details.globalPosition);
        },
        onVerticalDragUpdate: (details) {
          print('onVerticalDragUpdate');
          RenderBox box = _key.currentContext!.findRenderObject() as RenderBox;
          Offset local = box.globalToLocal(details.globalPosition);
          print(local);
          // get the selected component

          context.read<TestProvider>().updatePositionY(details.globalPosition);
        },
        child: Container(
          color: Colors.green,
          child: Stack(
            children: [
              for (var component in context.watch<TestProvider>().test1['children']) _buildComponent(component),
            ],
          ),
        ),
      ),
    );
  }
}

class TestProvider with ChangeNotifier {
  TypeComponent _selectedType = TypeComponent.none;
  TypeComponent get selectedType => _selectedType;
  set selectedType(TypeComponent value) {
    _selectedType = value;
    notifyListeners();
  }

  int _selectedId = -1;
  int get selectedId => _selectedId;
  set selectedId(int value) {
    _selectedId = value;
    notifyListeners();
  }

  Map<String, dynamic> _test1 = {
    "width": 1920,
    "height": 1080,
    "children": [
      {
        "id": 1,
        "key": GlobalObjectKey('key1'),
        "type": TypeComponent.container,
        "y": 20,
        "x": 20,
        "width": 200,
        "height": 100,
        "color": [255, 0, 0, 1],
        "isSelect": false,
      },
      {
        "id": 2,
        "key": GlobalObjectKey('key2'),
        "x": 30,
        "y": 30,
        "type": TypeComponent.text,
        "text": "Hello World",
        "color": [255, 255, 255, 1],
        "fontSize": 20,
        "isSelect": false,
      },
    ],
  };

  Map<String, dynamic> get test1 => _test1;

  set test1(Map<String, dynamic> value) {
    _test1 = value;
    notifyListeners();
  }

  void addComponent(TypeComponent type) {
    _test1['children'].add({
      'type': type,
      'x': 0,
      'y': 0,
      'width': 100,
      'height': 100,
      'color': [255, 255, 255, 1],
      'text': 'Hello World',
      'fontSize': 20,
    });
    notifyListeners();
  }

  void updateComponent(int id, Map<String, dynamic> component) {
    for (var i = 0; i < _test1['children'].length; i++) {
      if (_test1['children'][i]['id'] == id) {
        _test1['children'][i] = component;
        break;
      }
    }
    notifyListeners();
  }

  RenderBox getRenderBoxWithGlobalKey(int id) {
    List<Map<String, dynamic>> childs = _test1['children'];
    Map<String, dynamic> child = childs.firstWhere((element) => element['id'] == id);
    RenderBox box = child['key'].currentContext?.findRenderObject() as RenderBox;
    return box;
  }

  void updatePositionX(Offset offset) {
    print('updatePosition');
    print(offset);
    print(selectedId);
    RenderBox box = getRenderBoxWithGlobalKey(selectedId);
    Offset local = box.globalToLocal(offset);
    print(local);
    Map<String, dynamic> component = _test1['children'].firstWhere((element) => element['id'] == selectedId);
    component['x'] = local.dx;
    updateComponent(selectedId, component);
    notifyListeners();
  }

  void updatePositionY(Offset offset) {
    print('updatePosition');
    print(offset);
    print(selectedId);
    RenderBox box = getRenderBoxWithGlobalKey(selectedId);
    Offset local = box.globalToLocal(offset);
    print(local);
    Map<String, dynamic> component = _test1['children'].firstWhere((element) => element['id'] == selectedId);
    component['y'] = local.dy;
    updateComponent(selectedId, component);
    notifyListeners();
  }
}
