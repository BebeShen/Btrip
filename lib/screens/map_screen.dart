import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart'; // 需要添加依賴
import 'package:geolocator/geolocator.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  // 釜山中心點座標
  static const LatLng _busanCenter = LatLng(35.1796, 129.0756);

  GoogleMapController? _mapController;
  Set<Marker> _markers = {};

  String _selectedCategory = '全部';
  final List<String> _categories = ['全部', '海灘', '文化', '購物', '美食', '交通'];
  
  // 假資料，您可替換為從 API 取得的真實資料
  final List<BusanAttraction> _allAttractions = [
    BusanAttraction(
      id: '1',
      name: '海雲台海灘',
      nameKorean: '해운대해수욕장',
      category: '海灘',
      description: '釜山最著名的海灘，以美麗的沙灘和年度活動而聞名。',
      latitude: 35.1587,
      longitude: 129.1606,
      nearestStation: '海雲台',
      rating: 4.8,
      imageUrl: '',
    ),
    BusanAttraction(
      id: '2',
      name: '甘川洞文化村',
      nameKorean: '감천문화마을',
      category: '文化',
      description: '被稱為「釜山的馬丘比丘」，以其色彩繽紛的房屋和藝術壁畫而聞名。',
      latitude: 35.0991,
      longitude: 129.0135,
      nearestStation: '土城',
      rating: 4.7,
      imageUrl: '',
    ),
    BusanAttraction(
      id: '3',
      name: '南浦洞國際市場',
      nameKorean: '남포동 국제시장',
      category: '購物',
      description: '一個大型市場，銷售各種商品，包括服裝、化妝品和街頭小吃。',
      latitude: 35.1011,
      longitude: 129.0270,
      nearestStation: '南浦',
      rating: 4.5,
      imageUrl: '',
    ),
  ];
  
  List<BusanAttraction> _filteredAttractions = [];

  @override
  void initState() {
    super.initState();
    _filterAttractions();
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    _createMarkers();
  }

  void _filterAttractions() {
    setState(() {
      if (_selectedCategory == '全部') {
        _filteredAttractions = List.from(_allAttractions);
      } else {
        _filteredAttractions = _allAttractions
            .where((attraction) => attraction.category == _selectedCategory)
            .toList();
      }
      _createMarkers();
    });
  }

  void _createMarkers() {
    final Set<Marker> markers = {};
    for (var attraction in _filteredAttractions) {
      markers.add(
        Marker(
          markerId: MarkerId(attraction.id),
          position: LatLng(attraction.latitude, attraction.longitude),
          infoWindow: InfoWindow(
            title: attraction.name,
            snippet: attraction.description,
            onTap: () => _showAttractionDetails(attraction),
          ),
        ),
      );
    }
    _markers = markers;
  }
  
  // 取得使用者當前位置並移動地圖
  Future<void> _getUserLocation() async {
    // TODO: 需處理權限要求
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      _mapController?.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(position.latitude, position.longitude),
          zoom: 15,
        ),
      ));
    } catch (e) {
      debugPrint("Error getting location: $e");
    }
  }

  void _showAttractionDetails(BusanAttraction attraction) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                attraction.name,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(attraction.description),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // TODO: 導航功能
                        Navigator.of(context).pop();
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
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('加入行程'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('地圖'),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: _getUserLocation,
            tooltip: '我的位置',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: SizedBox(
            height: 48,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: ChoiceChip(
                    label: Text(category),
                    selected: _selectedCategory == category,
                    onSelected: (bool selected) {
                      if (selected) {
                        setState(() {
                          _selectedCategory = category;
                          _filterAttractions();
                        });
                      }
                    },
                  ),
                );
              },
            ),
          ),
        ),
      ),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: const CameraPosition(
          target: _busanCenter,
          zoom: 12.0,
        ),
        markers: _markers,
        myLocationButtonEnabled: false,
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