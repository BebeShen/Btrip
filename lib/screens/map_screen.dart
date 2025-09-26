import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart'; // 需要添加依賴
// import 'package:geolocator/geolocator.dart'; // 需要添加依賴

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  // GoogleMapController? _controller;
  
  // 釜山中心點座標
  // static const LatLng _busanCenter = LatLng(35.1796, 129.0756);
  
  String _selectedCategory = '全部';
  final List<String> _categories = ['全部', '海灘', '文化', '購物', '美食', '交通'];
  
  List<BusanAttraction> _attractions = [];
  List<BusanAttraction> _filteredAttractions = [];

  @override
  void initState() {
    super.initState();
    _initializeAttractions();
    _filterAttractions();
  }

  void _initializeAttractions() {
    _attractions = [
      // 海灘景點
      BusanAttraction(
        id: '1',
        name: '海雲台海灘',
        nameKorean: '해운대해수욕장',
        category: '海灘',
        description: '釜山最著名的海灘，擁有細白沙灘和清澈海水',
        latitude: 35.1587,
        longitude: 129.1603,
        nearestStation: '2號線 해운대역',
        rating: 4.5,
        imageUrl: 'assets/images/haeundae.jpg',
      ),
      BusanAttraction(
        id: '2',
        name: '廣安里海灘',
        nameKorean: '광안리해수욕장',
        category: '海灘',
        description: '夜景優美的海灘，可欣賞廣安大橋夜景',
        latitude: 35.1532,
        longitude: 129.1185,
        nearestStation: '2號線 광안역',
        rating: 4.3,
        imageUrl: 'assets/images/gwangalli.jpg',
      ),
      
      // 文化景點
      BusanAttraction(
        id: '3',
        name: '甘川洞文化村',
        nameKorean: '감천문화마을',
        category: '文化',
        description: '彩色房屋聚集的藝術村落，被稱為韓國聖托里尼',
        latitude: 35.0976,
        longitude: 129.0103,
        nearestStation: '1號線 토성역',
        rating: 4.4,
        imageUrl: 'assets/images/gamcheon.jpg',
      ),
      BusanAttraction(
        id: '4',
        name: '梵魚寺',
        nameKorean: '범어사',
        category: '文化',
        description: '新羅時代古剎，釜山最重要的佛教寺廟',
        latitude: 35.2364,
        longitude: 129.0650,
        nearestStation: '1號線 범어사역',
        rating: 4.2,
        imageUrl: 'assets/images/beomeosa.jpg',
      ),
      
      // 購物景點
      BusanAttraction(
        id: '5',
        name: 'CENTUM CITY',
        nameKorean: '센텀시티',
        category: '購物',
        description: '大型購物中心，包含新世界百貨和樂天百貨',
        latitude: 35.1692,
        longitude: 129.1313,
        nearestStation: '2號線 센텀시티역',
        rating: 4.1,
        imageUrl: 'assets/images/centum.jpg',
      ),
      BusanAttraction(
        id: '6',
        name: '西面商圈',
        nameKorean: '서면',
        category: '購物',
        description: '釜山最繁華的商業區，購物和美食聚集地',
        latitude: 35.1579,
        longitude: 129.0560,
        nearestStation: '1·2號線 서면역',
        rating: 4.0,
        imageUrl: 'assets/images/seomyeon.jpg',
      ),
      
      // 美食景點
      BusanAttraction(
        id: '7',
        name: '札嘎其市場',
        nameKorean: '자갈치시장',
        category: '美食',
        description: '韓國最大的海鮮市場，新鮮海產和海鮮料理',
        latitude: 35.0967,
        longitude: 129.0306,
        nearestStation: '1號線 자갈치역',
        rating: 4.3,
        imageUrl: 'assets/images/jagalchi.jpg',
      ),
      BusanAttraction(
        id: '8',
        name: '國際市場',
        nameKorean: '국제시장',
        category: '美食',
        description: '傳統市場，可品嘗各種韓式小吃和料理',
        latitude: 35.1022,
        longitude: 129.0287,
        nearestStation: '1號線 남포역',
        rating: 4.0,
        imageUrl: 'assets/images/gukje_market.jpg',
      ),
      
      // 交通景點
      BusanAttraction(
        id: '9',
        name: '釜山站',
        nameKorean: '부산역',
        category: '交通',
        description: '釜山主要火車站，KTX高速鐵路終點站',
        latitude: 35.1154,
        longitude: 129.0422,
        nearestStation: '1號線 부산역',
        rating: 3.8,
        imageUrl: 'assets/images/busan_station.jpg',
      ),
      BusanAttraction(
        id: '10',
        name: '金海國際機場',
        nameKorean: '김해국제공항',
        category: '交通',
        description: '釜山地區主要國際機場',
        latitude: 35.1795,
        longitude: 128.9382,
        nearestStation: '金海輕軌 공항역',
        rating: 3.9,
        imageUrl: 'assets/images/gimhae_airport.jpg',
      ),
    ];
  }

  void _filterAttractions() {
    setState(() {
      if (_selectedCategory == '全部') {
        _filteredAttractions = List.from(_attractions);
      } else {
        _filteredAttractions = _attractions
            .where((attraction) => attraction.category == _selectedCategory)
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('釜山景點地圖'),
        backgroundColor: Colors.blue.shade50,
      ),
      body: Column(
        children: [
          // 分類篩選器
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = category == _selectedCategory;
                
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = category;
                        _filterAttractions();
                      });
                    },
                    backgroundColor: Colors.grey.shade200,
                    selectedColor: Colors.blue.shade100,
                    checkmarkColor: Colors.blue.shade700,
                  ),
                );
              },
            ),
          ),
          
          // 地圖區域 (暫時用容器代替)
          Expanded(
            flex: 3,
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: Colors.grey.shade100,
                  child: Stack(
                    children: [
                      // 地圖佔位符
                      const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.map, size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(
                              'Google Maps 將顯示在這裡',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              '需要添加 google_maps_flutter 依賴',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      
                      // 地圖控制按鈕
                      Positioned(
                        top: 16,
                        right: 16,
                        child: Column(
                          children: [
                            FloatingActionButton.small(
                              heroTag: "location",
                              onPressed: () {
                                // 獲取當前位置
                                _showLocationDialog();
                              },
                              child: const Icon(Icons.my_location),
                            ),
                            const SizedBox(height: 8),
                            FloatingActionButton.small(
                              heroTag: "refresh",
                              onPressed: () {
                                // 重新載入地圖
                                _refreshMap();
                              },
                              child: const Icon(Icons.refresh),
                            ),
                          ],
                        ),
                      ),
                      
                      // 景點標記點 (示意)
                      ..._filteredAttractions.map((attraction) => 
                        Positioned(
                          left: (attraction.latitude - 35.0) * 1000, // 示意座標轉換
                          top: (129.2 - attraction.longitude) * 1000,
                          child: GestureDetector(
                            onTap: () => _showAttractionDetails(attraction),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: _getCategoryColor(attraction.category),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                              child: Icon(
                                _getCategoryIcon(attraction.category),
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          // 景點列表
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${_selectedCategory}景點 (${_filteredAttractions.length})',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          // 切換列表/網格視圖
                        },
                        icon: const Icon(Icons.view_list),
                        label: const Text('列表'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  Expanded(
                    child: ListView.builder(
                      itemCount: _filteredAttractions.length,
                      itemBuilder: (context, index) {
                        final attraction = _filteredAttractions[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: _getCategoryColor(attraction.category),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                _getCategoryIcon(attraction.category),
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            title: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  attraction.name,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  attraction.nameKorean,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text(attraction.description),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(Icons.train, size: 14, color: Colors.blue),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        attraction.nearestStation,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.blue,
                                        ),
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Icon(Icons.star, size: 14, color: Colors.orange),
                                        Text(
                                          attraction.rating.toString(),
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () => _showAttractionDetails(attraction),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case '海灘':
        return Colors.blue;
      case '文化':
        return Colors.purple;
      case '購物':
        return Colors.green;
      case '美食':
        return Colors.orange;
      case '交通':
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case '海灘':
        return Icons.beach_access;
      case '文化':
        return Icons.temple_buddhist;
      case '購物':
        return Icons.shopping_bag;
      case '美食':
        return Icons.restaurant;
      case '交通':
        return Icons.train;
      default:
        return Icons.place;
    }
  }

  void _showLocationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('定位功能'),
        content: const Text('此功能需要添加位置權限\n將會移動地圖到您的當前位置'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: 實現定位功能
            },
            child: const Text('確定'),
          ),
        ],
      ),
    );
  }

  void _refreshMap() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('地圖已重新載入')),
    );
  }

  void _showAttractionDetails(BusanAttraction attraction) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (_, controller) => Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          attraction.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          attraction.nameKorean,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getCategoryColor(attraction.category),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      attraction.category,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // 評分
              Row(
                children: [
                  ...List.generate(5, (index) {
                    return Icon(
                      index < attraction.rating.floor() 
                          ? Icons.star 
                          : Icons.star_border,
                      color: Colors.orange,
                    );
                  }),
                  const SizedBox(width: 8),
                  Text(
                    '${attraction.rating}/5.0',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              Text(
                '景點介紹',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(attraction.description),
              
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Icon(Icons.train, color: Colors.blue),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '最近地鐵站',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(attraction.nearestStation),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // 行動按鈕
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // TODO: 導航功能
                      },
                      icon: const Icon(Icons.directions),
                      label: const Text('導航'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // TODO: 加入行程
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('加入行程'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BusanAttraction {
  final String id;
  final String name;
  final String nameKorean;
  final String category;
  final String description;
  final double latitude;
  final double longitude;
  final String nearestStation;
  final double rating;
  final String imageUrl;

  BusanAttraction({
    required this.id,
    required this.name,
    required this.nameKorean,
    required this.category,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.nearestStation,
    required this.rating,
    required this.imageUrl,
  });
}