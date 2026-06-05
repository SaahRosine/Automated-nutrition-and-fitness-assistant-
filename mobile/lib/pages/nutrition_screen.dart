import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/nutrition_provider.dart';

class NutritionScreen extends StatefulWidget {
  const NutritionScreen({super.key});

  @override
  State<NutritionScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends State<NutritionScreen> {
  final TextEditingController _controller = TextEditingController();
  File? _image;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  void _analyze() {
    final provider = context.read<NutritionProvider>();
    provider.analyzeFood(
      text: _controller.text,
      image: _image,
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NutritionProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nutrition & AI Workout'),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildAnalysisSection(provider),
          const SizedBox(height: 24),
          _buildTodayLogSection(provider),
          const SizedBox(height: 24),
          _buildWorkoutSection(provider),
        ],
      ),
    );
  }

  Widget _buildAnalysisSection(NutritionProvider provider) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Log New Meal', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'What are you eating?',
                hintText: 'e.g. 2 slices of pizza',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                  image: _image != null ? DecorationImage(image: FileImage(_image!), fit: BoxFit.cover) : null,
                ),
                child: _image == null
                    ? const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.camera_alt, size: 48, color: Colors.grey),
                          Text('Tap to take photo', style: TextStyle(color: Colors.grey)),
                        ],
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 16),
            if (provider.isLoading)
              const Center(child: CircularProgressIndicator())
            else
              ElevatedButton(
                onPressed: _analyze,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Analyze with AI'),
              ),
            if (provider.lastAnalysis != null) ...[
              const SizedBox(height: 16),
              _buildAnalysisResult(provider),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisResult(NutritionProvider provider) {
    final data = provider.lastAnalysis!;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.restaurant, color: Colors.orange[800]),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  data['name'] ?? 'Analyzed Meal',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('Calories: ${data['calories']} kcal', style: const TextStyle(fontWeight: FontWeight.w600)),
          Text('Macros: ${data['protein_g']}g Protein, ${data['carbs_g']}g Carbs, ${data['fat_g']}g Fat'),
          const SizedBox(height: 12),
          Text('Verdict: ${data['verdict']}', style: const TextStyle(fontStyle: FontStyle.italic)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              provider.logMeal();
              _controller.clear();
              setState(() => _image = null);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
            child: const Text('Add to Daily Log'),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayLogSection(NutritionProvider provider) {
    if (provider.meals.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Today\'s Intake', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ...provider.meals.map((meal) => ListTile(
              leading: const Icon(Icons.check_circle, color: Colors.green),
              title: Text(meal['name']),
              subtitle: Text('${meal['calories']} kcal'),
              trailing: Text('${meal['protein_g']}g P'),
            )),
        const Divider(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('${provider.totalCalories} kcal', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWorkoutSection(NutritionProvider provider) {
    if (provider.meals.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('AI Workout Recommendation', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        if (provider.workoutPlan == null)
          ElevatedButton(
            onPressed: provider.isLoading ? null : () => provider.generateWorkout(),
            child: const Text('Generate Daily Workout Plan'),
          )
        else
          Card(
            color: Colors.blue[50],
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    provider.workoutPlan!['plan_name'] ?? 'Workout Plan',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
                  ),
                  const SizedBox(height: 8),
                  Text('Est. Burn: ${provider.workoutPlan!['estimated_calories_burned']} kcal'),
                  const Divider(),
                  _buildList('Warm-up', provider.workoutPlan!['warm_up']),
                  _buildExerciseList('Exercises', provider.workoutPlan!['main_exercises']),
                  _buildList('Cool-down', provider.workoutPlan!['cool_down']),
                  const Divider(),
                  Text('💡 Tip: ${provider.workoutPlan!['pro_tip']}', style: const TextStyle(fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildList(String title, dynamic items) {
    if (items == null || items is! List) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        ...items.map((item) => Text('• $item')),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildExerciseList(String title, dynamic items) {
    if (items == null || items is! List) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        ...items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text('• ${item['name']}: ${item['reps']} (${item['notes']})'),
            )),
        const SizedBox(height: 8),
      ],
    );
  }
}
