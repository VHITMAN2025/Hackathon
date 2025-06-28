import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class AddGroceryPage extends StatefulWidget {
  const AddGroceryPage({super.key});
  @override
  State<AddGroceryPage> createState() => _AddGroceryPageState();
}

class _AddGroceryPageState extends State<AddGroceryPage> {
  final _nameController = TextEditingController();
  final _qtyController = TextEditingController();
  File? _image;

  final List<Map<String, dynamic>> _groceries = [];

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _image = File(picked.path));
    }
  }

  void _addGrocery() {
    if (_nameController.text.isEmpty || _qtyController.text.isEmpty) return;
    _groceries.add({
      'name': _nameController.text,
      'qty': _qtyController.text,
      'image': _image,
    });
    _nameController.clear();
    _qtyController.clear();
    setState(() => _image = null);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Item added!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Text(
          'Add Grocery Item',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            height: 150,
            color: Colors.grey[200],
            child: _image != null
                ? Image.file(_image!, fit: BoxFit.cover)
                : const Center(child: Text('Tap to pick image')),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _nameController,
          decoration: const InputDecoration(labelText: 'Item Name'),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _qtyController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Quantity'),
        ),
        const SizedBox(height: 16),
      ElevatedButton(onPressed: _addGrocery, child: const Text("Add Grocery"))

