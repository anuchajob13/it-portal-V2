import 'package:flutter/material.dart';
import 'package:dart_ping/dart_ping.dart';

void main() {
  runApp(const NothingItPortalApp());
}

class NothingItPortalApp extends StatelessWidget {
  const NothingItPortalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IT Portal',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        cardColor: const Color(0xFF121212),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFD71921),
          surface: Color(0xFF121212),
        ),
      ),
      home: const DashboardScreen(),
    );
  }
}

class DeviceItem {
  String id;
  String name;
  String ip;
  String category;
  String status;
  int? latency;

  DeviceItem({
    required this.id,
    required this.name,
    required this.ip,
    required this.category,
    this.status = 'IDLE',
    this.latency,
  });
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<DeviceItem> devices = [
    DeviceItem(id: '1', name: 'Core Switch L3', ip: '192.168.1.1', category: 'SWITCH'),
    DeviceItem(id: '2', name: 'FortiGate FW', ip: '10.1.90.1', category: 'SWITCH'),
    DeviceItem(id: '3', name: 'Target VM', ip: '10.1.90.16', category: 'SERVER'),
    DeviceItem(id: '4', name: 'Backup Server', ip: '10.1.90.50', category: 'SERVER'),
  ];

  Future<void> pingDevice(DeviceItem device) async {
    setState(() {
      device.status = 'PINGING';
    });

    try {
      final ping = Ping(device.ip, count: 1, timeout: 2);
      final response = await ping.stream.first;

      if (response.response != null && response.response!.time != null) {
        setState(() {
          device.status = 'ONLINE';
          device.latency = response.response!.time!.inMilliseconds;
        });
      } else {
        setState(() {
          device.status = 'OFFLINE';
          device.latency = null;
        });
      }
    } catch (e) {
      setState(() {
        device.status = 'OFFLINE';
        device.latency = null;
      });
    }
  }

  void pingAll() {
    for (var device in devices) {
      pingDevice(device);
    }
  }

  void showAddDeviceDialog() {
    final nameController = TextEditingController();
    final ipController = TextEditingController();
    final categoryController = TextEditingController(text: 'SWITCH');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A),
          title: const Text('ADD NEW TARGET', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Device Name (เช่น Core SW)'),
              ),
              TextField(
                controller: ipController,
                decoration: const InputDecoration(labelText: 'IP Address (เช่น 192.168.1.1)'),
              ),
              TextField(
                controller: categoryController,
                decoration: const InputDecoration(labelText: 'Group / Category (เช่น SWITCH, SERVER)'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCEL', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD71921)),
              onPressed: () {
                if (nameController.text.isNotEmpty && ipController.text.isNotEmpty) {
                  setState(() {
                    devices.add(DeviceItem(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      name: nameController.text,
                      ip: ipController.text,
                      category: categoryController.text.toUpperCase(),
                    ));
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('ADD', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void deleteDevice(String id) {
    setState(() {
      devices.removeWhere((item) => item.id == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    // จัดกลุ่มตาม Category
    Map<String, List<DeviceItem>> groupedDevices = {};
    for (var dev in devices) {
      if (!groupedDevices.containsKey(dev.category)) {
        groupedDevices[dev.category] = [];
      }
      groupedDevices[dev.category]!.add(dev);
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('IT PORTAL', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2)),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFD71921),
        onPressed: showAddDeviceDialog,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E1E1E),
                minimumSize: const Size.fromHeight(48),
                side: const BorderSide(color: Color(0xFF333333)),
              ),
              onPressed: pingAll,
              icon: const Icon(Icons.radar, color: Colors.white),
              label: const Text('📡 PING ALL TARGETS (ICMP)', style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: groupedDevices.entries.map((entry) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                        child: Text(
                          'FOLDER: ${entry.key}',
                          style: const TextStyle(
                            color: Color(0xFFD71921),
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                      ...entry.value.map((dev) => Card(
                            margin: const EdgeInsets.only(bottom: 10),
                            shape: RoundedRectangleBorder(
                              side: const BorderSide(color: Color(0xFF2A2A2A)),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: ListTile(
                              title: Text(dev.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text(dev.ip, style: const TextStyle(color: Colors.grey, fontFamily: 'monospace')),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _buildStatusBadge(dev),
                                  IconButton(
                                    icon: const Icon(Icons.flash_on, size: 18),
                                    onPressed: () => pingDevice(dev),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, size: 18, color: Colors.grey),
                                    onPressed: () => deleteDevice(dev.id),
                                  ),
                                ],
                              ),
                            ),
                          )),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(DeviceItem dev) {
    if (dev.status == 'PINGING') {
      return const Text('...', style: TextStyle(color: Colors.orange));
    } else if (dev.status == 'ONLINE') {
      return Text('🟢 ${dev.latency}ms', style: const TextStyle(color: Color(0xFF00FF66), fontWeight: FontWeight.bold));
    } else if (dev.status == 'OFFLINE') {
      return const Text('🔴 TIMEOUT', style: TextStyle(color: Color(0xFFD71921), fontWeight: FontWeight.bold));
    }
    return const Text('IDLE', style: TextStyle(color: Colors.grey));
  }
}
