import 'package:flutter/material.dart';

import '../../../../app/auth_scope.dart';
import '../../../../app/navigation/app_routes.dart';
import '../../../../shared/theme/app_theme.dart';
import '../../../../shared/widgets/action_buttons.dart';
import '../../../../shared/widgets/authenticated_page_scaffold.dart';
import '../../../../shared/widgets/forkscore_text_field.dart';
import '../../domain/models/auth_user.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _birthDateController = TextEditingController();

  bool _didBootstrap = false;
  bool _isSyncingFields = false;
  bool _hasLocalChanges = false;
  String? _inlineMessage;
  bool _showErrorStyle = false;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_handleFieldChange);
    _emailController.addListener(_handleFieldChange);
    _birthDateController.addListener(_handleFieldChange);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didBootstrap) {
      return;
    }

    _didBootstrap = true;
    final sessionController = SessionScope.of(context, listen: false);
    _syncControllersFromUser(sessionController.currentUser);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _refreshProfile();
    });
  }

  @override
  void dispose() {
    _nameController.removeListener(_handleFieldChange);
    _emailController.removeListener(_handleFieldChange);
    _birthDateController.removeListener(_handleFieldChange);
    _nameController.dispose();
    _emailController.dispose();
    _birthDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sessionController = SessionScope.of(context);
    final currentUser = sessionController.currentUser;

    if (!_hasLocalChanges) {
      _syncControllersFromUser(currentUser);
    }

    return AuthenticatedPageScaffold(
      key: const Key('profile-page'),
      maxWidth: 960,
      showBackButton: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () => Navigator.of(
                context,
              ).pushNamedAndRemoveUntil(AppRoutes.home, (route) => false),
              icon: const Icon(Icons.arrow_back_rounded),
              label: const Text('Voltar para a home'),
            ),
          ),
          const SizedBox(height: 8),
          if (_inlineMessage != null) ...[
            _InlineFeedbackCard(
              message: _inlineMessage!,
              isError: _showErrorStyle,
            ),
            const SizedBox(height: 16),
          ],
          _ProfileFormCard(
            nameController: _nameController,
            emailController: _emailController,
            birthDateController: _birthDateController,
            isBusy: sessionController.isBusy,
            onChanged: _handleFieldChange,
            onSave: _saveProfile,
            onRefresh: _refreshProfile,
          ),
        ],
      ),
    );
  }

  Future<void> _refreshProfile() async {
    final sessionController = SessionScope.of(context, listen: false);
    setState(() {
      _inlineMessage = null;
      _showErrorStyle = false;
    });

    await sessionController.refreshProfile();

    if (!mounted) {
      return;
    }

    if (sessionController.errorMessage != null) {
      setState(() {
        _inlineMessage =
            sessionController.errorMessage ??
            'Nao foi possivel atualizar o perfil.';
        _showErrorStyle = true;
      });
      return;
    }

    if (!_hasLocalChanges) {
      _syncControllersFromUser(sessionController.currentUser);
    }
  }

  Future<void> _saveProfile() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final birthDateText = _birthDateController.text.trim();

    if (name.isEmpty || email.isEmpty) {
      setState(() {
        _inlineMessage = 'Nome e email sao obrigatorios para salvar o perfil.';
        _showErrorStyle = true;
      });
      return;
    }

    final birthDate = _parseBirthDate(birthDateText);
    if (birthDateText.isNotEmpty && birthDate == null) {
      setState(() {
        _inlineMessage = 'Use o formato AAAA-MM-DD para a data de nascimento.';
        _showErrorStyle = true;
      });
      return;
    }

    final sessionController = SessionScope.of(context, listen: false);
    setState(() {
      _inlineMessage = null;
      _showErrorStyle = false;
    });

    await sessionController.updateProfile(
      name: name,
      email: email,
      birthDate: birthDate,
    );

    if (!mounted) {
      return;
    }

    if (sessionController.errorMessage != null) {
      setState(() {
        _inlineMessage =
            sessionController.errorMessage ??
            'Nao foi possivel salvar o perfil.';
        _showErrorStyle = true;
      });
      return;
    }

    _hasLocalChanges = false;
    _syncControllersFromUser(sessionController.currentUser);
    setState(() {
      _inlineMessage = 'Perfil atualizado com sucesso.';
      _showErrorStyle = false;
    });
  }

  void _handleFieldChange() {
    if (_isSyncingFields) {
      return;
    }

    if (_hasLocalChanges) {
      return;
    }

    setState(() => _hasLocalChanges = true);
  }

  void _syncControllersFromUser(AuthUser? user) {
    _isSyncingFields = true;
    _nameController.text = user?.name ?? '';
    _emailController.text = user?.email ?? '';
    _birthDateController.text = user?.birthDate == null
        ? ''
        : _formatDate(user!.birthDate!);
    _isSyncingFields = false;
  }

  DateTime? _parseBirthDate(String value) {
    if (value.isEmpty) {
      return null;
    }

    final match = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(value);
    if (match == null) {
      return null;
    }

    final year = int.parse(match.group(1)!);
    final month = int.parse(match.group(2)!);
    final day = int.parse(match.group(3)!);

    try {
      final parsed = DateTime(year, month, day);
      if (parsed.year != year || parsed.month != month || parsed.day != day) {
        return null;
      }
      return parsed;
    } catch (_) {
      return null;
    }
  }

  String _formatDate(DateTime value) {
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '${value.year}-$month-$day';
  }
}

class _ProfileFormCard extends StatelessWidget {
  const _ProfileFormCard({
    required this.nameController,
    required this.emailController,
    required this.birthDateController,
    required this.isBusy,
    required this.onChanged,
    required this.onSave,
    required this.onRefresh,
  });

  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController birthDateController;
  final bool isBusy;
  final VoidCallback onChanged;
  final Future<void> Function() onSave;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final fields = _buildFields();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.inputBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Dados do perfil',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 6),
          Text(
            'Atualize seus dados basicos quando precisar.',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 24),
          LayoutBuilder(
            builder: (context, constraints) {
              final useWideLayout = constraints.maxWidth >= 760;

              if (!useWideLayout) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: fields,
                );
              }

              return Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: fields[0]),
                      const SizedBox(width: 16),
                      Expanded(child: fields[1]),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: fields[2]),
                      const SizedBox(width: 16),
                      Expanded(child: fields[3]),
                    ],
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: SecondaryActionButton(
                  key: const Key('profile-refresh-button'),
                  label: isBusy ? 'Atualizando...' : 'Recarregar perfil',
                  onPressed: isBusy ? null : () => onRefresh(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: PrimaryActionButton(
                  key: const Key('profile-save-button'),
                  label: isBusy ? 'Salvando...' : 'Salvar alteracoes',
                  onPressed: isBusy ? null : () => onSave(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _buildFields() {
    return [
      ForkScoreTextField(
        key: const Key('profile-name-field'),
        controller: nameController,
        label: 'Nome',
        hintText: 'Como voce quer aparecer no app',
        prefixIcon: const Icon(Icons.person_outline_rounded, size: 20),
      ),
      ForkScoreTextField(
        key: const Key('profile-email-field'),
        controller: emailController,
        label: 'Email',
        hintText: 'seu@email.com',
        keyboardType: TextInputType.emailAddress,
        prefixIcon: const Icon(Icons.email_outlined, size: 20),
      ),
      ForkScoreTextField(
        key: const Key('profile-birth-date-field'),
        controller: birthDateController,
        label: 'Data de nascimento',
        hintText: 'AAAA-MM-DD',
        keyboardType: TextInputType.datetime,
        prefixIcon: const Icon(Icons.cake_outlined, size: 20),
      ),
    ];
  }
}

class _InlineFeedbackCard extends StatelessWidget {
  const _InlineFeedbackCard({required this.message, required this.isError});

  final String message;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isError
        ? const Color(0xFFFFF1EE)
        : const Color(0xFFF1F6EF);
    final borderColor = isError
        ? const Color(0xFFF0C5BB)
        : const Color(0xFFC9DEC3);
    final iconColor = isError
        ? const Color(0xFF8D3F2B)
        : const Color(0xFF47623E);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Icon(
            isError ? Icons.error_outline_rounded : Icons.check_circle_outline,
            color: iconColor,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppTheme.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}
