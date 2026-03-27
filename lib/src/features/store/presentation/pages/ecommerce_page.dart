import 'package:flutter/material.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';

import '../../data/model/product_model.dart';
import '../../data/repository/product_repository.dart';
import '../widgets/product_item.dart';

class ECommerceScreen extends StatefulWidget {
  final ProductRepository productRepository;

  const ECommerceScreen({Key? key, required this.productRepository})
      : super(key: key);

  @override
  _ECommerceScreenState createState() => _ECommerceScreenState();
}

class _ECommerceScreenState extends State<ECommerceScreen> {
  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  final TextEditingController _searchController = TextEditingController();

  // ✅ Added for interactivity: Category filtering
  final List<String> _categories = ['All', 'Books', 'Courses', 'Mock Tests'];
  String _selectedCategory = 'All';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchProducts() async {
    setState(() => _isLoading = true);

    List<Product> products = await widget.productRepository.getProducts();

    if (mounted) {
      setState(() {
        _products = products;
        _isLoading = false;
      });
      _applyFilters(); // Apply any existing search/category filters
    }
  }

  // ✅ Consolidated filter method for both Search and Categories
  void _applyFilters() {
    final query = _searchController.text.toLowerCase();

    setState(() {
      _filteredProducts = _products.where((product) {
        final matchesSearch = product.title.toLowerCase().contains(query);
        // Assuming your Product model has a 'category' field.
        // If not, you can remove the category logic or adapt it to your model.
        final matchesCategory = _selectedCategory == 'All' ||
            product.category == _selectedCategory;

        return matchesSearch && matchesCategory;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.background,
      appBar: AppBar(
        title: const Text(
          'Library',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(130), // ✅ Expanded to fit chips
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── SEARCH BAR ───
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) => _applyFilters(),
                  decoration: InputDecoration(
                    hintText: 'Search library...',
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    fillColor: cs.surface,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: cs.outline.withOpacity(0.3)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: cs.outline.withOpacity(0.3)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: cs.primary, width: 2),
                    ),
                    prefixIcon: Icon(Icons.search, color: cs.primary),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                      icon: Icon(Icons.clear, color: cs.onSurfaceVariant),
                      onPressed: () {
                        _searchController.clear();
                        _applyFilters();
                        FocusScope.of(context).unfocus(); // Dismiss keyboard
                      },
                    )
                        : null,
                  ),
                ),
              ),

              // ─── CATEGORY CHIPS (Interactive) ───
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: _categories.map((category) {
                    final isSelected = _selectedCategory == category;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0, bottom: 12.0),
                      child: ChoiceChip(
                        label: Text(
                          category,
                          style: TextStyle(
                            color: isSelected ? cs.onPrimary : cs.onSurfaceVariant,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        selected: isSelected,
                        selectedColor: cs.primary,
                        backgroundColor: cs.surfaceVariant.withOpacity(0.5),
                        onSelected: (selected) {
                          setState(() => _selectedCategory = category);
                          _applyFilters();
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),

      // ─── SAFE SCROLL BODY ───
      body: LiquidPullToRefresh(
        color: cs.primary,
        backgroundColor: cs.surface,
        showChildOpacityTransition: true,
        onRefresh: _fetchProducts,
        // ✅ CustomScrollView ensures the screen is ALWAYS scrollable
        // even when empty, allowing pull-to-refresh to work.
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            if (_isLoading)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_filteredProducts.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _buildEmptyState(context),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverGrid(
                  // ✅ Fixes Overflow: mainAxisExtent forces the card to be exactly
                  // 260px tall regardless of screen width, preventing text overflow!
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 220, // Max width of a card
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    mainAxisExtent: 260, // Fixed height (adjust based on your ProductItem)
                  ),
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      return SingleProductItem(product: _filteredProducts[index]);
                    },
                    childCount: _filteredProducts.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: cs.primaryContainer.withOpacity(0.4),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search_off_rounded,
                size: 64,
                color: cs.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Products Found',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _searchController.text.isNotEmpty || _selectedCategory != 'All'
                  ? 'Try changing your search or category filter.'
                  : 'The library is currently empty.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: cs.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            if (_searchController.text.isNotEmpty || _selectedCategory != 'All')
              TextButton.icon(
                onPressed: () {
                  _searchController.clear();
                  setState(() => _selectedCategory = 'All');
                  _applyFilters();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Clear Filters'),
              ),
          ],
        ),
      ),
    );
  }
}
