import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auto_route/auto_route.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wortspion/blocs/game/game_bloc.dart';
import 'package:wortspion/blocs/game/game_event.dart';
import 'package:wortspion/blocs/game/game_state.dart';
import 'package:wortspion/data/models/category.dart';
import 'package:wortspion/data/repositories/word_repository.dart';
import 'package:wortspion/di/injection_container.dart';
import 'package:wortspion/presentation/themes/app_colors.dart';
import 'package:wortspion/presentation/themes/app_spacing.dart';
import 'package:wortspion/presentation/themes/app_typography.dart';
import 'package:wortspion/presentation/widgets/app_button.dart';

@RoutePage()
class CategorySelectionScreen extends StatefulWidget {
  final int playerCount;
  final int impostorCount;
  final int saboteurCount; // 🆕 NEW: Add saboteur count parameter
  final int roundCount;
  final int timerDuration;
  final bool impostorsKnowEachOther;
  final List<String>? groupPlayerNames;

  const CategorySelectionScreen({
    super.key,
    required this.playerCount,
    required this.impostorCount,
    this.saboteurCount = 0, // 🆕 NEW: Default to 0 for backward compatibility
    required this.roundCount,
    required this.timerDuration,
    required this.impostorsKnowEachOther,
    this.groupPlayerNames,
  });

  @override
  State<CategorySelectionScreen> createState() => _CategorySelectionScreenState();
}

class _CategorySelectionScreenState extends State<CategorySelectionScreen> {
  final WordRepository _wordRepository = sl<WordRepository>();
  List<Category> _categories = [];
  Set<String> _selectedCategoryIds = {};
  bool _isLoading = true;
  String? _errorMessage;

  // SharedPreferences keys
  static const String _selectedCategoriesKey = 'selected_category_ids';
  static const String _favoriteCategoriesKey = 'favorite_category_ids';
  
  Set<String> _favoriteCategoryIds = {}; // NEW: Track user's favorite categories

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await _wordRepository.getAllCategories();

      setState(() {
        _categories = categories;
        _isLoading = false;
      });

      // Load saved category selection or use defaults
      await _loadSavedCategorySelection();
    } catch (e) {
      setState(() {
        _errorMessage = 'Fehler beim Laden der Kategorien: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadSavedCategorySelection() async {
  try {
  final prefs = await SharedPreferences.getInstance();
  
  // Load saved selection
  final savedCategories = prefs.getStringList(_selectedCategoriesKey);
  
  // Load favorite categories
  final favoriteCategories = prefs.getStringList(_favoriteCategoriesKey);
  
  if (savedCategories != null && savedCategories.isNotEmpty) {
    // Use saved selection
  setState(() {
    _selectedCategoryIds = savedCategories.toSet();
  });
  print('Loaded saved categories: $savedCategories');
  } else {
  // Use default categories if no saved selection
    final defaultCategories = await _wordRepository.getDefaultCategories();
      setState(() {
      _selectedCategoryIds = defaultCategories.map((c) => c.id).toSet();
    });
    print('Using default categories: ${_selectedCategoryIds.toList()}');
  }
  
  // Load favorites (or use defaults if none set)
    if (favoriteCategories != null && favoriteCategories.isNotEmpty) {
        setState(() {
          _favoriteCategoryIds = favoriteCategories.toSet();
        });
        print('Loaded favorite categories: $favoriteCategories');
      } else {
        // If no favorites set, use default categories as initial favorites
        final defaultCategories = await _wordRepository.getDefaultCategories();
        final defaultIds = defaultCategories.map((c) => c.id).toSet();
        setState(() {
          _favoriteCategoryIds = defaultIds;
        });
        // Save these as initial favorites
        await prefs.setStringList(_favoriteCategoriesKey, defaultIds.toList());
        print('Set initial favorites from defaults: ${defaultIds.toList()}');
      }
    } catch (e) {
      print('Error loading saved categories: $e');
      // Fallback to default categories
      final defaultCategories = await _wordRepository.getDefaultCategories();
      setState(() {
        _selectedCategoryIds = defaultCategories.map((c) => c.id).toSet();
        _favoriteCategoryIds = defaultCategories.map((c) => c.id).toSet();
      });
    }
  }

  Future<void> _saveCategorySelection() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_selectedCategoriesKey, _selectedCategoryIds.toList());
      print('Saved categories: ${_selectedCategoryIds.toList()}');
    } catch (e) {
      print('Error saving categories: $e');
    }
  }

  void _toggleCategory(String categoryId) {
    setState(() {
      if (_selectedCategoryIds.contains(categoryId)) {
        // Don't allow deselecting if it's the last selected category
        if (_selectedCategoryIds.length > 1) {
          _selectedCategoryIds.remove(categoryId);
        }
      } else {
        _selectedCategoryIds.add(categoryId);
      }
    });
    // Save selection whenever it changes
    _saveCategorySelection();
  }

  void _selectAllCategories() {
    setState(() {
      _selectedCategoryIds = _categories.map((c) => c.id).toSet();
    });
    _saveCategorySelection();
  }

  void _selectDefaultCategories() {
    setState(() {
      _selectedCategoryIds = _categories.where((c) => c.isDefault).map((c) => c.id).toSet();
    });
    _saveCategorySelection();
  }

  void _startGame() {
    if (_selectedCategoryIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bitte wähle mindestens eine Kategorie aus'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (widget.groupPlayerNames != null) {
      // Create game from group with selected categories
      context.read<GameBloc>().add(
            CreateGameFromGroupWithCategories(
              playerNames: widget.groupPlayerNames!,
              selectedCategoryIds: _selectedCategoryIds.toList(),
              impostorCount: widget.impostorCount,
              saboteurCount: widget.saboteurCount, // 🆕 NEW: Pass saboteur count
              roundCount: widget.roundCount,
              timerDuration: widget.timerDuration,
              impostorsKnowEachOther: widget.impostorsKnowEachOther,
            ),
          );
    } else {
      // Create regular game with selected categories
      context.read<GameBloc>().add(
            CreateGameWithCategories(
              playerCount: widget.playerCount,
              impostorCount: widget.impostorCount,
              saboteurCount: widget.saboteurCount, // 🆕 NEW: Pass saboteur count
              roundCount: widget.roundCount,
              timerDuration: widget.timerDuration,
              impostorsKnowEachOther: widget.impostorsKnowEachOther,
              selectedCategoryIds: _selectedCategoryIds.toList(),
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kategorien auswählen'),
        elevation: 2,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? _buildErrorView()
              : _buildCategorySelection(),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.m),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: AppSpacing.m),
            Text(
              _errorMessage!,
              style: AppTypography.body1,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.m),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _errorMessage = null;
                });
                _loadCategories();
              },
              child: const Text('Erneut versuchen'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Compact Header
        Container(
          padding: const EdgeInsets.all(AppSpacing.m),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            border: Border(
              bottom: BorderSide(
                color: Colors.grey.shade200,
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Kategorien wählen',
                      style: AppTypography.headline3.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_selectedCategoryIds.length} ${_selectedCategoryIds.length == 1 ? 'Kategorie' : 'Kategorien'} ausgewählt',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              // Quick action buttons
              Row(
                children: [
                  OutlinedButton(
                    onPressed: _selectDefaultCategories,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      minimumSize: Size.zero,
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.star_outline, size: 16),
                        SizedBox(width: 4),
                        Text('Standard'),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  OutlinedButton(
                    onPressed: _selectAllCategories,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      minimumSize: Size.zero,
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.select_all, size: 16),
                        SizedBox(width: 4),
                        Text('Alle'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Categories list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.m),
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final category = _categories[index];
              final isSelected = _selectedCategoryIds.contains(category.id);
              final isLastSelected = _selectedCategoryIds.length == 1 && isSelected;

              return Card(
                margin: const EdgeInsets.only(bottom: AppSpacing.xs),
                elevation: isSelected ? 4 : 1,
                color: isSelected ? AppColors.primary.withOpacity(0.1) : null,
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.m,
                    vertical: AppSpacing.xs,
                  ),
                  leading: CircleAvatar(
                    backgroundColor: isSelected ? AppColors.primary : Colors.grey.shade300,
                    child: Icon(
                      isSelected ? Icons.check : Icons.category,
                      color: isSelected ? Colors.white : Colors.grey[600],
                      size: 20,
                    ),
                  ),
                  title: Row(
                    children: [
                      Text(
                        category.name,
                        style: AppTypography.body1.copyWith(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? AppColors.primary : null,
                        ),
                      ),
                      if (category.isDefault) ...[
                        const SizedBox(width: AppSpacing.xs),
                        Icon(
                          Icons.star,
                          size: 16,
                          color: Colors.amber[600],
                        ),
                      ],
                    ],
                  ),
                  subtitle: category.description != null
                      ? Text(
                          category.description!,
                          style: AppTypography.caption.copyWith(
                            color: isSelected ? AppColors.primary.withOpacity(0.8) : Colors.grey[600],
                          ),
                        )
                      : null,
                  trailing: isLastSelected
                      ? Tooltip(
                          message: 'Mindestens eine Kategorie muss ausgewählt sein',
                          child: Icon(
                            Icons.lock,
                            color: Colors.grey[400],
                            size: 20,
                          ),
                        )
                      : null,
                  onTap: isLastSelected ? null : () => _toggleCategory(category.id),
                ),
              );
            },
          ),
        ),

        // Start game button
        Padding(
          padding: const EdgeInsets.all(AppSpacing.m),
          child: BlocBuilder<GameBloc, GameState>(
            builder: (context, state) {
              return AppButton(
                text: widget.groupPlayerNames != null ? 'Spiel mit Gruppe starten' : 'Spiel starten',
                isLoading: state is GameLoading,
                onPressed: state is GameLoading ? null : _startGame,
              );
            },
          ),
        ),
      ],
    );
  }
}
