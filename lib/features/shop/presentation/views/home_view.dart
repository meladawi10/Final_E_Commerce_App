
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:t_store/core/utils/constants/colors.dart';

import 'package:t_store/core/common/widgets/horizontal_small_list_view.dart';
import 'package:t_store/core/common/view_models/section_heading_view_model.dart';
import 'package:t_store/core/common/widgets/section_heading.dart';

import 'package:t_store/features/shop/presentation/cubit/products_cubit.dart';
import 'package:t_store/features/shop/presentation/cubit/products_state.dart';

import 'package:t_store/features/shop/presentation/cubit/categories_cubit.dart';
import 'package:t_store/features/shop/presentation/cubit/categories_state.dart';

import 'package:t_store/features/shop/presentation/widgets/home_categories.dart';
import 'package:t_store/features/shop/presentation/widgets/home_header_section.dart';
import 'package:t_store/features/shop/presentation/widgets/promo_banner_carousel_slider.dart';

import 'package:t_store/features/personalization/presentation/cubit/profile_cubit.dart';

import 'package:t_store/core/dependency_injection/service_locator.dart';

import 'all_products_view.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => sl<ProfileCubit>()..getProfile(),
        ),
        BlocProvider(
          create: (context) => sl<ProductsCubit>()..getProducts(
            refresh: true,
          ),
        ),
        BlocProvider(
          create: (context) => sl<CategoriesCubit>()..getCategories(),
        ),
      ],
      child: const HomeViewBody(),
    );
  }
}

// ============================================================
// HOME BODY
// ============================================================

class HomeViewBody extends StatefulWidget {
  const HomeViewBody({super.key});

  @override
  State<HomeViewBody> createState() => _HomeViewBodyState();
}

class _HomeViewBodyState extends State<HomeViewBody> {
  // ==========================================================
  // SORT
  // ==========================================================

  String _selectedSort = 'none';

  // ==========================================================
  // FILTER
  // ==========================================================

  String? _selectedCategoryId;
  String? _selectedBrandId;

  double? _minPrice;
  double? _maxPrice;

  bool _onlyDiscounted = false;

  // ==========================================================
  // SORT LABEL
  // ==========================================================

  String get _sortLabel {
    switch (_selectedSort) {
      case 'low_to_high':
        return 'Price ↑';

      case 'high_to_low':
        return 'Price ↓';

      case 'name_a_z':
        return 'Name A-Z';

      case 'rating':
        return 'Rating';

      case 'newest':
        return 'Newest';

      default:
        return 'Sort';
    }
  }

  // ==========================================================
  // FILTER ACTIVE
  // ==========================================================

  bool get _hasActiveFilters {
    return _selectedCategoryId != null ||
        _selectedBrandId != null ||
        _minPrice != null ||
        _maxPrice != null ||
        _onlyDiscounted;
  }

  // ==========================================================
  // APPLY FILTER
  // ==========================================================

  void _applyFilters() {
    context.read<ProductsCubit>().applyFiltersLocally(
          categoryId: _selectedCategoryId,
          brandId: _selectedBrandId,
          minPrice: _minPrice,
          maxPrice: _maxPrice,
          onlyDiscounted: _onlyDiscounted,
          sortType: _selectedSort,
        );
  }

  // ==========================================================
  // SORT SHEET
  // ==========================================================

  void _showSortSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final dark =
            Theme.of(sheetContext).brightness == Brightness.dark;

        return Material(
          color: dark ? TColors.darkContainer : Colors.white,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(24),
          ),
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              20,
              12,
              20,
              30,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle
                Container(
                  width: 45,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

                const SizedBox(height: 20),

                Row(
                  children: [
                    const Icon(
                      Icons.sort,
                      color: TColors.primary,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Sort Products',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: dark ? Colors.white : Colors.black,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 15),

                _SortOption(
                  title: 'Default',
                  icon: Icons.auto_awesome,
                  value: 'none',
                  selectedValue: _selectedSort,
                  onTap: () {
                    setState(() {
                      _selectedSort = 'none';
                    });

                    Navigator.pop(sheetContext);
                    _applyFilters();
                  },
                ),

                _SortOption(
                  title: 'Price: Low to High',
                  icon: Icons.arrow_upward,
                  value: 'low_to_high',
                  selectedValue: _selectedSort,
                  onTap: () {
                    setState(() {
                      _selectedSort = 'low_to_high';
                    });

                    Navigator.pop(sheetContext);
                    _applyFilters();
                  },
                ),

                _SortOption(
                  title: 'Price: High to Low',
                  icon: Icons.arrow_downward,
                  value: 'high_to_low',
                  selectedValue: _selectedSort,
                  onTap: () {
                    setState(() {
                      _selectedSort = 'high_to_low';
                    });

                    Navigator.pop(sheetContext);
                    _applyFilters();
                  },
                ),

                _SortOption(
                  title: 'Name: A to Z',
                  icon: Icons.sort_by_alpha,
                  value: 'name_a_z',
                  selectedValue: _selectedSort,
                  onTap: () {
                    setState(() {
                      _selectedSort = 'name_a_z';
                    });

                    Navigator.pop(sheetContext);
                    _applyFilters();
                  },
                ),

                _SortOption(
                  title: 'Highest Rating',
                  icon: Icons.star,
                  value: 'rating',
                  selectedValue: _selectedSort,
                  onTap: () {
                    setState(() {
                      _selectedSort = 'rating';
                    });

                    Navigator.pop(sheetContext);
                    _applyFilters();
                  },
                ),

                _SortOption(
                  title: 'Newest',
                  icon: Icons.new_releases,
                  value: 'newest',
                  selectedValue: _selectedSort,
                  onTap: () {
                    setState(() {
                      _selectedSort = 'newest';
                    });

                    Navigator.pop(sheetContext);
                    _applyFilters();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ==========================================================
  // FILTER SHEET
  // ==========================================================

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return _FilterBottomSheet(
          selectedCategoryId: _selectedCategoryId,
          selectedBrandId: _selectedBrandId,
          minPrice: _minPrice,
          maxPrice: _maxPrice,
          onlyDiscounted: _onlyDiscounted,
          onApply: ({
            String? categoryId,
            String? brandId,
            double? minPrice,
            double? maxPrice,
            bool onlyDiscounted = false,
          }) {
            setState(() {
              _selectedCategoryId = categoryId;
              _selectedBrandId = brandId;
              _minPrice = minPrice;
              _maxPrice = maxPrice;
              _onlyDiscounted = onlyDiscounted;
            });

            Navigator.pop(sheetContext);
            _applyFilters();
          },
        );
      },
    );
  }

  // ==========================================================
  // RESET ALL
  // ==========================================================

  void _resetAllFilters() {
    setState(() {
      _selectedCategoryId = null;
      _selectedBrandId = null;
      _minPrice = null;
      _maxPrice = null;
      _onlyDiscounted = false;
      _selectedSort = 'none';
    });

    context.read<ProductsCubit>().resetFilters();
  }

  // ==========================================================
  // REFRESH
  // ==========================================================

  Future<void> _refresh() async {
    context.read<ProfileCubit>().getProfile();

    await context.read<ProductsCubit>().getProducts(
          refresh: true,
        );

    context.read<CategoriesCubit>().getCategories();
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    final dark =
        Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          color: TColors.primary,
          backgroundColor:
              dark ? TColors.darkContainer : Colors.white,
          onRefresh: _refresh,
          child: SingleChildScrollView(
            physics:
                const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const HomeHeaderSection(),

                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      // ==================================================
                      // ALL FEATURED + SORT + FILTER
                      // ==================================================

                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'All Featured',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: dark
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),

                          Row(
                            children: [
                              // SORT
                              GestureDetector(
                                onTap: _showSortSheet,
                                child: Container(
                                  padding:
                                      const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 7,
                                  ),
                                  decoration:
                                      BoxDecoration(
                                    color: dark
                                        ? TColors.darkContainer
                                        : Colors.grey[200],
                                    borderRadius:
                                        BorderRadius.circular(8),
                                    border: _selectedSort != 'none'
                                        ? Border.all(
                                            color: TColors.primary,
                                          )
                                        : null,
                                  ),
                                  child: Row(
                                    children: [
                                      Text(
                                        _sortLabel,
                                        style: TextStyle(
                                          color: dark
                                              ? Colors.white
                                              : Colors.black,
                                          fontSize: 12,
                                          fontWeight:
                                              FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Icon(
                                        Icons.sort,
                                        size: 16,
                                        color: dark
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              const SizedBox(width: 8),

                              // FILTER
                              GestureDetector(
                                onTap: _showFilterSheet,
                                child: Container(
                                  padding:
                                      const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 7,
                                  ),
                                  decoration:
                                      BoxDecoration(
                                    color: dark
                                        ? TColors.darkContainer
                                        : Colors.grey[200],
                                    borderRadius:
                                        BorderRadius.circular(8),
                                    border: _hasActiveFilters
                                        ? Border.all(
                                            color: TColors.primary,
                                          )
                                        : null,
                                  ),
                                  child: Row(
                                    children: [
                                      Text(
                                        _hasActiveFilters
                                            ? 'Filter ✓'
                                            : 'Filter',
                                        style: TextStyle(
                                          color: dark
                                              ? Colors.white
                                              : Colors.black,
                                          fontSize: 12,
                                          fontWeight:
                                              FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Icon(
                                        Icons.filter_alt_outlined,
                                        size: 16,
                                        color: dark
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      // ==================================================
                      // ACTIVE FILTER RESET
                      // ==================================================

                      if (_hasActiveFilters ||
                          _selectedSort != 'none') ...[
                        const SizedBox(height: 12),

                        GestureDetector(
                          onTap: _resetAllFilters,
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.close,
                                size: 16,
                                color: TColors.primary,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Clear sorting & filters',
                                style: TextStyle(
                                  color: TColors.primary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 16),

                      // ==================================================
                      // CATEGORIES
                      // ==================================================

                      const HomeCategories(),

                      const SizedBox(height: 24),

                      // ==================================================
                      // PROMO
                      // ==================================================

                      const PromoBannerCarouselSlider(),

                      const SizedBox(height: 24),

                      // ==================================================
                      // PRODUCTS
                      // ==================================================

                      BlocBuilder<ProductsCubit, ProductsState>(
                        builder: (context, state) {
                          if (state is ProductsLoading) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(20),
                                child:
                                    CircularProgressIndicator(),
                              ),
                            );
                          }

                          if (state is ProductsLoaded) {
                            return Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                // ======================================
                                // DEAL OF THE DAY
                                // ======================================

                                ColoredSectionHeader(
                                  title: 'Deal of the Day',
                                  subtitle:
                                      '22h 55m 20s remaining',
                                  color: Colors.blue,
                                  icon: Icons.access_time,
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const AllProductsView(
                                          title: 'Deal of the Day',
                                          isFeatured: true,
                                        ),
                                      ),
                                    );
                                  },
                                ),

                                const SizedBox(height: 16),

                                HorizontalSmallListView(
                                  items: state.featuredProducts,
                                ),

                                const SizedBox(height: 24),

                                // ======================================
                                // BANNER
                                // ======================================

                                ClipRRect(
                                  borderRadius:
                                      BorderRadius.circular(12),
                                  child: Image.asset(
                                    'assets/images/banners/banner_4.jpg',
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                  ),
                                ),

                                const SizedBox(height: 24),

                                // ======================================
                                // TRENDING
                                // ======================================

                                ColoredSectionHeader(
                                  title: 'Trending Products',
                                  subtitle:
                                      'Last Date 29/02/22',
                                  color: Colors.redAccent,
                                  icon: Icons.calendar_month,
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const AllProductsView(
                                          title:
                                              'Trending Products',
                                          categoryId:
                                              'mens-shirts',
                                        ),
                                      ),
                                    );
                                  },
                                ),

                                const SizedBox(height: 16),

                                HorizontalSmallListView(
                                  items: state.popularProducts,
                                ),

                                const SizedBox(height: 24),

                                // ======================================
                                // BANNER
                                // ======================================

                                ClipRRect(
                                  borderRadius:
                                      BorderRadius.circular(12),
                                  child: Image.asset(
                                    'assets/images/banners/banner_2.jpg',
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                  ),
                                ),

                                const SizedBox(height: 24),

                                // ======================================
                                // NEW ARRIVALS
                                // ======================================

                                SectionHeading(
                                  sectionHeadingModel:
                                      SectionHeadingModel(
                                    title: 'New Arrivals',
                                    showActionButton: true,
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const AllProductsView(
                                            title: 'New Arrivals',
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),

                                const SizedBox(height: 16),

                                HorizontalSmallListView(
                                  items: state.newArrivals,
                                ),

                                const SizedBox(height: 24),

                                // ======================================
                                // RESULT COUNT
                                // ======================================

                                if (_hasActiveFilters)
                                  Padding(
                                    padding:
                                        const EdgeInsets.only(
                                      bottom: 10,
                                    ),
                                    child: Text(
                                      '${state.products.length} products found',
                                      style: TextStyle(
                                        color: dark
                                            ? Colors.white70
                                            : Colors.black54,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                              ],
                            );
                          }

                          if (state is ProductsError) {
                            return Center(
                              child: Padding(
                                padding:
                                    const EdgeInsets.all(20),
                                child: Text(
                                  'خطأ في تحميل المنتجات: ${state.message}',
                                  style:
                                      const TextStyle(
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                            );
                          }

                          return const SizedBox.shrink();
                        },
                      ),

                      // ==================================================
                      // SPONSORED
                      // ==================================================

                      Text(
                        'Sponsored',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: dark
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),

                      const SizedBox(height: 12),

                      ClipRRect(
                        borderRadius:
                            BorderRadius.circular(12),
                        child: Image.asset(
                          'assets/images/banners/banner_3.jpg',
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// SORT OPTION
// ============================================================

class _SortOption extends StatelessWidget {
  final String title;
  final IconData icon;
  final String value;
  final String selectedValue;
  final VoidCallback onTap;

  const _SortOption({
    required this.title,
    required this.icon,
    required this.value,
    required this.selectedValue,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final selected = value == selectedValue;

    return Material(
      color: Colors.transparent,
      child: ListTile(
        onTap: onTap,
        splashColor: TColors.primary.withValues(alpha: 0.12),
        leading: Icon(
          icon,
          color: selected
              ? TColors.primary
              : Colors.grey,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: selected
                ? FontWeight.bold
                : FontWeight.normal,
          ),
        ),
        trailing: selected
            ? const Icon(
                Icons.check_circle,
                color: TColors.primary,
              )
            : null,
      ),
    );
  }
}

// ============================================================
// FILTER BOTTOM SHEET
// ============================================================

class _FilterBottomSheet extends StatefulWidget {
  final String? selectedCategoryId;
  final String? selectedBrandId;

  final double? minPrice;
  final double? maxPrice;

  final bool onlyDiscounted;

  final Function({
    String? categoryId,
    String? brandId,
    double? minPrice,
    double? maxPrice,
    bool onlyDiscounted,
  }) onApply;

  const _FilterBottomSheet({
    required this.selectedCategoryId,
    required this.selectedBrandId,
    required this.minPrice,
    required this.maxPrice,
    required this.onlyDiscounted,
    required this.onApply,
  });

  @override
  State<_FilterBottomSheet> createState() =>
      _FilterBottomSheetState();
}

class _FilterBottomSheetState
    extends State<_FilterBottomSheet> {
  String? _categoryId;
  String? _brandId;

  double? _minPrice;
  double? _maxPrice;

  bool _onlyDiscounted = false;

  double _sliderMin = 0;
  double _sliderMax = 5000;

  @override
  void initState() {
    super.initState();

    _categoryId = widget.selectedCategoryId;
    _brandId = widget.selectedBrandId;

    _minPrice = widget.minPrice;
    _maxPrice = widget.maxPrice;

    _onlyDiscounted = widget.onlyDiscounted;
  }

  // ==========================================================
  // GET PRICE
  // ==========================================================

  double _getProductPrice(dynamic product) {
    return product.salePrice ?? product.price;
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    final dark =
        Theme.of(context).brightness == Brightness.dark;

    final productsCubit =
        context.read<ProductsCubit>();

    final categoriesState =
        context.watch<CategoriesCubit>().state;

    List<dynamic> categories = [];

    if (categoriesState is CategoriesLoaded) {
      categories = categoriesState.categories
          .where((category) => category.isActive)
          .toList();
    }

    final products =
        productsCubit.state is ProductsLoaded
            ? (productsCubit.state as ProductsLoaded).products
            : <dynamic>[];

    // ==========================================================
    // BRANDS
    // ==========================================================

    final Map<String, String> brandsMap = {};

    for (final product in products) {
      if (product.brandId != null &&
          product.brandId.toString().isNotEmpty) {
        brandsMap[product.brandId.toString()] =
            product.brandName ?? 'Brand';
      }
    }

    final brands = brandsMap.entries.toList();

    // ==========================================================
    // PRICE RANGE
    // ==========================================================

    if (products.isNotEmpty) {
      double highestPrice = 0;

      for (final product in products) {
        final price = _getProductPrice(product);

        if (price > highestPrice) {
          highestPrice = price;
        }
      }

      if (highestPrice > 0) {
        _sliderMax = highestPrice.ceilToDouble();
      }
    }

    final currentMin = _minPrice ?? _sliderMin;
    final currentMax = _maxPrice ?? _sliderMax;

    return Material(
      color: dark ? TColors.darkContainer : Colors.white,
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(24),
      ),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.85,
        child: SafeArea(
          child: Column(
            children: [
              // ====================================================
              // HEADER
              // ====================================================

              Padding(
                padding: const EdgeInsets.fromLTRB(
                  20,
                  12,
                  20,
                  10,
                ),
                child: Column(
                  children: [
                    Container(
                      width: 45,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius:
                            BorderRadius.circular(10),
                      ),
                    ),

                    const SizedBox(height: 18),

                    Row(
                      children: [
                        const Icon(
                          Icons.filter_alt,
                          color: TColors.primary,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Filter Products',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: dark
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // ====================================================
              // CONTENT
              // ====================================================

              Expanded(
                child: ListView(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 20,
                  ),
                  children: [
                    const SizedBox(height: 10),

                    const Text(
                      'Category',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    DropdownButtonFormField<String?>(
                      value: _categoryId,
                      isExpanded: true,
                      decoration: InputDecoration(
                        hintText: 'All Categories',
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(12),
                        ),
                      ),
                      items: [
                        const DropdownMenuItem<String?>(
                          value: null,
                          child: Text(
                            'All Categories',
                          ),
                        ),
                        ...categories.map(
                          (category) {
                            return DropdownMenuItem<String?>(
                              value: category.id,
                              child: Text(category.name),
                            );
                          },
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _categoryId = value;
                        });
                      },
                    ),

                    // ==================================================
                    // BRAND
                    // ==================================================

                    const SizedBox(height: 24),

                    const Text(
                      'Brand',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    DropdownButtonFormField<String?>(
                      value: _brandId,
                      isExpanded: true,
                      decoration: InputDecoration(
                        hintText: 'All Brands',
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(12),
                        ),
                      ),
                      items: [
                        const DropdownMenuItem<String?>(
                          value: null,
                          child: Text('All Brands'),
                        ),
                        ...brands.map(
                          (brand) {
                            return DropdownMenuItem<String?>(
                              value: brand.key,
                              child: Text(brand.value),
                            );
                          },
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _brandId = value;
                        });
                      },
                    ),

                    // ==================================================
                    // PRICE
                    // ==================================================

                    const SizedBox(height: 24),

                    const Text(
                      'Price Range',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${currentMin.toStringAsFixed(0)} EGP',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${currentMax.toStringAsFixed(0)} EGP',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),

                    RangeSlider(
                      min: _sliderMin,
                      max: _sliderMax,
                      values: RangeValues(
                        currentMin.clamp(
                          _sliderMin,
                          _sliderMax,
                        ),
                        currentMax.clamp(
                          _sliderMin,
                          _sliderMax,
                        ),
                      ),
                      divisions:
                          _sliderMax > 0 ? 100 : null,
                      labels: RangeLabels(
                        currentMin.toStringAsFixed(0),
                        currentMax.toStringAsFixed(0),
                      ),
                      activeColor: TColors.primary,
                      onChanged: (values) {
                        setState(() {
                          _minPrice = values.start;
                          _maxPrice = values.end;
                        });
                      },
                    ),

                    // ==================================================
                    // DISCOUNT
                    // ==================================================

                    const SizedBox(height: 10),

                    Material(
                      color: Colors.transparent,
                      child: SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text(
                          'Only discounted products',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: const Text(
                          'Show products with an active discount',
                        ),
                        value: _onlyDiscounted,
                        activeColor: TColors.primary,
                        onChanged: (value) {
                          setState(() {
                            _onlyDiscounted = value;
                          });
                        },
                      ),
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),

              // ====================================================
              // BUTTONS
              // ====================================================

              Padding(
                padding: const EdgeInsets.fromLTRB(
                  20,
                  10,
                  20,
                  20,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          setState(() {
                            _categoryId = null;
                            _brandId = null;
                            _minPrice = null;
                            _maxPrice = null;
                            _onlyDiscounted = false;
                          });
                        },
                        style: OutlinedButton.styleFrom(
                          minimumSize:
                              const Size(
                            double.infinity,
                            52,
                          ),
                          side: const BorderSide(
                            color: TColors.primary,
                          ),
                        ),
                        child: const Text('Reset'),
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: () {
                          widget.onApply(
                            categoryId: _categoryId,
                            brandId: _brandId,
                            minPrice: _minPrice,
                            maxPrice: _maxPrice,
                            onlyDiscounted:
                                _onlyDiscounted,
                          );
                        },
                        style:
                            ElevatedButton.styleFrom(
                          backgroundColor:
                              TColors.primary,
                          foregroundColor:
                              Colors.white,
                          minimumSize:
                              const Size(
                            double.infinity,
                            52,
                          ),
                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Apply Filters',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// COLORED SECTION HEADER
// ============================================================

class ColoredSectionHeader
    extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color color;
  final IconData icon;
  final VoidCallback onPressed;

  const ColoredSectionHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 20,
          ),

          const SizedBox(width: 8),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          OutlinedButton(
            onPressed: onPressed,
            style: OutlinedButton.styleFrom(
              side: const BorderSide(
                color: Colors.white,
              ),
              foregroundColor: Colors.white,
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 10,
              ),
            ),
            child: const Text('View all →'),
          ),
        ],
      ),
    );
  }
}

