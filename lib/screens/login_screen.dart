import 'package:flutter/material.dart';
import '../models/user.dart';

class LoginScreen extends StatefulWidget {
  final Function(User) onLogin;

  const LoginScreen({super.key, required this.onLogin});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController nameController = TextEditingController();
  int? selectedGrade;
  bool isLoading = false;

  final List<Map<String, dynamic>> grades = [
    {'grade': 2, 'color': Colors.red, 'icon': Icons.traffic, 'description': 'Learn Traffic Lights'},
    {'grade': 3, 'color': Colors.orange, 'icon': Icons.traffic, 'description': 'Traffic Lights & Basic Signs'},
    {'grade': 4, 'color': Colors.yellow.shade700, 'icon': Icons.sign_language, 'description': 'Road Signs & Symbols'},
    {'grade': 5, 'color': Colors.green, 'icon': Icons.directions_walk, 'description': 'Walking & Crossing Safety'},
    {'grade': 6, 'color': Colors.blue, 'icon': Icons.directions_car, 'description': 'Car Safety Rules'},
    {'grade': 7, 'color': Colors.indigo, 'icon': Icons.motorcycle, 'description': 'Vehicle Rules & Safety'},
    {'grade': 8, 'color': Colors.purple, 'icon': Icons.local_police, 'description': 'Traffic Laws & Regulations'},
    {'grade': 9, 'color': Colors.teal, 'icon': Icons.security, 'description': 'Advanced Safety Rules'},
    {'grade': 10, 'color': Colors.brown, 'icon': Icons.school, 'description': 'Comprehensive Traffic Rules'},
  ];

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (nameController.text.trim().isEmpty || selectedGrade == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your name and select your grade!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    // Create user with grade information
    final user = User(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: nameController.text.trim(),
      email: '${nameController.text.toLowerCase().replaceAll(' ', '.')}@student.grade$selectedGrade.com',
      grade: selectedGrade!,
    );

    // Simulate loading for better UX
    await Future.delayed(const Duration(seconds: 1));

    widget.onLogin(user);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade300,
              Colors.blue.shade600,
              Colors.purple.shade400,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 40),
                _buildHeader(),
                const SizedBox(height: 40),
                _buildLoginForm(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Icon(
            Icons.school,
            size: 60,
            color: Colors.blue,
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          '🚦 TrafficAce Kids 🚦',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            'Learn Traffic Rules & Stay Safe!',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    return Card(
      elevation: 10,
      shadowColor: Colors.black.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Row(
              children: [
                Icon(Icons.person, color: Colors.blue, size: 24),
                SizedBox(width: 8),
                Text(
                  'Tell us about yourself!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildNameField(),
            const SizedBox(height: 24),
            _buildGradeSelection(),
            const SizedBox(height: 30),
            _buildStartButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.child_care, color: Colors.green, size: 20),
            SizedBox(width: 8),
            Text(
              'What\'s your name?',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: nameController,
          decoration: InputDecoration(
            hintText: 'Enter your first name',
            prefixIcon: const Icon(Icons.face, color: Colors.blue),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: Colors.blue.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: Colors.blue, width: 2),
            ),
            filled: true,
            fillColor: Colors.blue.shade50,
          ),
          style: const TextStyle(fontSize: 16),
          textInputAction: TextInputAction.done,
        ),
      ],
    );
  }

  Widget _buildGradeSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.grade, color: Colors.orange, size: 20),
            SizedBox(width: 8),
            Text(
              'Which grade are you in?',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          height: 320,
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: GridView.builder(
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 0.85,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: grades.length,
            itemBuilder: (context, index) {
              final gradeData = grades[index];
              final grade = gradeData['grade'] as int;
              final isSelected = selectedGrade == grade;
              
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedGrade = grade;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? gradeData['color'] 
                        : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected 
                          ? gradeData['color'] 
                          : Colors.grey.shade300,
                      width: isSelected ? 3 : 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: (gradeData['color'] as Color).withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isSelected 
                              ? Colors.white.withOpacity(0.2) 
                              : (gradeData['color'] as Color).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          gradeData['icon'],
                          size: 24,
                          color: isSelected 
                              ? Colors.white 
                              : gradeData['color'],
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Grade $grade',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isSelected 
                              ? Colors.white 
                              : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        gradeData['description'],
                        style: TextStyle(
                          fontSize: 10,
                          color: isSelected 
                              ? Colors.white.withOpacity(0.9) 
                              : Colors.grey.shade600,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStartButton() {
    return ElevatedButton(
      onPressed: isLoading ? null : _handleLogin,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        elevation: 5,
      ),
      child: isLoading
          ? const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    strokeWidth: 2,
                  ),
                ),
                SizedBox(width: 12),
                Text(
                  'Getting Ready...',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            )
          : const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.rocket_launch, size: 24),
                SizedBox(width: 8),
                Text(
                  'Start Learning!',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
    );
  }
}