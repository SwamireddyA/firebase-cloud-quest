import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/challenge_service.dart';
import '../services/coach_service.dart';
import '../services/reward_service.dart';

class ChallengeScreen extends StatefulWidget {
  const ChallengeScreen({super.key, required this.user});
  final User user;

  @override
  State<ChallengeScreen> createState() => _ChallengeScreenState();
}

class _ChallengeScreenState extends State<ChallengeScreen> {
  final _question = TextEditingController();
  Map<String, dynamic>? _challenge;
  Map<String, dynamic>? _progress;
  bool _loading = true;
  String? _loadError;
  bool _completing = false;
  String? _rewardMessage;
  bool _asking = false;
  String? _coachReply;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _question.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });
    try {
      final data = await loadToday();
      if (!mounted) return;
      setState(() {
        _challenge = data['challenge'] as Map<String, dynamic>?;
        _progress = data['progress'] as Map<String, dynamic>?;
      });
    } catch (e) {
      debugPrint('Load failed: $e');
      if (!mounted) return;
      setState(() => _loadError = "Could not load today's quest. Try again.");
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _complete() async {
    if (_completing) return;
    setState(() {
      _completing = true;
      _rewardMessage = null;
    });
    try {
      final r = await completeChallenge();
      if (!mounted) return;
      final already = r['alreadyCompleted'] == true;
      setState(() => _rewardMessage = already
          ? 'Already completed: ${r['points']} points and the "${r['badgeId']}" badge (no new reward).'
          : 'Quest complete! You earned ${r['points']} points and the "${r['badgeId']}" badge.');
      await _load();
    } on FirebaseFunctionsException catch (e) {
      debugPrint('Complete failed: ${e.code}');
      if (!mounted) return;
      setState(() => _rewardMessage = 'Could not complete the quest. Try again.');
    } finally {
      if (mounted) setState(() => _completing = false);
    }
  }

  Future<void> _askCoach() async {
    if (_asking) return;
    if (_question.text.trim().isEmpty) {
      setState(() => _coachReply = 'Type a question first.');
      return;
    }
    setState(() => _asking = true);
    try {
      final reply = await getQuestHint(_question.text);
      if (!mounted) return;
      setState(() => _coachReply = reply);
    } on FirebaseFunctionsException catch (e) {
      debugPrint('Quest Coach request failed: ${e.code}');
      if (!mounted) return;
      setState(() => _coachReply =
          'The coach is unavailable. Try again. (${e.code}: ${e.message})');
    } finally {
      if (mounted) setState(() => _asking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final done = _progress?['completed'] == true;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cloud Quest'),
        actions: [
          IconButton(
            tooltip: 'Sign out',
            icon: const Icon(Icons.logout),
            onPressed: logOut,
          ),
        ],
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text('Signed in as ${widget.user.email ?? widget.user.uid}'),
                  const SizedBox(height: 12),
                  if (_loadError != null) ...[
                    Text(_loadError!,
                        style: TextStyle(color: Theme.of(context).colorScheme.error)),
                    TextButton(onPressed: _load, child: const Text('Retry')),
                  ] else ...[
                    Text("Today's challenge",
                        style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 8),
                    Text('${_challenge?['title'] ?? 'No challenge found'}',
                        style: Theme.of(context).textTheme.titleMedium),
                    Text('${_challenge?['prompt'] ?? ''}'),
                    const SizedBox(height: 12),
                    Text(done
                        ? 'Progress: completed | ${_progress?['points']} points | badge: ${_progress?['badgeId']}'
                        : 'Progress: not completed yet'),
                  ],
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: _completing ? null : _complete,
                    child: Text(_completing ? 'Completing...' : 'Complete challenge'),
                  ),
                  if (_rewardMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(_rewardMessage!),
                    ),
                  const Divider(height: 32),
                  TextField(
                    controller: _question,
                    maxLength: 300,
                    decoration: const InputDecoration(
                      labelText: 'Ask the Quest Coach for a hint',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  OutlinedButton(
                    onPressed: _asking ? null : _askCoach,
                    child: Text(_asking ? 'Thinking...' : 'Get hint'),
                  ),
                  if (_coachReply != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(_coachReply!), // plain text only
                    ),
                ],
              ),
      ),
    );
  }
}
