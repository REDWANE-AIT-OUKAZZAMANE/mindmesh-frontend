TextButton(
  onPressed: () {
    Navigator.of(context).pushNamed('/debug');
  },
  child: const Text(
    'Network Diagnostics',
    style: TextStyle(
      color: Colors.blue,
      fontWeight: FontWeight.w600,
    ),
  ),
), 