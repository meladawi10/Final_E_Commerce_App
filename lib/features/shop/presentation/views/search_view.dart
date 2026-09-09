import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:t_store/core/utils/constants/colors.dart';
import 'package:t_store/core/utils/constants/sizes.dart';

class SearchView extends StatefulWidget {
  const SearchView({super.key});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final TextEditingController _searchController = TextEditingController();
  List<String> _searchResults = [];
  
  final List<String> _allProducts = [
    'Nike Air Jordan',
    'Nike Sports Shoe',
    'Adidas Running Shoes',
    'Puma Tracksuit',
    'Leather Jacket',
    'iPhone 15 Pro Max',
    'Samsung Galaxy S24',
    'Apple Watch Series 9',
    'Wireless Gaming Mouse',
    'Mechanical Keyboard',
  ];

  void _filterProducts(String query) {
    setState(() {
      if (query.isEmpty) {
        _searchResults = [];
      } else {
        _searchResults = _allProducts
            .where((product) => product.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              onChanged: _filterProducts,
              decoration: InputDecoration(
                hintText: 'Search in store...',
                prefixIcon: const Icon(Iconsax.search_normal),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _filterProducts('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(TSizes.cardRadiusLg),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: dark ? TColors.darkContainer : Colors.grey[200],
              ),
            ),
            const SizedBox(height: TSizes.spaceBtwSections),
            Expanded(
              child: _searchResults.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Iconsax.search_status, size: 80, color: dark ? TColors.darkGrey : Colors.grey),
                          const SizedBox(height: TSizes.spaceBtwItems),
                          Text(
                            _searchController.text.isEmpty
                                ? 'Type something to search...'
                                : 'No results found!',
                            style: TextStyle(
                              color: dark ? TColors.darkGrey : Colors.grey,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _searchResults.length,
                      itemBuilder: (context, index) {
                        return Card(
                          color: dark ? TColors.darkContainer : Colors.white,
                          margin: const EdgeInsets.only(bottom: TSizes.spaceBtwItems / 2),
                          child: ListTile(
                            leading: const Icon(Iconsax.shopping_bag, color: TColors.primary),
                            title: Text(
                              _searchResults[index],
                              style: TextStyle(
                                color: dark ? Colors.white : Colors.black,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                            onTap: () {},
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}