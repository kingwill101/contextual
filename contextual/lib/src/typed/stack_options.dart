class StackOptions {
  final List<String> channels; // names of other channels to stack
  final bool ignoreExceptions;

  const StackOptions({required this.channels, this.ignoreExceptions = false});
}
