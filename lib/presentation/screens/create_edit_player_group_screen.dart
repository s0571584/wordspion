import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wortspion/blocs/player_group/player_group_bloc.dart';
import 'package:wortspion/blocs/player_group/player_group_event.dart';
import 'package:wortspion/blocs/player_group/player_group_state.dart';
import 'package:wortspion/data/models/player_group.dart';
import 'package:wortspion/data/repositories/player_group_repository.dart';
import 'package:wortspion/di/injection_container.dart';
import 'package:wortspion/presentation/themes/app_typography.dart';

@RoutePage()
class CreateEditPlayerGroupScreen extends StatefulWidget {
  final String? groupId; // Null if creating, non-null if editing

  const CreateEditPlayerGroupScreen({super.key, @QueryParam('groupId') this.groupId});

  @override
  State<CreateEditPlayerGroupScreen> createState() => _CreateEditPlayerGroupScreenState();
}

class _CreateEditPlayerGroupScreenState extends State<CreateEditPlayerGroupScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _groupNameController;
  final List<TextEditingController> _playerNameControllers = [];
  final int _minPlayers = 3; // Minimum players for a group
  bool _isLoading = false;
  PlayerGroup? _existingGroup;
  late PlayerGroupBloc _playerGroupBloc;

  bool get _isEditing => widget.groupId != null;

  @override
  void initState() {
    super.initState();
    _groupNameController = TextEditingController();
    _playerGroupBloc = sl<PlayerGroupBloc>();

    // Initialize with min player fields for new group
    if (!_isEditing) {
      for (int i = 0; i < _minPlayers; i++) {
        _playerNameControllers.add(TextEditingController());
      }
    } else {
      _loadExistingGroupData();
    }
  }

  Future<void> _loadExistingGroupData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get all groups from repository and find the one we need
      final groups = await sl<PlayerGroupRepository>().getAllPlayerGroups();

      if (!mounted) return;

      final group = groups.firstWhere(
        (g) => g.id == widget.groupId,
        orElse: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Gruppe nicht gefunden')),
          );
          context.router.pop();
          throw Exception('Group not found');
        },
      );

      _existingGroup = group;

      // Clear any existing controllers
      for (var controller in _playerNameControllers) {
        controller.dispose();
      }
      _playerNameControllers.clear();

      // Set the group name
      _groupNameController.text = group.groupName;

      // Add controllers for existing player names
      for (var name in group.playerNames) {
        _playerNameControllers.add(TextEditingController(text: name));
      }

      // Ensure we have at least the minimum number of player fields
      while (_playerNameControllers.length < _minPlayers) {
        _playerNameControllers.add(TextEditingController());
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        // Only show error if we're still mounted and it's not the 'Group not found' exception we already handled
        if (e.toString() != 'Exception: Group not found') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Fehler beim Laden der Gruppe: ${e.toString()}')),
          );
        }

        // Initialize empty fields as fallback if we're still on the screen
        if (_playerNameControllers.isEmpty) {
          for (int i = 0; i < _minPlayers; i++) {
            _playerNameControllers.add(TextEditingController());
          }
        }
      }
    }
  }

  @override
  void dispose() {
    _groupNameController.dispose();
    for (var controller in _playerNameControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addPlayerField() {
    setState(() {
      _playerNameControllers.add(TextEditingController());
    });
  }

  void _removePlayerField(int index) {
    if (_playerNameControllers.length > _minPlayers) {
      setState(() {
        final controller = _playerNameControllers.removeAt(index);
        controller.dispose();
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final groupName = _groupNameController.text.trim();
      final playerNames = _playerNameControllers.map((controller) => controller.text.trim()).where((name) => name.isNotEmpty).toList();

      if (playerNames.length < _minPlayers) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Eine Gruppe muss mindestens $_minPlayers Spieler haben.')),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      if (_isEditing && widget.groupId != null) {
        _playerGroupBloc.add(UpdatePlayerGroup(
          groupId: widget.groupId!,
          newGroupName: groupName,
          newPlayerNames: playerNames,
        ));
      } else {
        _playerGroupBloc.add(AddPlayerGroup(
          groupName: groupName,
          playerNames: playerNames,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _playerGroupBloc,
      child: BlocListener<PlayerGroupBloc, PlayerGroupState>(
        listener: (context, state) {
          if (state is PlayerGroupOperationSuccess) {
            setState(() {
              _isLoading = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Gruppe ${(_isEditing ? "aktualisiert" : "erstellt")}.')),
            );
            context.router.pop(); // Go back to previous screen
          }
          if (state is PlayerGroupError) {
            setState(() {
              _isLoading = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Fehler: ${state.message}')),
            );
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(_isEditing ? 'Gruppe bearbeiten' : 'Neue Gruppe erstellen'),
          ),
          body: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          controller: _groupNameController,
                          decoration: const InputDecoration(
                            labelText: 'Gruppenname',
                            hintText: 'z.B. Familienabend, Spielegruppe, ...',
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Bitte gib einen Gruppennamen ein.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Spieler (${_playerNameControllers.length})', style: AppTypography.subtitle1),
                            TextButton.icon(
                              icon: const Icon(Icons.add, size: 16),
                              label: const Text('Spieler hinzufügen'),
                              onPressed: _addPlayerField,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: ListView.builder(
                            itemCount: _playerNameControllers.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        controller: _playerNameControllers[index],
                                        decoration: InputDecoration(
                                          labelText: 'Spieler ${index + 1}',
                                          hintText: 'Name eingeben',
                                          suffixIcon: _playerNameControllers.length > _minPlayers
                                              ? IconButton(
                                                  icon: const Icon(Icons.remove_circle_outline, size: 20),
                                                  onPressed: () => _removePlayerField(index),
                                                )
                                              : null,
                                        ),
                                        validator: (value) {
                                          if (value == null || value.trim().isEmpty) {
                                            return 'Name darf nicht leer sein.';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _submitForm,
                            child: Text(_isEditing ? 'Änderungen speichern' : 'Gruppe erstellen'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
