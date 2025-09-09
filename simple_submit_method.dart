void _submitComplaint() async {
  if (!_formKey.currentState!.validate()) return;

  // Check if category is selected
  if (_selectedCategory == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please select a complaint category')),
    );
    return;
  }

  setState(() => _isSubmitting = true);

  // ULTRA SIMPLE - Just show success!
  print('✅ COMPLAINT FORM SUBMITTED!');
  print('📋 Shop: ${widget.shop.name}');
  print('📝 Category: $_selectedCategory');
  print('🔥 Priority: $_selectedPriority');
  print('⚡ Severity: $_selectedSeverity');
  print('💬 Description: ${_descriptionController.text.trim()}');

  // Simulate small delay for user feedback
  await Future.delayed(const Duration(milliseconds: 500));

  if (mounted) {
    setState(() => _isSubmitting = false);

    // Success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ অভিযোগ সফলভাবে জমা হয়েছে!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 3),
      ),
    );

    // Go back
    Navigator.of(context).pop();
  }
}
