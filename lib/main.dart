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
  String _robotStatusMessage = '로봇 상태 대기 중...'; // 초기 상태 메시지
  double _progress = 0.0; // 진행률 초기화
  int _currentWaypoint = 0; // 현재 도착한 좌표
  int _totalWaypoints = 0; // 총 좌표 수
  String _finalDestination = ''; // 최종 목적지

  @override
  void initState() {
    super.initState();
    _initializeSocketConnection();
  }

  void _initializeSocketConnection() {
    socket = IO.io('http://192.168.1.121:8765', IO.OptionBuilder()
        .setTransports(['websocket']) // websocket 전송만 허용
        .enableAutoConnect() // 자동 연결 활성화
        .build());

    socket.onConnect((_) {
      print('Connected to Socket.IO server');
      // _startPing(); // Ping 시작 (필요시 사용)
    });

    // 서버에서 받은 메시지를 처리
    socket.on('message', (data) {
      print('Received message: $data');
    });

    // 로봇 상태 메시지 수신
    socket.on('navigation_status', (data) {
      print('로봇 상태 메시지: $data');
      _handleNavigationStatus(data);
    });

    socket.onDisconnect((_) => print('Disconnected from server'));
    socket.onError((error) => print('Error: $error'));
  }

  void _updateProgress(int currentWaypoint, int totalWaypoints, String finalDestination) {
    setState(() {
      _progress = (totalWaypoints > 0) ? currentWaypoint / totalWaypoints : 0.0;
      _robotStatusMessage = '로봇 진행률 ${(_progress * 100).toStringAsFixed(1)}% - 목적지: $finalDestination';
    });
  }

  void _handleNavigationStatus(dynamic data) {
    // 데이터에서 좌표 및 최종 목적지 정보 추출
    if (data is Map) {
      int currentWaypoint = data['currentWaypoint'] ?? 0;
      int totalWaypoints = data['totalWaypoints'] ?? 0;
      String finalDestination = data['finalDestination'] ?? '';

      // 업데이트 프로그레스 호출
      _updateProgress(currentWaypoint, totalWaypoints, finalDestination);
    } else {
      print('Invalid data format received');
    }
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
            LinearProgressIndicator(value: _progress), // 진행률 표시
            SizedBox(height: 10),
            Text(_robotStatusMessage), // 로봇 상태 메시지 표시
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
