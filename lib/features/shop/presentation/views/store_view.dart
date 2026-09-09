import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:t_store/core/utils/constants/colors.dart';
import 'package:t_store/core/utils/constants/sizes.dart';
import 'package:t_store/core/utils/helpers/helper_functions.dart';
import 'package:t_store/core/dependency_injection/service_locator.dart';
import 'package:t_store/features/shop/presentation/cubit/products_cubit.dart';
import 'package:t_store/features/shop/presentation/cubit/products_state.dart';

class StoreView extends StatelessWidget {
  const StoreView({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);

    // 🎯 أسماء الأقسام المطابقة تماماً لـ Endpoints الـ API في DummyJSON
    final List<String> categoryIds = [
      'sports-accessories', // Sports
      'furniture',          // Furniture
      'laptops',            // Electronics
      'mens-shirts',        // Clothes
      'beauty',             // Cosmetics
    ];

    return DefaultTabController(
      length: categoryIds.length,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text(
            'Store',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: dark ? TColors.white : TColors.textPrimary,
            ),
          ),
          actions: [
            IconButton(
              onPressed: () {},
              icon: Icon(
                Iconsax.shopping_cart,
                color: dark ? TColors.white : TColors.dark,
              ),
            ),
          ],
        ),
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(TSizes.defaultSpace),
                  child: Column(
                    children: [
                      // 1. شريط البحث في المتجر
                      Container(
                        padding: const EdgeInsets.all(TSizes.md),
                        decoration: BoxDecoration(
                          color: dark ? TColors.dark : TColors.light,
                          borderRadius: BorderRadius.circular(TSizes.cardRadiusLg),
                          border: Border.all(color: TColors.grey),
                        ),
                        child: const Row(
                          children: [
                            Icon(Iconsax.search_normal, color: TColors.darkGrey),
                            SizedBox(width: TSizes.spaceBtwItems),
                            Text('Search in store...', style: TextStyle(color: TColors.darkGrey)),
                          ],
                        ),
                      ),
                      const SizedBox(height: TSizes.spaceBtwSections),

                      // 2. عنوان البراندات المميزة مع زرار View All
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Featured Brands',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          TextButton(
                            onPressed: () {},
                            child: const Text('View All', style: TextStyle(color: TColors.primary)),
                          ),
                        ],
                      ),
                      const SizedBox(height: TSizes.spaceBtwItems / 1.5),

                      // 3. شبكة مصغرة لعرض البراندات (Brands Grid)
                      GridView.builder(
                        itemCount: 4,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisExtent: 80,
                          mainAxisSpacing: TSizes.spaceBtwItems / 2,
                          crossAxisSpacing: TSizes.spaceBtwItems / 2,
                        ),
                        itemBuilder: (context, index) {
                          return Container(
                            padding: const EdgeInsets.all(TSizes.sm),
                            decoration: BoxDecoration(
                              color: dark ? TColors.darkContainer : Colors.white,
                              borderRadius: BorderRadius.circular(TSizes.cardRadiusLg),
                              border: Border.all(
                                color: dark ? TColors.darkerGrey : TColors.borderPrimary,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: dark ? TColors.dark : TColors.light,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Iconsax.shop, color: TColors.primary),
                                ),
                                const SizedBox(width: TSizes.spaceBtwItems / 2),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text(
                                        'Nike',
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const Text(
                                        '256 Products',
                                        style: TextStyle(color: TColors.darkGrey, fontSize: 11),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // 4. التبويبات العلوية (TabBar) للأقسام داخل المتجر
              SliverPersistentHeader(
                pinned: true,
                delegate: _SliverAppBarDelegate(
                  TabBar(
                    isScrollable: true,
                    indicatorColor: TColors.primary,
                    labelColor: dark ? TColors.white : TColors.primary,
                    unselectedLabelColor: TColors.darkGrey,
                    tabs: const [
                      Tab(text: 'Sports'),
                      Tab(text: 'Furniture'),
                      Tab(text: 'Electronics'),
                      Tab(text: 'Clothes'),
                      Tab(text: 'Cosmetics'),
                    ],
                  ),
                  dark,
                ),
              ),
            ];
          },
          // 🌟 محتوى التبويبات الديناميكي: كل تبويب بينادي الـ Cubit ويبعت الـ categoryId الخاص بيه
          body: TabBarView(
            children: categoryIds.map((catId) => _buildCategoryTabContent(dark, catId)).toList(),
          ),
        ),
      ),
    );
  }

  // 🌟 دالة لبناء محتوى كل قسم بشكل مستقل تماماً مع جلب البيانات من الـ API
  Widget _buildCategoryTabContent(bool dark, String categoryId) {
    return BlocProvider(
      create: (context) => sl<ProductsCubit>()..getProducts(
        categoryId: categoryId,
        refresh: true,
      ),
      child: Builder(
        builder: (context) {
          return BlocBuilder<ProductsCubit, ProductsState>(
            builder: (context, state) {
              if (state is ProductsLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is ProductsError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(TSizes.defaultSpace),
                    child: Text(
                      state.message,
                      style: const TextStyle(color: Colors.red, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              } else if (state is ProductsLoaded) {
                final products = state.products;

                if (products.isEmpty) {
                  return const Center(
                    child: Text('لا توجد منتجات متاحة في هذا القسم حالياً'),
                  );
                }

                return ListView(
                  padding: const EdgeInsets.all(TSizes.defaultSpace),
                  children: [
                    const Text(
                      'You might like these',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: TSizes.spaceBtwItems),
                    GridView.builder(
                      itemCount: products.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisExtent: 230,
                        mainAxisSpacing: TSizes.spaceBtwItems,
                        crossAxisSpacing: TSizes.spaceBtwItems,
                      ),
                      itemBuilder: (context, index) {
                        final product = products[index];
                        final double displayPrice = (product.salePrice ?? 0) > 0 
                            ? product.salePrice! 
                            : product.price;

                        return Container(
                          decoration: BoxDecoration(
                            color: dark ? TColors.darkContainer : TColors.white,
                            borderRadius: BorderRadius.circular(TSizes.cardRadiusLg),
                            border: Border.all(color: dark ? TColors.darkerGrey : TColors.borderPrimary),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(TSizes.cardRadiusLg),
                                    topRight: Radius.circular(TSizes.cardRadiusLg),
                                  ),
                                  child: (product.thumbnail != null && product.thumbnail!.isNotEmpty)
                                      ? Image.network(
                                          product.thumbnail!,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) =>
                                              const Center(child: Icon(Icons.broken_image)),
                                        )
                                      : const Center(child: Icon(Iconsax.box, size: 40, color: TColors.primary)),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product.name,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '\$$displayPrice',
                                      style: const TextStyle(color: TColors.primary, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                );
              }
              return const SizedBox();
            },
          );
        },
      ),
    );
  }
}

// مساعد لتثبيت الـ TabBar فوق الـ Scroll
class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar, this._dark);

  final TabBar _tabBar;
  final bool _dark;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: _dark ? TColors.dark : TColors.white,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}