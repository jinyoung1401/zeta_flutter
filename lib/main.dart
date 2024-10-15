import 'dart:async';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late IO.Socket socket;
  Timer? _pingTimer;

  @override
  void initState() {
    super.initState();
    _initializeSocketConnection();
  }

  void _initializeSocketConnection() {
    // Socket.io 서버와 연결 설정
    socket = IO.io('http://192.168.1.121:8765', IO.OptionBuilder()
        .setTransports(['websocket']) // websocket 전송만 허용
        .enableAutoConnect() // 자동 연결 활성화
        .build());

    // 연결 시 이벤트 처리
    socket.onConnect((_) {
      print('Connected to Socket.IO server');
      _startPing(); // Ping 시작
    });

    // 서버에서 받은 메시지를 처리
    socket.on('message', (data) {
      print('Received message: $data');
    });

    // 연결 해제 시 처리
    socket.onDisconnect((_) => print('Disconnected from server'));

    // 에러 처리
    socket.onError((error) => print('Error: $error'));
  }

  void _startPing() {
    _pingTimer = Timer.periodic(Duration(seconds: 30), (timer) {
      socket.emit('message', 'ping'); // 30초마다 ping 메시지 전송
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Robot Navigation Control'),
        ),
        body: Column(
          children: [
            ElevatedButton(
              onPressed: () {
                socket.emit('message', 'run_route_1'); // Ready 라우트 전송
              },
              child: Text('Ready'),
            ),
            ElevatedButton(
              onPressed: () {
                socket.emit('message', 'run_route_2'); // go A 라우트 전송
              },
              child: Text('go A'),
            ),
            ElevatedButton(
              onPressed: () {
                socket.emit('message', 'run_route_3'); // go B 라우트 전송
              },
              child: Text('go B'),
            ),
            ElevatedButton(
              onPressed: () {
                socket.emit('message', 'run_route_4'); // go C 라우트 전송
              },
              child: Text('go C'),
            ),
            ElevatedButton(
              onPressed: () {
                socket.emit('message', 'run_route_5'); // Return A 라우트 전송
              },
              child: Text('Return A'),
            ),
            ElevatedButton(
              onPressed: () {
                socket.emit('message', 'run_route_6'); // Return B 라우트 전송
              },
              child: Text('Return B'),
            ),
            ElevatedButton(
              onPressed: () {
                socket.emit('message', 'run_route_7'); // Return C 라우트 전송
              },
              child: Text('Return C'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pingTimer?.cancel();
    socket.disconnect(); // 소켓 연결 해제
    socket.dispose(); // 소켓 자원 해제
    super.dispose();
  }
}
