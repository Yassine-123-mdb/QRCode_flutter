import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

void main() {
  runApp(MaterialApp(home: QRCodeApp()));
}

class QRCodeApp extends StatefulWidget {
  @override
  _QRCodeAppState createState() => _QRCodeAppState();
}

class _QRCodeAppState extends State<QRCodeApp> {
  List<Map<String, String>> fields = [];
  String qrData = '';
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Générateur de Code QR'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () {
                setState(() {
                  fields.add({'label': '', 'value': ''});
                });
              },
              child: Text('Ajouter un champ'),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: fields.length,
                itemBuilder: (context, index) {
                  return Row(
                    children: [
                      Expanded(
                        child: TextField(
                          onChanged: (value) {
                            setState(() {
                              fields[index]['label'] = value;
                            });
                          },
                          decoration: InputDecoration(labelText: 'Label'),
                        ),
                      ),
                      Expanded(
                        child: TextField(
                          onChanged: (value) {
                            setState(() {
                              fields[index]['value'] = value;
                            });
                          },
                          decoration: InputDecoration(labelText: 'Valeur'),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  qrData = fields.map((e) => '${e['label']}: ${e['value']}').join('\n');
                });
              },
              child: Text('Générer le QR code'),
            ),
            if (qrData.isNotEmpty)
              QrImageView(
                data: qrData,
                version: QrVersions.auto,
                size: 200,
              ),
            Spacer(),
            ElevatedButton(
              onPressed: () async {
                final scannedData = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => QRScannerScreen()),
                );
                if (scannedData != null) {
                  _decodeQRData(scannedData);
                }
              },
              child: Text('Scanner le QR code'),
            ),
          ],
        ),
      ),
    );
  }

  // Fonction pour décoder les données du QR code
  void _decodeQRData(String scannedData) {
    List<String> lines = scannedData.split('\n');
    setState(() {
      fields = lines.map((line) {
        List<String> parts = line.split(': ');
        return {'label': parts[0], 'value': parts[1]};
      }).toList();
    });
  }
}

class QRScannerScreen extends StatefulWidget {
  @override
  _QRScannerScreenState createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  QRViewController? controller;

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Scan QR Code')),
      body: Column(
        children: <Widget>[
          Expanded(
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
              overlay: QrScannerOverlayShape(
                borderColor: Colors.red,
                borderRadius: 10,
                borderLength: 30,
                borderWidth: 10,
                cutOutSize: 300,
              ),
            ),
          ),
          if (result != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('Code Scanné: ${result!.code}'),
            ),
          ElevatedButton(
            onPressed: () {
              if (result != null) {
                Navigator.pop(context, result!.code);
              }
            },
            child: Text('Retourner les données scannées'),
          ),
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData;
      });
    });
  }
}
