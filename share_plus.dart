class ShareHelper {
  static void shareTaskSummary(List<String> taskTitles) {
    final message = taskTitles.isEmpty
        ? 'No tasks available.'
        : 'Task Summary:\n${taskTitles.map((e) => '- $e').join('\n')}';
    // Share.share(message);
  }
}
