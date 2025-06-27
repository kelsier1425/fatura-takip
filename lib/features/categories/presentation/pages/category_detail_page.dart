import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../data/datasources/default_categories.dart';
import '../../domain/entities/category_entity.dart';
import '../../../../core/constants/app_colors.dart';

class CategoryDetailPage extends StatelessWidget {
  final String categoryId;
  
  const CategoryDetailPage({
    Key? key,
    required this.categoryId,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Kategoriyi bul
    final allCategories = [
      ...DefaultCategories.getDefaultCategories(),
      ...DefaultCategories.getDefaultSubcategories(),
      ...DefaultCategories.getDefaultSubSubcategories(),
    ];
    
    final category = allCategories.firstWhere(
      (c) => c.id == categoryId,
      orElse: () => CategoryEntity(
        id: 'not_found',
        name: 'Kategori Bulunamadı',
        type: CategoryType.personal,
        color: Colors.grey,
        icon: Icons.error_outline,
        createdAt: DateTime.now(),
      ),
    );
    
    // Alt kategorileri bul
    List<CategoryEntity> subcategories = [];
    
    if (category.isMainCategory) {
      // Ana kategoriyse alt kategorileri getir
      subcategories = DefaultCategories.getDefaultSubcategories()
          .where((sub) => sub.parentId == categoryId)
          .toList();
    } else if (category.isSubcategory) {
      // Alt kategoriyse alt-alt kategorileri getir
      subcategories = DefaultCategories.getDefaultSubSubcategories()
          .where((subsub) => subsub.subParentId == categoryId)
          .toList();
    }
    
    return Scaffold(
      appBar: AppBar(
        title: Text(category.name),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/categories'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Düzenleme özelliği yakında gelecek!')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    category.color.withOpacity(0.1),
                    category.color.withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: category.color.withOpacity(0.3),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: category.color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      category.icon,
                      size: 40,
                      color: category.color,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    category.name,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: category.color,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (category.description != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      category.description!,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.textTheme.bodyLarge?.color?.withOpacity(0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  if (category.isPremium) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Text(
                        'PREMIUM ÖZELLİK',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Statistics
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    theme: theme,
                    title: 'Harcama Sayısı',
                    value: '0',
                    icon: Icons.receipt_outlined,
                    color: category.color,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    theme: theme,
                    title: 'Toplam Tutar',
                    value: '₺0',
                    icon: Icons.account_balance_wallet_outlined,
                    color: category.color,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Subcategories
            if (subcategories.isNotEmpty) ...[
              Text(
                category.isMainCategory 
                    ? 'Alt Kategoriler (${subcategories.length})'
                    : 'Detay Kategoriler (${subcategories.length})',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: subcategories.length,
                itemBuilder: (context, index) {
                  final sub = subcategories[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: sub.color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          sub.icon,
                          color: sub.color,
                          size: 20,
                        ),
                      ),
                      title: Text(sub.name),
                      trailing: sub.isPremium
                          ? Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.accent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'PRO',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          : const Icon(Icons.chevron_right),
                      onTap: () {
                        context.push('/category/detail/${sub.id}');
                      },
                    ),
                  );
                },
              ),
            ],
            
            const SizedBox(height: 24),
            
            // Actions
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  context.push('/expense/add?categoryId=$categoryId');
                },
                icon: const Icon(Icons.add),
                label: Text('${category.name} Harcaması Ekle'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: category.color,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatCard({
    required ThemeData theme,
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}