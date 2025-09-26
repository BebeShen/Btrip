import 'package:flutter/material.dart';

class SubwayScreen extends StatefulWidget {
  const SubwayScreen({super.key});

  @override
  State<SubwayScreen> createState() => _SubwayScreenState();
}

class _SubwayScreenState extends State<SubwayScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _selectedLine;
  String? _fromStation;
  String? _toStation;
  List<RouteInfo> _routes = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _searchRoute() {
    if (_fromStation != null && _toStation != null && _fromStation != _toStation) {
      setState(() {
        _routes = _findRoutes(_fromStation!, _toStation!);
      });
    }
  }

  void _swapStations() {
    setState(() {
      final temp = _fromStation;
      _fromStation = _toStation;
      _toStation = temp;
      if (_fromStation != null && _toStation != null) {
        _searchRoute();
      }
    });
  }

  List<String> _getStationsForLine(String? lineName) {
    if (lineName == null) return [];
    final line = _subwayLines.firstWhere(
      (line) => line.name == lineName,
      orElse: () => _subwayLines.first,
    );
    return line.stations;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('釜山地鐵'),
        backgroundColor: Colors.blue.shade50,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.search), text: '路線查詢'),
            Tab(icon: Icon(Icons.map), text: '路線圖'),
            Tab(icon: Icon(Icons.info), text: '乘車資訊'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRouteSearchTab(),
          _buildMapTab(),
          _buildInfoTab(),
        ],
      ),
    );
  }

  Widget _buildRouteSearchTab() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // 路線選擇
                  DropdownButtonFormField<String>(
                    value: _selectedLine,
                    decoration: const InputDecoration(
                      labelText: '選擇路線 (可選)',
                      prefixIcon: Icon(Icons.train, color: Colors.blue),
                      border: OutlineInputBorder(),
                      helperText: '選擇特定路線或留空查詢所有路線',
                    ),
                    items: [
                      const DropdownMenuItem<String>(
                        value: null,
                        child: Text('所有路線'),
                      ),
                      ..._subwayLines.map((line) {
                        return DropdownMenuItem(
                          value: line.name,
                          child: Row(
                            children: [
                              Container(
                                width: 16,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: line.color,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(line.name),
                            ],
                          ),
                        );
                      }),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedLine = value;
                        _fromStation = null;
                        _toStation = null;
                        _routes.clear();
                      });
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // 出發站選擇
                  DropdownButtonFormField<String>(
                    value: _fromStation,
                    decoration: const InputDecoration(
                      labelText: '出發站',
                      prefixIcon: Icon(Icons.radio_button_checked, color: Colors.blue),
                      border: OutlineInputBorder(),
                    ),
                    items: _selectedLine != null 
                        ? _getStationsForLine(_selectedLine).map((station) {
                            return DropdownMenuItem(
                              value: station,
                              child: Text('$station ($_selectedLine)'),
                            );
                          }).toList()
                        : _getUniqueStations().map((stationInfo) {
                            return DropdownMenuItem(
                              value: stationInfo.name,
                              child: Text('${stationInfo.name} (${stationInfo.linesDisplay})'),
                            );
                          }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _fromStation = value;
                      });
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // 交換按鈕
                  Row(
                    children: [
                      Expanded(child: Container()),
                      IconButton(
                        onPressed: _swapStations,
                        icon: const Icon(Icons.swap_vert, size: 32),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.grey.shade200,
                        ),
                      ),
                      Expanded(child: Container()),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // 到達站選擇
                  DropdownButtonFormField<String>(
                    value: _toStation,
                    decoration: const InputDecoration(
                      labelText: '到達站',
                      prefixIcon: Icon(Icons.location_on, color: Colors.red),
                      border: OutlineInputBorder(),
                    ),
                    items: _selectedLine != null 
                        ? _getStationsForLine(_selectedLine).map((station) {
                            return DropdownMenuItem(
                              value: station,
                              child: Text('$station ($_selectedLine)'),
                            );
                          }).toList()
                        : _getUniqueStations().map((stationInfo) {
                            return DropdownMenuItem(
                              value: stationInfo.name,
                              child: Text('${stationInfo.name} (${stationInfo.linesDisplay})'),
                            );
                          }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _toStation = value;
                      });
                    },
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // 搜尋按鈕
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: (_fromStation != null && _toStation != null) 
                          ? _searchRoute 
                          : null,
                      icon: const Icon(Icons.search),
                      label: const Text('搜尋路線'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        
        // 搜尋結果
        Expanded(
          child: _routes.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.directions_subway, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text('請選擇出發站和到達站\n開始搜尋路線'),
                      if (_selectedLine != null) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _getLineColor(_selectedLine!).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: _getLineColor(_selectedLine!)),
                          ),
                          child: Text(
                            '限定 $_selectedLine',
                            style: TextStyle(
                              color: _getLineColor(_selectedLine!),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _routes.length,
                  itemBuilder: (context, index) {
                    final route = _routes[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '路線 ${index + 1}',
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade100,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    index == 0 ? '推薦' : '替代',
                                    style: TextStyle(
                                      color: Colors.green.shade700,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            
                            // 即時班次資訊
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.schedule, size: 16, color: Colors.blue.shade700),
                                      const SizedBox(width: 4),
                                      Text(
                                        '下班車時間: ${_getNextTrainTime()}',
                                        style: TextStyle(
                                          color: Colors.blue.shade700,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(Icons.info_outline, size: 14, color: Colors.grey.shade600),
                                      const SizedBox(width: 4),
                                      Text(
                                        '班距: ${_getCurrentInterval()}',
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            
                            // 路線詳情
                            Row(
                              children: [
                                Icon(Icons.schedule, size: 16, color: Colors.grey.shade600),
                                const SizedBox(width: 4),
                                Text('${route.duration} 分鐘'),
                                const SizedBox(width: 16),
                                Icon(Icons.compare_arrows, size: 16, color: Colors.grey.shade600),
                                const SizedBox(width: 4),
                                Text('${route.transfers} 次轉乘'),
                                const SizedBox(width: 16),
                                Icon(Icons.attach_money, size: 16, color: Colors.grey.shade600),
                                const SizedBox(width: 4),
                                Text('₩${route.fare}'),
                              ],
                            ),
                            const SizedBox(height: 12),
                            
                            // 路線步驟
                            ...route.steps.map((step) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                children: [
                                  Container(
                                    width: 20,
                                    height: 20,
                                    decoration: BoxDecoration(
                                      color: _getLineColor(step.line),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        step.line == '부산김해경전철' ? 'BG' : step.line.split('號線')[0],
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(child: Text(step.description)),
                                ],
                              ),
                            )),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildMapTab() {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            '釜山地鐵路線圖',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 5.0,
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: Colors.white,
                  child: Image.asset(
                    'assets/images/busan_subway_map.png', // 您可以替換成您的圖片路徑
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.image_not_supported, size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(
                              '請將釜山地鐵路線圖放在\nassets/images/busan_subway_map.png',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
        
        // 簡化的使用說明
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '使用說明',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Row(
                children: [
                  Icon(Icons.touch_app, color: Colors.blue, size: 16),
                  SizedBox(width: 6),
                  Text('雙指縮放查看詳細資訊'),
                ],
              ),
              const SizedBox(height: 4),
              const Row(
                children: [
                  Icon(Icons.pan_tool, color: Colors.blue, size: 16),
                  SizedBox(width: 6),
                  Text('拖曳移動查看不同區域'),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCard(
            '票價資訊',
            Icons.payment,
            [
              '地鐵系統：',
              '• 成人 單程票：₩1,600 (1區段) / ₩1,800 (2區段)',
              '• 交通卡優惠：₩1,550 (1區段) / ₩1,750 (2區段)', 
              '• 一日券：₩5,000 (當日無限次搭乘)',
              '',
              '金海輕軌：',
              '• 機場到沙上：₩1,700-2,000',
              '• 可與地鐵享轉乘優惠 (10分鐘內)',
              '• 區段計算：10公里內為1區段，超過10公里為2區段',
            ],
          ),
          
          _buildInfoCard(
            '營運時間',
            Icons.schedule,
            [
              '首班車：約 05:30-06:00',
              '末班車：約 23:30-24:00',
              '尖峰時間 (07-09, 18-20)：2-4分鐘',
              '平日離峰：5-7分鐘',
              '假日：6-8分鐘',
              '※ 各站點時間略有不同，建議提前確認',
            ],
          ),
          
          _buildInfoCard(
            '主要轉乘站',
            Icons.transfer_within_a_station,
            [
              '西面站：1號線 ↔ 2號線',
              '蓮山站：1號線 ↔ 3號線',  
              '美南站：2號線 ↔ 3號線',
              '東萊站：1號線 ↔ 4號線',
              '沙上站：2號線 ↔ 3號線 ↔ 金海輕軌',
              '사상站：2號線 ↔ 金海輕軌',
              '안락站：3號線 ↔ 東海線',
            ],
          ),
          
          _buildInfoCard(
            '機場交通重點',
            Icons.flight,
            [
              '金海機場 → 市區路線：',
              '• 金海輕軌 공항站 → 사상站 (約30分鐘)',
              '• 사상站轉乘地鐵2號線到西面站',
              '• 轉乘時需重新刷卡，但可享轉乘優惠',
              '• 機場到西面總時間約45-60分鐘',
              '※ 金海輕軌與地鐵為不同系統',
            ],
          ),
          
          _buildInfoCard(
            '熱門景點站點',
            Icons.place,
            [
              '해운대해수욕장：2號線 해운대站',
              '광안리해수욕장：2號線 광안역',
              '감천문화마을：1號線 토성역',
              '자갈치시장：1號線 자갈치역',
              '부산역：1號線 부산역',
              '범어사：1號線 범어사역',
              '김해공항：金海輕軌 공항역',
              'CENTUM CITY：2號線 센텀시티역',
            ],
          ),
          
          _buildInfoCard(
            '乘車注意事項',
            Icons.info,
            [
              '地鐵內禁止飲食',
              '請讓座給老弱婦孺',
              '上下車時請先下後上',
              '車廂內請保持安靜',
              '遺失物品請至各站服務台詢問',
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, IconData icon, List<String> items) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• ', style: TextStyle(color: Colors.blue)),
                  Expanded(child: Text(item)),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  // 取得唯一站點（合併重複站名）
  List<UniqueStation> _getUniqueStations() {
    Map<String, List<String>> stationLines = {};
    
    for (var line in _subwayLines) {
      for (var station in line.stations) {
        if (stationLines[station] == null) {
          stationLines[station] = [];
        }
        stationLines[station]!.add(line.name);
      }
    }
    
    return stationLines.entries.map((entry) {
      return UniqueStation(
        name: entry.key,
        lines: entry.value,
        linesDisplay: entry.value.length > 3 
            ? '${entry.value.take(3).join(', ')}...' 
            : entry.value.join(', '),
      );
    }).toList()..sort((a, b) => a.name.compareTo(b.name));
  }

  // 取得下班車時間
  String _getNextTrainTime() {
    final now = DateTime.now();
    final currentHour = now.hour;
    final currentMinute = now.minute;
    
    // 根據當前時間計算班距
    int intervalMinutes;
    if ((currentHour >= 7 && currentHour < 9) || (currentHour >= 18 && currentHour < 20)) {
      intervalMinutes = 3; // 尖峰時間
    } else if (currentHour >= 5 && currentHour < 24) {
      intervalMinutes = 6; // 正常時間
    } else {
      return '運營已結束';
    }
    
    // 計算下班車時間
    final nextMinute = ((currentMinute ~/ intervalMinutes) + 1) * intervalMinutes;
    var nextHour = currentHour;
    var finalMinute = nextMinute;
    
    if (nextMinute >= 60) {
      nextHour += 1;
      finalMinute = nextMinute - 60;
    }
    
    if (nextHour >= 24) {
      return '運營已結束';
    }
    
    return '${nextHour.toString().padLeft(2, '0')}:${finalMinute.toString().padLeft(2, '0')}';
  }

  // 取得當前班距資訊
  String _getCurrentInterval() {
    final currentHour = DateTime.now().hour;
    if ((currentHour >= 7 && currentHour < 9) || (currentHour >= 18 && currentHour < 20)) {
      return '2-4分鐘 (尖峰)';
    } else if (currentHour >= 5 && currentHour < 24) {
      return '5-7分鐘 (平日)';
    } else {
      return '運營結束';
    }
  }

  Color _getLineColor(String line) {
    switch (line) {
      case '1號線':
        return const Color(0xFFFF7A00); // 橙色
      case '2號線':
        return const Color(0xFF00B04F); // 綠色
      case '3號線':
        return const Color(0xFF8B4513); // 棕色
      case '4號線':
        return const Color(0xFF0066CC); // 藍色
      case '동해선':
      case '東海線':
        return const Color(0xFF9966CC); // 紫色
      case '부산김해경전철':
      case 'BGL':
      case '金海輕軌':
        return const Color(0xFF663399); // 深紫色
      default:
        return Colors.grey;
    }
  }

  List<RouteInfo> _findRoutes(String from, String to) {
    if (_selectedLine != null) {
      // 限定路線查詢
      final line = _subwayLines.firstWhere((l) => l.name == _selectedLine);
      if (line.stations.contains(from) && line.stations.contains(to)) {
        return [
          RouteInfo(
            duration: 12,
            transfers: 0,
            fare: 1550,
            steps: [
              RouteStep(
                line: _selectedLine!,
                description: '$from → $to ($_selectedLine)',
              ),
            ],
          ),
        ];
      } else {
        return [];
      }
    } else {
      // 一般查詢邏輯
      final fromStationInfo = _getUniqueStations().firstWhere((s) => s.name == from);
      final toStationInfo = _getUniqueStations().firstWhere((s) => s.name == to);
      
      List<RouteInfo> routes = [];
      
      // 檢查是否有共同路線 (直達)
      final commonLines = fromStationInfo.lines.toSet().intersection(toStationInfo.lines.toSet());
      
      if (commonLines.isNotEmpty) {
        routes.add(RouteInfo(
          duration: 15,
          transfers: 0,
          fare: 1550,
          steps: [
            RouteStep(
              line: commonLines.first,
              description: '$from → $to (${commonLines.first})',
            ),
          ],
        ));
      }
      
      // 一次轉乘路線
      if (routes.isEmpty || routes.length < 2) {
        routes.add(RouteInfo(
          duration: 28,
          transfers: 1,
          fare: 1550,
          steps: [
            RouteStep(
              line: fromStationInfo.lines.first,
              description: '$from → 서면 (${fromStationInfo.lines.first})',
            ),
            RouteStep(
              line: toStationInfo.lines.first,
              description: '서면 → $to (${toStationInfo.lines.first})',
            ),
          ],
        ));
      }
      
      return routes;
    }
  }
}

// 詳細地鐵路線圖繪製器
class DetailedSubwayMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // 定義所有主要站點位置 (更接近真實路線圖)
    final stations = <String, Offset>{
      // 1號線主要站點
      '신평': Offset(size.width * 0.05, size.height * 0.85),
      '하단': Offset(size.width * 0.12, size.height * 0.82),
      '당리': Offset(size.width * 0.18, size.height * 0.78),
      '사하': Offset(size.width * 0.24, size.height * 0.74),
      '괴정': Offset(size.width * 0.30, size.height * 0.70),
      '대티': Offset(size.width * 0.36, size.height * 0.66),
      '서대신': Offset(size.width * 0.40, size.height * 0.62),
      '동대신': Offset(size.width * 0.44, size.height * 0.58),
      '토성': Offset(size.width * 0.48, size.height * 0.54),
      '자갈치': Offset(size.width * 0.52, size.height * 0.50),
      '남포': Offset(size.width * 0.56, size.height * 0.46),
      '중앙': Offset(size.width * 0.60, size.height * 0.42),
      '부산역': Offset(size.width * 0.64, size.height * 0.38),
      '초량': Offset(size.width * 0.68, size.height * 0.34),
      '부산진': Offset(size.width * 0.70, size.height * 0.30),
      '서면': Offset(size.width * 0.50, size.height * 0.30), // 중앙 전환점
      '부전': Offset(size.width * 0.54, size.height * 0.26),
      '양정': Offset(size.width * 0.58, size.height * 0.22),
      '시청': Offset(size.width * 0.62, size.height * 0.18),
      '연산': Offset(size.width * 0.66, size.height * 0.14),
      '교대': Offset(size.width * 0.70, size.height * 0.10),
      '동래': Offset(size.width * 0.74, size.height * 0.06),
      '명륜': Offset(size.width * 0.78, size.height * 0.08),
      '온천장': Offset(size.width * 0.82, size.height * 0.10),
      '부산대': Offset(size.width * 0.86, size.height * 0.12),
      '장전': Offset(size.width * 0.90, size.height * 0.14),
      '구서': Offset(size.width * 0.94, size.height * 0.16),
      '범어사': Offset(size.width * 0.98, size.height * 0.18),

      // 2號線主要站點
      '장산': Offset(size.width * 0.85, size.height * 0.25),
      '해운대': Offset(size.width * 0.82, size.height * 0.30),
      '중동': Offset(size.width * 0.78, size.height * 0.35),
      '벡스코': Offset(size.width * 0.74, size.height * 0.40),
      '센텀시티': Offset(size.width * 0.70, size.height * 0.45),
      '민락': Offset(size.width * 0.66, size.height * 0.50),
      '수영': Offset(size.width * 0.62, size.height * 0.55),
      '광안': Offset(size.width * 0.58, size.height * 0.60),
      '금련산': Offset(size.width * 0.54, size.height * 0.65),
      '남천': Offset(size.width * 0.50, size.height * 0.70),
      '경성대·부경대': Offset(size.width * 0.46, size.height * 0.65),
      '대연': Offset(size.width * 0.42, size.height * 0.60),
      '못골': Offset(size.width * 0.38, size.height * 0.55),
      '지게골': Offset(size.width * 0.34, size.height * 0.50),
      '문현': Offset(size.width * 0.30, size.height * 0.45),
      '국제금융센터·부산은행': Offset(size.width * 0.26, size.height * 0.40),
      '전포': Offset(size.width * 0.22, size.height * 0.35),
      '서면2호선': Offset(size.width * 0.50, size.height * 0.30), // 서면 2호선
      '부암': Offset(size.width * 0.44, size.height * 0.25),
      '가야': Offset(size.width * 0.40, size.height * 0.20),
      '동의대': Offset(size.width * 0.36, size.height * 0.15),
      '개금': Offset(size.width * 0.32, size.height * 0.10),
      '냉정': Offset(size.width * 0.28, size.height * 0.05),
      '주례': Offset(size.width * 0.24, size.height * 0.08),
      '감전': Offset(size.width * 0.20, size.height * 0.12),
      '사상': Offset(size.width * 0.16, size.height * 0.16),
      '덕포': Offset(size.width * 0.12, size.height * 0.20),
      '모덕': Offset(size.width * 0.08, size.height * 0.24),
      '모라': Offset(size.width * 0.04, size.height * 0.28),
      '구남': Offset(size.width * 0.02, size.height * 0.32),
      '구명': Offset(size.width * 0.04, size.height * 0.36),
      '덕천': Offset(size.width * 0.08, size.height * 0.40),
      '수정': Offset(size.width * 0.12, size.height * 0.44),
      '화명': Offset(size.width * 0.16, size.height * 0.48),
      '율리': Offset(size.width * 0.20, size.height * 0.52),
      '동원': Offset(size.width * 0.24, size.height * 0.56),
      '금곡': Offset(size.width * 0.28, size.height * 0.60),
      '호포': Offset(size.width * 0.32, size.height * 0.64),
      '증산': Offset(size.width * 0.36, size.height * 0.68),
      '부산대양산캠퍼스': Offset(size.width * 0.40, size.height * 0.72),
      '남양산': Offset(size.width * 0.44, size.height * 0.76),
      '양산': Offset(size.width * 0.48, size.height * 0.80),

      // 3號線主요站點
      '대저': Offset(size.width * 0.10, size.height * 0.75),
      '체육공원': Offset(size.width * 0.15, size.height * 0.70),
      '강서구청': Offset(size.width * 0.20, size.height * 0.65),
      '구포': Offset(size.width * 0.25, size.height * 0.60),
      '덕천3호선': Offset(size.width * 0.30, size.height * 0.55),
      '숙등': Offset(size.width * 0.35, size.height * 0.50),
      '덕산': Offset(size.width * 0.40, size.height * 0.45),
      '물만골': Offset(size.width * 0.45, size.height * 0.40),
      '연산3호선': Offset(size.width * 0.66, size.height * 0.35),
      '거제': Offset(size.width * 0.70, size.height * 0.40),
      '종합운동장': Offset(size.width * 0.75, size.height * 0.45),
      '사직': Offset(size.width * 0.80, size.height * 0.50),
      '미남': Offset(size.width * 0.85, size.height * 0.55),

      // 4號線主요站點
      '미남4호선': Offset(size.width * 0.85, size.height * 0.55),
      '동래4호선': Offset(size.width * 0.74, size.height * 0.50),
      '수안': Offset(size.width * 0.78, size.height * 0.55),
      '낙민': Offset(size.width * 0.82, size.height * 0.60),
      '충렬사': Offset(size.width * 0.86, size.height * 0.65),
      '명장': Offset(size.width * 0.90, size.height * 0.70),
      '서동': Offset(size.width * 0.94, size.height * 0.75),
      '금사': Offset(size.width * 0.90, size.height * 0.80),
      '반여농산물시장': Offset(size.width * 0.85, size.height * 0.85),
      '석대': Offset(size.width * 0.80, size.height * 0.90),
      '영산대': Offset(size.width * 0.75, size.height * 0.95),

      // 금해경전철 주요站點
      '공항': Offset(size.width * 0.02, size.height * 0.05),
      '대저경전철': Offset(size.width * 0.06, size.height * 0.10),
      '평강': Offset(size.width * 0.10, size.height * 0.15),
      '대곡': Offset(size.width * 0.14, size.height * 0.18),
      '사상경전철': Offset(size.width * 0.16, size.height * 0.16), // 사상 연결점
    };

    // 1號線 그리기 (오렌지)
    paint.color = const Color(0xFFFF7A00);
    _drawMetroLine(canvas, paint, [
      stations['신평']!, stations['하단']!, stations['당리']!, 
      stations['사하']!, stations['괴정']!, stations['대티']!, 
      stations['서대신']!, stations['동대신']!, stations['토성']!,
      stations['자갈치']!, stations['남포']!, stations['중앙']!,
      stations['부산역']!, stations['초량']!, stations['부산진']!,
      stations['서면']!, stations['부전']!, stations['양정']!,
      stations['시청']!, stations['연산']!, stations['교대']!,
      stations['동래']!, stations['명륜']!, stations['온천장']!,
      stations['부산대']!, stations['장전']!, stations['구서']!, stations['범어사']!
    ]);

    // 2號線 그리기 (그린)
    paint.color = const Color(0xFF00B04F);
    _drawMetroLine(canvas, paint, [
      stations['장산']!, stations['해운대']!, stations['중동']!,
      stations['벡스코']!, stations['센텀시티']!, stations['민락']!,
      stations['수영']!, stations['광안']!, stations['금련산']!,
      stations['남천']!, stations['경성대·부경대']!, stations['대연']!,
      stations['못골']!, stations['지게골']!, stations['문현']!,
      stations['국제금융센터·부산은행']!, stations['전포']!, stations['서면2호선']!,
      stations['부암']!, stations['가야']!, stations['동의대']!,
      stations['개금']!, stations['냉정']!, stations['주례']!,
      stations['감전']!, stations['사상']!,
    ]);

    // 2號선 연장선 (양산 방향)
    _drawMetroLine(canvas, paint, [
      stations['사상']!, stations['덕포']!, stations['모덕']!,
      stations['모라']!, stations['구남']!, stations['구명']!,
      stations['덕천']!, stations['수정']!, stations['화명']!,
      stations['율리']!, stations['동원']!, stations['금곡']!,
      stations['호포']!, stations['증산']!, stations['부산대양산캠퍼스']!,
      stations['남양산']!, stations['양산']!
    ]);

    // 3號線 그리기 (브라운)
    paint.color = const Color(0xFF8B4513);
    _drawMetroLine(canvas, paint, [
      stations['대저']!, stations['체육공원']!, stations['강서구청']!,
      stations['구포']!, stations['덕천3호선']!, stations['숙등']!,
      stations['덕산']!, stations['물만골']!, stations['연산3호선']!,
      stations['거제']!, stations['종합운동장']!, stations['사직']!, stations['미남']!
    ]);

    // 4號線 그리기 (블루)
    paint.color = const Color(0xFF0066CC);
    _drawMetroLine(canvas, paint, [
      stations['미남4호선']!, stations['동래4호선']!, stations['수안']!,
      stations['낙민']!, stations['충렬사']!, stations['명장']!,
      stations['서동']!, stations['금사']!, stations['반여농산물시장']!,
      stations['석대']!, stations['영산대']!
    ]);

    // 금해경전철 그리기 (퍼플)
    paint.color = const Color(0xFF663399);
    _drawMetroLine(canvas, paint, [
      stations['공항']!, stations['대저경전철']!, stations['평강']!,
      stations['대곡']!, stations['사상경전철']!
    ]);

    // 역 표시
    final stationPaint = Paint()..style = PaintingStyle.fill;
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    
    // 주요 역만 표시
    final majorStations = [
      '부산역', '서면', '해운대', '사상', '동래', '범어사', 
      '센텀시티', '광안', '자갈치', '공항', '미남'
    ];

    stations.forEach((name, position) {
      if (majorStations.any((major) => name.contains(major.split('·')[0]))) {
        // 역 원 그리기
        stationPaint.color = Colors.white;
        canvas.drawCircle(position, 8, stationPaint);
        
        // 전환역 표시 (빨간 원)
        if (_isTransferStation(name)) {
          stationPaint.color = Colors.red;
          canvas.drawCircle(position, 10, stationPaint);
          stationPaint.color = Colors.white;
          canvas.drawCircle(position, 7, stationPaint);
        }
        
        // 테두리
        canvas.drawCircle(position, 8, 
          Paint()..style = PaintingStyle.stroke..strokeWidth = 2..color = Colors.black);

        // 역명 표시
        final displayName = name.contains('호선') ? name.split('호선')[0] : 
                          name.contains('경전철') ? name.split('경전철')[0] : name;
        
        textPainter.text = TextSpan(
          text: displayName,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        );
        textPainter.layout();
        
        // 텍스트 위치 조정
        final textX = position.dx - textPainter.width / 2;
        final textY = position.dy + 12;
        
        // 텍스트 배경
        final textBg = Paint()..color = Colors.white.withOpacity(0.8);
        canvas.drawRect(
          Rect.fromLTWH(textX - 2, textY - 2, textPainter.width + 4, textPainter.height + 4),
          textBg
        );
        
        textPainter.paint(canvas, Offset(textX, textY));
      }
    });

    // 공항 특별 표시
    if (stations['공항'] != null) {
      final airportPaint = Paint()
        ..color = Colors.orange
        ..style = PaintingStyle.fill;
      canvas.drawCircle(stations['공항']!, 12, airportPaint);
      
      textPainter.text = const TextSpan(
        text: '✈',
        style: TextStyle(color: Colors.white, fontSize: 14),
      );
      textPainter.layout();
      textPainter.paint(canvas, 
        Offset(stations['공항']!.dx - 7, stations['공항']!.dy - 7));
    }
  }

  void _drawMetroLine(Canvas canvas, Paint paint, List<Offset> points) {
    for (int i = 0; i < points.length - 1; i++) {
      canvas.drawLine(points[i], points[i + 1], paint);
    }
  }

  bool _isTransferStation(String stationName) {
    final transferStations = ['서면', '연산', '사상', '동래', '미남', '덕천'];
    return transferStations.any((transfer) => stationName.contains(transfer));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// 資料模型
class SubwayLine {
  final String number;
  final String name;
  final Color color;
  final List<String> stations;

  SubwayLine({
    required this.number,
    required this.name,
    required this.color,
    required this.stations,
  });
}

class UniqueStation {
  final String name;
  final List<String> lines;
  final String linesDisplay;

  UniqueStation({
    required this.name,
    required this.lines,
    required this.linesDisplay,
  });
}

class RouteInfo {
  final int duration;
  final int transfers;
  final int fare;
  final List<RouteStep> steps;

  RouteInfo({
    required this.duration,
    required this.transfers,
    required this.fare,
    required this.steps,
  });
}

class RouteStep {
  final String line;
  final String description;

  RouteStep({
    required this.line,
    required this.description,
  });
}

// 釜山地鐵路線資料
final List<SubwayLine> _subwayLines = [
  SubwayLine(
    number: '1',
    name: '1號線',
    color: const Color(0xFFFF7A00),
    stations: [
      '신평', '하단', '당리', '사하', '괴정', '대티', '서대신', '동대신', '토성',
      '자갈치', '남포', '중앙', '부산역', '초량', '부산진', '서면', '부전', '양정',
      '시청', '연산', '교대', '동래', '명륜', '온천장', '부산대', '장전', '구서', '범어사'
    ],
  ),
  SubwayLine(
    number: '2',
    name: '2號線',
    color: const Color(0xFF00B04F),
    stations: [
      '장산', '해운대', '중동', '벡스코', '센텀시티', '민락', '수영', '광안', '금련산',
      '남천', '경성대·부경대', '대연', '못골', '지게골', '문현', '국제금융센터·부산은행',
      '전포', '서면', '부암', '가야', '동의대', '개금', '냉정', '주례', '감전', '사상',
      '덕포', '모덕', '모라', '구남', '구명', '덕천', '수정', '화명', '율리', '동원',
      '금곡', '호포', '증산', '부산대양산캠퍼스', '남양산', '양산'
    ],
  ),
  SubwayLine(
    number: '3',
    name: '3號線',
    color: const Color(0xFF8B4513),
    stations: [
      '대저', '체육공원', '강서구청', '구포', '덕천', '숙등', '덕산', '물만골',
      '연산', '거제', '종합운동장', '사직', '미남'
    ],
  ),
  SubwayLine(
    number: '4',
    name: '4號線',  
    color: const Color(0xFF0066CC),
    stations: [
      '미남', '동래', '수안', '낙민', '충렬사', '명장', '서동', '금사',
      '반여농산물시장', '석대', '영산대'
    ],
  ),
  SubwayLine(
    number: '동해선',
    name: '東海線',
    color: const Color(0xFF9966CC),
    stations: [
      '부전', '거제해맞이', '교대', '동래', '안락', '부산원동', '재송',
      '센텀', '벡스코', '신해운대', '송정', '오시리아', '기장', '일광', 
      '좌천', '월내', '서생', '남창', '망양', '덕하', '개운포', '태화강'
    ],
  ),
  SubwayLine(
    number: 'BGL',
    name: '부산김해경전철',
    color: const Color(0xFF663399),
    stations: [
      '사상', '괘법르네시떼', '대저', '평강', '대곡', '수로왕릉', '박물관',
      '연지공원', '보건소', '장유', '장유3', '김해대학', '인제대',
      '김해시청', '부원', '봉황', '김해공항', '공항', '덕두', '등구', '전하', '가야대'
    ],
  ),
];