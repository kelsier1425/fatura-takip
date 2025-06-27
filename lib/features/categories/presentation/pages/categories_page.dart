import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/datasources/default_categories.dart';
import '../../domain/entities/category_entity.dart';
import '../widgets/category_card.dart';
import '../widgets/category_filter_chips.dart';
import '../widgets/add_category_fab.dart';
import '../../../../core/constants/app_constants.dart';

class CategoriesPage extends ConsumerStatefulWidget {
  const CategoriesPage({Key? key}) : super(key: key);

  @override
  ConsumerState<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends ConsumerState<CategoriesPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  CategoryType? _selectedFilter;
  final List<CategoryEntity> _categories = [];
  final List<CategoryEntity> _subcategories = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadCategories();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadCategories() {
    _categories.addAll(DefaultCategories.getDefaultCategories());
    _subcategories.addAll(DefaultCategories.getDefaultSubcategories());
  }

  List<CategoryEntity> get _filteredMainCategories {
    if (_selectedFilter == null) return _categories;
    return _categories.where((c) => c.type == _selectedFilter).toList();
  }

  List<CategoryEntity> get _filteredSubcategories {
    if (_selectedFilter == null) return _subcategories;
    return _subcategories.where((c) => c.type == _selectedFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kategoriler'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Ana Kategoriler'),
            Tab(text: 'Alt Kategoriler'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearchDialog(),
          ),
        ],
      ),
      floatingActionButton: const AddCategoryFab(),
      body: Column(
        children: [
          // Filter Chips
          CategoryFilterChips(
            selectedFilter: _selectedFilter,
            onFilterChanged: (filter) {
              setState(() {
                _selectedFilter = filter;
              });
            },
          ),
          const SizedBox(height: 8),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Ana Kategoriler Tab
                _buildCategoriesList(_filteredMainCategories, true),
                // Alt Kategoriler Tab
                _buildCategoriesList(_filteredSubcategories, false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesList(List<CategoryEntity> categories, bool isMainCategory) {
    if (categories.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.category_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Kategori bulunamadı',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Yeni kategori eklemek için + butonuna tıklayın',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      )
      .animate()
      .fadeIn(duration: AppConstants.mediumAnimation)
      .scale(begin: const Offset(0.8, 0.8));
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        List<CategoryEntity> subcategories = [];

        if (isMainCategory) {
          subcategories = _subcategories
              .where((sub) => sub.parentId == category.id)
              .toList();
        }

        return CategoryCard(
          category: category,
          subcategories: subcategories,
          onTap: () => _onCategoryTap(category),
          onEdit: () => _onCategoryEdit(category),
          onDelete: () => _onCategoryDelete(category),
        )
        .animate()
        .fadeIn(
          delay: Duration(milliseconds: index * 100),
          duration: AppConstants.mediumAnimation,
        )
        .slideX(
          begin: 0.2,
          end: 0,
          delay: Duration(milliseconds: index * 100),
        );
      },
    );
  }

  void _onCategoryTap(CategoryEntity category) {
    if (category.isMainCategory) {
      // Ana kategoriye tıklandığında alt kategorileri göster
      _tabController.animateTo(1);
      setState(() {
        _selectedFilter = category.type;
      });
    } else {
      // Alt kategoriye tıklandığında detay sayfasını aç
      context.push('/category/detail/${category.id}');
    }
  }

  void _onCategoryEdit(CategoryEntity category) {
    context.push('/category/edit/${category.id}');
  }

  void _onCategoryDelete(CategoryEntity category) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kategoriyi Sil'),
        content: Text(
          '${category.name} kategorisini silmek istediğinizden emin misiniz? '
          'Bu işlem geri alınamaz.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteCategory(category);
            },
            child: const Text(
              'Sil',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _deleteCategory(CategoryEntity category) {
    setState(() {
      if (category.isMainCategory) {
        _categories.removeWhere((c) => c.id == category.id);
        // Alt kategorileri de sil
        _subcategories.removeWhere((c) => c.parentId == category.id);
      } else {
        _subcategories.removeWhere((c) => c.id == category.id);
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${category.name} kategorisi silindi'),
        action: SnackBarAction(
          label: 'Geri Al',
          onPressed: () {
            // TODO: Implement undo functionality
          },
        ),
      ),
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kategori Ara'),
        content: TextField(
          decoration: const InputDecoration(
            hintText: 'Kategori adı girin...',
            prefixIcon: Icon(Icons.search),
          ),
          onChanged: (value) {
            // TODO: Implement search functionality
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
        ],
      ),
    );
  }
}