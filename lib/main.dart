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
  String name;
  String ip;
  String category;
  String status;
  int? latency;

  DeviceItem({
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
    DeviceItem(name: 'Core Switch L3', ip: '192.168.1.1', category: '01_SWITCH'),
    DeviceItem(name: 'FortiGate FW', ip: '10.1.90.1', category: '01_SWITCH'),
    DeviceItem(name: 'Target VM', ip: '10.1.90.16', category: '02_VM'),
    DeviceItem(name: 'Backup Server', ip: '10.1.90.50', category: '02_VM'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('IT PORTAL', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2)),
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
              child: ListView.builder(
                itemCount: devices.length,
                itemBuilder: (context, index) {
                  final dev = devices[index];
                  return Card(
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
                        ],
                      ),
                    ),
                  );
                },
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
