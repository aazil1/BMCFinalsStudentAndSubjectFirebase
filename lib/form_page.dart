import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FormPage extends StatefulWidget {
  const FormPage({super.key});

  @override
  State<FormPage> createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {
  // Personal Information
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController middleNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController nicknameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController birthdayController = TextEditingController();

  // Contact Information
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController cityController = TextEditingController();

  // School Information
  final TextEditingController courseController = TextEditingController();
  final TextEditingController sectionController = TextEditingController();
  final TextEditingController schoolController = TextEditingController();

  // Personal / Casual Information
  final TextEditingController hobbiesController = TextEditingController();
  final TextEditingController favoriteFoodController =
      TextEditingController();
  final TextEditingController favoriteColorController =
      TextEditingController();
  final TextEditingController bioController = TextEditingController();

  // Dropdown values
  String? selectedGender;
  String? selectedCivilStatus;
  String? selectedYearLevel;

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> saveData() async {
    if (firstNameController.text.trim().isEmpty ||
        lastNameController.text.trim().isEmpty ||
        ageController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty ||
        courseController.text.trim().isEmpty ||
        sectionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields')),
      );
      return;
    }

    await firestore.collection('students').add({
      // Personal Information
      'firstName': firstNameController.text.trim(),
      'middleName': middleNameController.text.trim(),
      'lastName': lastNameController.text.trim(),
      'nickname': nicknameController.text.trim(),
      'age': ageController.text.trim(),
      'birthday': birthdayController.text.trim(),
      'gender': selectedGender,
      'civilStatus': selectedCivilStatus,

      // Contact Information
      'email': emailController.text.trim(),
      'phone': phoneController.text.trim(),
      'address': addressController.text.trim(),
      'city': cityController.text.trim(),

      // School Information
      'course': courseController.text.trim(),
      'yearLevel': selectedYearLevel,
      'section': sectionController.text.trim(),
      'school': schoolController.text.trim(),

      // Casual Information
      'hobbies': hobbiesController.text.trim(),
      'favoriteFood': favoriteFoodController.text.trim(),
      'favoriteColor': favoriteColorController.text.trim(),
      'bio': bioController.text.trim(),

      'createdAt': FieldValue.serverTimestamp(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Biodata saved successfully')),
    );

    // Clear all fields
    firstNameController.clear();
    middleNameController.clear();
    lastNameController.clear();
    nicknameController.clear();
    ageController.clear();
    birthdayController.clear();

    emailController.clear();
    phoneController.clear();
    addressController.clear();
    cityController.clear();

    courseController.clear();
    sectionController.clear();
    schoolController.clear();

    hobbiesController.clear();
    favoriteFoodController.clear();
    favoriteColorController.clear();
    bioController.clear();

    setState(() {
      selectedGender = null;
      selectedCivilStatus = null;
      selectedYearLevel = null;
    });
  }

  @override
  void dispose() {
    // Personal Information
    firstNameController.dispose();
    middleNameController.dispose();
    lastNameController.dispose();
    nicknameController.dispose();
    ageController.dispose();
    birthdayController.dispose();

    // Contact Information
    emailController.dispose();
    phoneController.dispose();
    addressController.dispose();
    cityController.dispose();

    // School Information
    courseController.dispose();
    sectionController.dispose();
    schoolController.dispose();

    // Casual Information
    hobbiesController.dispose();
    favoriteFoodController.dispose();
    favoriteColorController.dispose();
    bioController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Biodata Form'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            // =========================
            // PERSONAL INFORMATION
            // =========================

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Personal Information',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: firstNameController,
              decoration: const InputDecoration(
                labelText: 'First Name *',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: middleNameController,
              decoration: const InputDecoration(
                labelText: 'Middle Name',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: lastNameController,
              decoration: const InputDecoration(
                labelText: 'Last Name *',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: nicknameController,
              decoration: const InputDecoration(
                labelText: 'Nickname',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: ageController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Age *',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: birthdayController,
              decoration: const InputDecoration(
                labelText: 'Birthday',
                hintText: 'MM/DD/YYYY',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            // Gender
            DropdownButtonFormField<String>(
              value: selectedGender,
              decoration: const InputDecoration(
                labelText: 'Gender',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'Male',
                  child: Text('Male'),
                ),
                DropdownMenuItem(
                  value: 'Female',
                  child: Text('Female'),
                ),
                DropdownMenuItem(
                  value: 'Other',
                  child: Text('Other'),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  selectedGender = value;
                });
              },
            ),

            const SizedBox(height: 12),

            // Civil Status
            DropdownButtonFormField<String>(
              value: selectedCivilStatus,
              decoration: const InputDecoration(
                labelText: 'Civil Status',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'Single',
                  child: Text('Single'),
                ),
                DropdownMenuItem(
                  value: 'Married',
                  child: Text('Married'),
                ),
                DropdownMenuItem(
                  value: 'Other',
                  child: Text('Other'),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  selectedCivilStatus = value;
                });
              },
            ),

            const SizedBox(height: 24),

            // =========================
            // CONTACT INFORMATION
            // =========================

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Contact Information',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email *',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: addressController,
              decoration: const InputDecoration(
                labelText: 'Address',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: cityController,
              decoration: const InputDecoration(
                labelText: 'City / Municipality',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 24),

            // =========================
            // SCHOOL INFORMATION
            // =========================

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'School Information',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: courseController,
              decoration: const InputDecoration(
                labelText: 'Course *',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            // Year Level
            DropdownButtonFormField<String>(
              value: selectedYearLevel,
              decoration: const InputDecoration(
                labelText: 'Year Level',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: '1st Year',
                  child: Text('1st Year'),
                ),
                DropdownMenuItem(
                  value: '2nd Year',
                  child: Text('2nd Year'),
                ),
                DropdownMenuItem(
                  value: '3rd Year',
                  child: Text('3rd Year'),
                ),
                DropdownMenuItem(
                  value: '4th Year',
                  child: Text('4th Year'),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  selectedYearLevel = value;
                });
              },
            ),

            const SizedBox(height: 12),

            TextField(
              controller: sectionController,
              decoration: const InputDecoration(
                labelText: 'Section *',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: schoolController,
              decoration: const InputDecoration(
                labelText: 'School',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 24),

            // =========================
            // CASUAL INFORMATION
            // =========================

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'About Me',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: hobbiesController,
              decoration: const InputDecoration(
                labelText: 'Hobbies',
                hintText: 'e.g. Gaming, Drawing, Collecting',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: favoriteFoodController,
              decoration: const InputDecoration(
                labelText: 'Favorite Food',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: favoriteColorController,
              decoration: const InputDecoration(
                labelText: 'Favorite Color',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: bioController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Short Bio',
                hintText: 'Tell something about yourself...',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 24),

            // =========================
            // SAVE BUTTON
            // =========================

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: saveData,
                child: const Text('Save to Firebase'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}