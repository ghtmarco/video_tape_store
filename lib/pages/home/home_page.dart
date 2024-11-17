import 'package:flutter/material.dart';
import 'package:video_tape_store/pages/product/video_tape_detail_page.dart';
import 'package:video_tape_store/services/api_service.dart';
import 'package:video_tape_store/utils/constants.dart';
import 'package:video_tape_store/models/video_tape.dart';
import 'package:video_tape_store/pages/cart/cart_page.dart';
import 'package:carousel_slider/carousel_slider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _carouselIndex = 0;
  final _searchController = TextEditingController();
  bool _isLoading = true;
  final List<CartItem> cartItems = [];

  List<VideoTape> _featuredTapes = [
    // VideoTape(
    //   id: '1',
    //   title: 'Jurassic Park',
    //   price: 100.00,
    //   description:
    //       'Experience the thrill of dinosaurs in this classic masterpiece.',
    //   genreId: '1',
    //   genreName: 'Sci-Fi',
    //   level: 1,
    //   imageUrls: [
    //     'https://picsum.photos/400/300?random=1',
    //     'https://picsum.photos/400/300?random=2',
    //     'https://picsum.photos/400/300?random=3',
    //   ],
    //   releasedDate: DateTime(1993),
    //   stockQuantity: 5,
    //   rating: 4.8,
    //   totalReviews: 2453,
    // ),
  ];

  List<VideoTape> get _filteredTapes {
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) return _featuredTapes;

    return _featuredTapes.where((tape) {
      return tape.title.toLowerCase().contains(query) ||
          tape.description.toLowerCase().contains(query) ||
          tape.genreName.toLowerCase().contains(query);
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final tapes = await ApiService.getVideoTapes();
      setState(() {
        _featuredTapes = tapes;
        _isLoading = false;
      });
    } catch (e) {
      _showErrorSnackBar('Failed to load data. Please try again.');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: _buildAppBar(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: CustomScrollView(
                slivers: [
                  _buildSearchBar(),
                  SliverToBoxAdapter(
                    child: _buildFeaturedCarousel(),
                  ),
                  _buildSectionHeader('Popular Video Tapes'),
                  _buildVideoTapeGrid(),
                ],
              ),
            ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: const Text(
        AppStrings.appName,
        style: AppTextStyles.headingMedium,
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.shopping_cart),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CartPage(cartItems: cartItems),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return SliverPadding(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      sliver: SliverToBoxAdapter(
        child: TextField(
          controller: _searchController,
          onChanged: (value) => setState(() {}),
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search),
            filled: true,
            fillColor: AppColors.surfaceColor,
            border: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(AppDimensions.borderRadiusSmall),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturedCarousel() {
    return Column(
      children: [
        CarouselSlider(
          options: CarouselOptions(
            height: 200,
            viewportFraction: 0.8,
            enlargeCenterPage: true,
            autoPlay: true,
            onPageChanged: (index, reason) {
              setState(() => _carouselIndex = index);
            },
          ),
          items: _featuredTapes.map((tape) {
            return Builder(
              builder: (BuildContext context) {
                return Container(
                  width: MediaQuery.of(context).size.width,
                  margin: const EdgeInsets.symmetric(horizontal: 5.0),
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(AppDimensions.borderRadiusMedium),
                    image: DecorationImage(
                      image: NetworkImage(tape.imageUrls.first),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                          AppDimensions.borderRadiusMedium),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                    padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tape.title,
                          style: AppTextStyles.headingSmall,
                        ),
                        const SizedBox(height: AppDimensions.marginSmall),
                        Row(
                          children: [
                            Text(
                              '\$${tape.price.toStringAsFixed(2)}',
                              style: AppTextStyles.priceText,
                            ),
                            const Spacer(),
                            Row(
                              children: [
                                const Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  tape.rating.toStringAsFixed(1),
                                  style: AppTextStyles.bodySmall,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }).toList(),
        ),
        const SizedBox(height: AppDimensions.marginSmall),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: _featuredTapes.asMap().entries.map((entry) {
            return Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _carouselIndex == entry.key
                    ? AppColors.primaryColor
                    : AppColors.surfaceColor,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return SliverPadding(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      sliver: SliverToBoxAdapter(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: AppTextStyles.headingSmall),
            TextButton(
              onPressed: () {},
              child: const Text('See All'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoTapeGrid() {
    return SliverPadding(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.5,
          crossAxisSpacing: AppDimensions.marginMedium,
          mainAxisSpacing: AppDimensions.marginMedium,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final tape = _filteredTapes[index];
            return Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(AppDimensions.borderRadiusMedium),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 6,
                    child: InkWell(
                      onTap: () => _navigateToDetail(tape),
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top:
                              Radius.circular(AppDimensions.borderRadiusMedium),
                        ),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.network(
                              tape.imageUrls.first,
                              fit: BoxFit.cover,
                            ),
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      Colors.black.withOpacity(0.7),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              top: 8,
                              left: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryColor,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  tape.genreName,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tape.title,
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '\$${tape.price.toStringAsFixed(2)}',
                                style: AppTextStyles.priceText,
                              ),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.star,
                                    size: 14,
                                    color: Colors.amber,
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    tape.rating.toStringAsFixed(1),
                                    style: AppTextStyles.bodySmall,
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const Spacer(),
                          SizedBox(
                            width: double.infinity,
                            height: 32,
                            child: ElevatedButton(
                              onPressed: () => _addToCart(tape),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.successColor,
                                padding: EdgeInsets.zero,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              child: const Text(
                                'Add to Cart',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
          childCount: _filteredTapes.length,
        ),
      ),
    );
  }

  void _addToCart(VideoTape tape) {
    setState(() {
      cartItems.add(CartItem(tape: tape));
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${tape.title} added to cart'),
        action: SnackBarAction(
          label: 'View Cart',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CartPage(cartItems: cartItems),
              ),
            );
          },
        ),
      ),
    );
  }

  void _navigateToDetail(VideoTape tape) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoTapeDetailPage(
          tape: tape,
          cartItems: cartItems,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
