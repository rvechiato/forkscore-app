import 'package:flutter/material.dart';

import '../../../../app/auth_scope.dart';
import '../../../../shared/theme/app_theme.dart';
import '../../../../shared/widgets/authenticated_page_scaffold.dart';
import '../controllers/places_controller.dart';

class PlaceCreatePage extends StatefulWidget {
  const PlaceCreatePage({super.key, required this.controller});

  final PlacesController controller;

  @override
  State<PlaceCreatePage> createState() => _PlaceCreatePageState();
}

class _PlaceCreatePageState extends State<PlaceCreatePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _streetController = TextEditingController();
  final _numberController = TextEditingController();
  final _neighborhoodController = TextEditingController();
  final _cityController = TextEditingController();
  String? _selectedCategoryId;
  String? _selectedSubcategoryId;

  @override
  void initState() {
    super.initState();
    if (widget.controller.categories.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          widget.controller.loadCategories();
        }
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _streetController.dispose();
    _numberController.dispose();
    _neighborhoodController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUserName =
        SessionScope.of(context).currentUser?.name ?? 'Gastronomo';

    return AuthenticatedPageScaffold(
      maxWidth: 760,
      showBackButton: true,
      child: ListenableBuilder(
        listenable: widget.controller,
        builder: (context, _) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.inputBorder),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x06000000),
                  blurRadius: 20,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Form(
                key: _formKey,
                child: Column(
                  key: const Key('place-create-page'),
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryBrand.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Novo Estabelecimento',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.primaryBrand,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Cadastrar estabelecimento',
                      style: Theme.of(
                        context,
                      ).textTheme.headlineLarge?.copyWith(fontSize: 32),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Cadastre um novo lugar para seguir com a avaliacao.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        border: Border.all(color: AppTheme.inputBorder),
                      ),
                      child: Text(
                        'Autoria atual: $currentUserName',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      key: const Key('create-place-name-field'),
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Nome'),
                      validator: _requiredValidator,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      key: const Key('create-place-street-field'),
                      controller: _streetController,
                      decoration: const InputDecoration(labelText: 'Rua'),
                      validator: _requiredValidator,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            key: const Key('create-place-number-field'),
                            controller: _numberController,
                            decoration: const InputDecoration(
                              labelText: 'Numero',
                            ),
                            validator: _requiredValidator,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            key: const Key('create-place-neighborhood-field'),
                            controller: _neighborhoodController,
                            decoration: const InputDecoration(
                              labelText: 'Bairro',
                            ),
                            validator: _requiredValidator,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      key: const Key('create-place-city-field'),
                      controller: _cityController,
                      decoration: const InputDecoration(labelText: 'Cidade'),
                      validator: _requiredValidator,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      key: ValueKey(
                        'create-place-category-field-${_selectedCategoryId ?? 'empty'}',
                      ),
                      initialValue: _selectedCategoryId,
                      decoration: const InputDecoration(labelText: 'Categoria'),
                      items: widget.controller.categories
                          .map(
                            (category) => DropdownMenuItem<String>(
                              value: category.id,
                              child: Text(category.name),
                            ),
                          )
                          .toList(growable: false),
                      onChanged: widget.controller.isLoadingTaxonomy
                          ? null
                          : (value) async {
                              setState(() {
                                _selectedCategoryId = value;
                                _selectedSubcategoryId = null;
                              });
                              widget.controller.clearSubcategories();
                              if (value != null) {
                                await widget.controller.loadSubcategories(
                                  value,
                                );
                              }
                            },
                      validator: _requiredSelectionValidator,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      key: ValueKey(
                        'create-place-subcategory-field-${_selectedSubcategoryId ?? 'empty'}',
                      ),
                      initialValue: _selectedSubcategoryId,
                      decoration: const InputDecoration(
                        labelText: 'Subcategoria',
                      ),
                      items: widget.controller.subcategories
                          .map(
                            (subcategory) => DropdownMenuItem<String>(
                              value: subcategory.id,
                              child: Text(subcategory.name),
                            ),
                          )
                          .toList(growable: false),
                      onChanged:
                          _selectedCategoryId == null ||
                              widget.controller.isLoadingTaxonomy
                          ? null
                          : (value) {
                              setState(() => _selectedSubcategoryId = value);
                            },
                      validator: _requiredSelectionValidator,
                    ),
                    const SizedBox(height: 20),
                    if (widget.controller.errorMessage != null) ...[
                      Text(
                        widget.controller.errorMessage!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.redAccent,
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: widget.controller.isSaving
                                ? null
                                : () => Navigator.of(context).pop(false),
                            child: const Text('Cancelar'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton(
                            key: const Key('submit-new-establishment'),
                            onPressed: widget.controller.isSaving
                                ? null
                                : _submit,
                            child: Text(
                              widget.controller.isSaving
                                  ? 'Salvando...'
                                  : 'Salvar local',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _submit() async {
    widget.controller.clearError();
    if (!_formKey.currentState!.validate()) {
      return;
    }

    await widget.controller.createPlace(
      name: _nameController.text.trim(),
      street: _streetController.text.trim(),
      number: _numberController.text.trim(),
      neighborhood: _neighborhoodController.text.trim(),
      city: _cityController.text.trim(),
      categoryId: _selectedCategoryId!,
      subcategoryId: _selectedSubcategoryId!,
    );

    if (!mounted || widget.controller.errorMessage != null) {
      return;
    }

    Navigator.of(context).pop(true);
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Campo obrigatorio.';
    }
    return null;
  }

  String? _requiredSelectionValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Campo obrigatorio.';
    }
    return null;
  }
}
