import 'package:flutter/material.dart';
import 'package:video_tape_store/utils/constants.dart';
import 'package:video_tape_store/models/video_tape.dart';
import 'package:video_tape_store/pages/admin/add_edit_video_page.dart';

class AdminVideoListPage extends StatefulWidget {
  const AdminVideoListPage({super.key});

  @override
  State<AdminVideoListPage> createState() => _AdminVideoListPageState();
}

class _AdminVideoListPageState extends State<AdminVideoListPage> {
  bool _isLoading = false;
  final _searchController = TextEditingController();
  String _selectedGenre = 'All';

  final List<VideoTape> _videoTapes = [
    VideoTape(
      id: '1',
      title: 'Jurassic Park',
      price: 29.99,
      description:
          'Experience the thrill of dinosaurs in this classic masterpiece.',
      genreId: '1',
      genreName: 'Sci-Fi',
      level: 1,
      imageUrls: [
        'https://picsum.photos/400/300?random=1',
        'https://picsum.photos/400/300?random=2',
      ],
      releasedDate: DateTime(1993),
      stockQuantity: 5,
      rating: 4.8,
      totalReviews: 2453,
    ),
  ];

  List<VideoTape> get _filteredTapes {
    return _videoTapes.where((tape) {
      final matchesSearch = tape.title.toLowerCase().contains(
            _searchController.text.toLowerCase(),
          );
      final matchesGenre =
          _selectedGenre == 'All' || tape.genreName == _selectedGenre;
      return matchesSearch && matchesGenre;
    }).toList();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      await Future.delayed(const Duration(seconds: 1));
    } catch (e) {
      _showErrorSnackBar('Failed to load data');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.errorColor,
      ),
    );
  }

  Future<void> _deleteVideoTape(VideoTape tape) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete "${tape.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.errorColor,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed ?? false) {
      setState(() => _isLoading = true);
      try {
        await Future.delayed(const Duration(seconds: 1));
        setState(() {
          _videoTapes.remove(tape);
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Video tape deleted successfully')),
          );
        }
      } catch (e) {
        _showErrorSnackBar('Failed to delete video tape');
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceColor,
        title: const Text(
          'Manage Video Tapes',
          style: AppTextStyles.headingMedium,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddEditVideoPage(),
                ),
              ).then((_) => _loadData());
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(AppDimensions.paddingMedium),
            color: AppColors.surfaceColor,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Search video tapes...',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: AppColors.backgroundColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          AppDimensions.borderRadiusSmall,
                        ),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppDimensions.marginMedium),
                DropdownButton<String>(
                  value: _selectedGenre,
                  items: [
                    'All',
                    ...VideoGenre.values.map((e) => e.displayName),
                  ].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedGenre = newValue;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredTapes.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding:
                            const EdgeInsets.all(AppDimensions.paddingMedium),
                        itemCount: _filteredTapes.length,
                        itemBuilder: (context, index) {
                          final tape = _filteredTapes[index];
                          return _buildVideoTapeCard(tape);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.movie_creation_outlined,
            size: AppDimensions.iconSizeLarge * 2,
            color: AppColors.primaryColor,
          ),
          const SizedBox(height: AppDimensions.marginLarge),
          const Text(
            'No video tapes found',
            style: AppTextStyles.headingSmall,
          ),
          const SizedBox(height: AppDimensions.marginMedium),
          Text(
            _searchController.text.isEmpty
                ? 'Add some video tapes to get started'
                : 'Try adjusting your search or filters',
            style: AppTextStyles.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildVideoTapeCard(VideoTape tape) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppDimensions.marginMedium),
      child: ListTile(
        contentPadding: const EdgeInsets.all(AppDimensions.paddingMedium),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(AppDimensions.borderRadiusSmall),
          child: Image.network(
            tape.imageUrls.first,
            width: 60,
            height: 80,
            fit: BoxFit.cover,
          ),
        ),
        title: Text(
          tape.title,
          style: AppTextStyles.bodyMedium,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              '\$${tape.price.toStringAsFixed(2)}',
              style: AppTextStyles.priceText,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(
                      AppDimensions.borderRadiusSmall,
                    ),
                  ),
                  child: Text(
                    tape.genreName,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.primaryColor,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Stock: ${tape.stockQuantity}',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddEditVideoPage(tape: tape),
                  ),
                ).then((_) => _loadData());
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              color: AppColors.errorColor,
              onPressed: () => _deleteVideoTape(tape),
            ),
          ],
        ),
      ),
    );
  }
}
