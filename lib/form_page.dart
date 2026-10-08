import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FormPage extends StatefulWidget {
  const FormPage({super.key});

  @override
  State<FormPage> createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {
  // ============================================================
  // USER REGISTRATION
  // ============================================================

  final TextEditingController nameController = TextEditingController();
  final TextEditingController sectionController = TextEditingController();
  final TextEditingController courseController = TextEditingController();

  // ============================================================
  // SUBJECT ENROLLMENT
  // ============================================================

  final TextEditingController subject1Controller = TextEditingController();
  final TextEditingController subject2Controller = TextEditingController();

  String subject1Time = '';
  String subject2Time = '';

  // ============================================================
  // FIREBASE
  // ============================================================

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // ============================================================
  // PAGE CONTROL
  // ============================================================

  int currentPage = 0;

  // ============================================================
  // NEXT PAGE
  // ============================================================

  void nextPage() {
    // PAGE 1 VALIDATION
    if (currentPage == 0) {
      if (nameController.text.trim().isEmpty ||
          sectionController.text.trim().isEmpty ||
          courseController.text.trim().isEmpty) {
        showMessage(
          'Please fill in Name, Section, and Course.',
        );
        return;
      }
    }

    // PAGE 2 VALIDATION
    if (currentPage == 1) {
      if (subject1Controller.text.trim().isEmpty ||
          subject1Time.isEmpty) {
        showMessage(
          'Please fill in Subject #1 and Time.',
        );
        return;
      }

      // Subject #2 is optional
    }

    if (currentPage < 2) {
      setState(() {
        currentPage++;
      });
    }
  }

  // ============================================================
  // PREVIOUS PAGE
  // ============================================================

  void previousPage() {
    if (currentPage > 0) {
      setState(() {
        currentPage--;
      });
    }
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  // ============================================================
  // TIME PICKER
  // ============================================================

  Future<void> pickTimeRange(int subjectNumber) async {
    // START TIME
    TimeOfDay? startTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      helpText: 'Select START time',
    );

    if (startTime == null) {
      return;
    }

    // END TIME
    TimeOfDay? endTime = await showTimePicker(
      context: context,
      initialTime: startTime,
      helpText: 'Select END time',
    );

    if (endTime == null) {
      return;
    }

    final String formattedStart = startTime.format(context);
    final String formattedEnd = endTime.format(context);

    final String selectedRange =
        '$formattedStart - $formattedEnd';

    setState(() {
      if (subjectNumber == 1) {
        subject1Time = selectedRange;
      } else {
        subject2Time = selectedRange;
      }
    });
  }

  // ============================================================
  // SAVE TO FIREBASE
  // ============================================================

  Future<void> saveData() async {
    if (nameController.text.trim().isEmpty ||
        sectionController.text.trim().isEmpty ||
        courseController.text.trim().isEmpty) {
      showMessage(
        'Please complete the registration information.',
      );
      return;
    }

    if (subject1Controller.text.trim().isEmpty ||
        subject1Time.isEmpty) {
      showMessage(
        'Please complete Subject #1 information.',
      );
      return;
    }

    try {
      await firestore.collection('act3').add({
        'name': nameController.text.trim(),
        'section': sectionController.text.trim(),
        'course': courseController.text.trim(),

        'subject1': subject1Controller.text.trim(),
        'subject1Time': subject1Time,

        'subject2': subject2Controller.text.trim(),
        'subject2Time': subject2Time,

        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: const Text('Registration Complete'),
            content: const Text(
              'The student information has been successfully saved.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);

                  clearForm();

                  setState(() {
                    currentPage = 0;
                  });
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      if (!mounted) return;

      showMessage(
        'Error saving data: $e',
      );
    }
  }

  // ============================================================
  // CLEAR FORM
  // ============================================================

  void clearForm() {
    nameController.clear();
    sectionController.clear();
    courseController.clear();

    subject1Controller.clear();
    subject2Controller.clear();

    subject1Time = '';
    subject2Time = '';
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    nameController.dispose();
    sectionController.dispose();
    courseController.dispose();

    subject1Controller.dispose();
    subject2Controller.dispose();

    super.dispose();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          getPageTitle(),
        ),
        centerTitle: true,
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: buildCurrentPage(),
        ),
      ),
    );
  }

  // ============================================================
  // PAGE TITLE
  // ============================================================

  String getPageTitle() {
    if (currentPage == 0) {
      return 'User Registration';
    }

    if (currentPage == 1) {
      return 'Subject Enrollment';
    }

    return 'Subject Verification Details';
  }

  // ============================================================
  // CURRENT PAGE
  // ============================================================

  Widget buildCurrentPage() {
    if (currentPage == 0) {
      return buildPage1();
    }

    if (currentPage == 1) {
      return buildPage2();
    }

    return buildPage3();
  }

  // ============================================================
  // PAGE 1
  // USER REGISTRATION
  // ============================================================

  Widget buildPage1() {
    return FormContainer(
      title: 'User Registration',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildTextField(
            controller: nameController,
            label: 'Name',
          ),

          buildTextField(
            controller: sectionController,
            label: 'Section',
          ),

          buildTextField(
            controller: courseController,
            label: 'Course',
          ),

          const SizedBox(height: 15),

          // NEXT
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: nextPage,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                ),
              ),
              child: const Text('Next'),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PAGE 2
  // SUBJECT ENROLLMENT
  // ============================================================

  Widget buildPage2() {
    return FormContainer(
      title: 'Subject Enrollment',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // SUBJECT #1
          const Text(
            'Subject #1',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          buildTextField(
            controller: subject1Controller,
            label: 'Subject',
          ),

          buildTimeField(
            label: 'Time',
            value: subject1Time,
            onTap: () {
              pickTimeRange(1);
            },
          ),

          const SizedBox(height: 15),

          // SUBJECT #2
          const Text(
            'Subject #2',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          buildTextField(
            controller: subject2Controller,
            label: 'Subject',
          ),

          buildTimeField(
            label: 'Time',
            value: subject2Time,
            onTap: () {
              pickTimeRange(2);
            },
          ),

          const SizedBox(height: 20),

          // BUTTONS
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: previousPage,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                    ),
                  ),
                  child: const Text('Back'),
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: ElevatedButton(
                  onPressed: nextPage,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                    ),
                  ),
                  child: const Text('Next'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PAGE 3
  // SUBJECT VERIFICATION DETAILS
  // OUTPUT PAGE
  // ============================================================

  Widget buildPage3() {
    return FormContainer(
      title: 'Subject Verification Details',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // USER INFORMATION
          const Text(
            'Student Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 15),

          buildOutput(
            'Name',
            nameController.text,
          ),

          buildOutput(
            'Section',
            sectionController.text,
          ),

          buildOutput(
            'Course',
            courseController.text,
          ),

          const Divider(
            height: 30,
          ),

          // SUBJECT #1
          const Text(
            'Subject #1',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          buildOutput(
            'Subject',
            subject1Controller.text,
          ),

          buildOutput(
            'Time',
            subject1Time,
          ),

          const SizedBox(height: 15),

          // SUBJECT #2
          const Text(
            'Subject #2',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          buildOutput(
            'Subject',
            subject2Controller.text.isEmpty
                ? 'Not provided'
                : subject2Controller.text,
          ),

          buildOutput(
            'Time',
            subject2Time.isEmpty
                ? 'Not provided'
                : subject2Time,
          ),

          const SizedBox(height: 25),

          // BUTTONS
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: previousPage,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                    ),
                  ),
                  child: const Text('Back'),
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: ElevatedButton(
                  onPressed: saveData,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                    ),
                  ),
                  child: const Text('Save'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TEXT INPUT
  // ============================================================

  Widget buildTextField({
    required TextEditingController controller,
    required String label,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  // ============================================================
  // TIME INPUT
  // ============================================================

  Widget buildTimeField({
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
            suffixIcon: const Icon(
              Icons.access_time,
            ),
          ),
          child: Text(
            value.isEmpty
                ? 'Select time'
                : value,
            style: TextStyle(
              color: value.isEmpty
                  ? Colors.grey
                  : Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // OUTPUT
  // ============================================================

  Widget buildOutput(
    String label,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 85,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          Expanded(
            child: Text(
              value.isEmpty
                  ? 'Not provided'
                  : value,
            ),
          ),
        ],
      ),
    );
  }
}

// ================================================================
// FORM CONTAINER
// ================================================================

class FormContainer extends StatelessWidget {
  final String title;
  final Widget child;

  const FormContainer({
    super.key,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: Colors.grey.shade400,
        ),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),

          child,
        ],
      ),
    );
  }
}