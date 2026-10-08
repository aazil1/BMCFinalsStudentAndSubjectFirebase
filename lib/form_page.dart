import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

const Color primaryRed = Color(0xFF8F2638);
const Color darkRed = Color(0xFF681D2B);
const Color softRed = Color(0xFFF7EAED);
const Color lightRed = Color(0xFFFCF5F6);

const Color background = Color(0xFFF8F7F7);
const Color textDark = Color(0xFF292426);
const Color textMuted = Color(0xFF81777A);
const Color border = Color(0xFFE5DDDF);

class FormPage extends StatefulWidget {
  const FormPage({super.key});

  @override
  State<FormPage> createState() => _FormPageState();
}

class _FormPageState extends State<FormPage>
    with TickerProviderStateMixin {
  // ============================================================
  // USER REGISTRATION
  // ============================================================

  final TextEditingController nameController =
      TextEditingController();

  final TextEditingController sectionController =
      TextEditingController();

  final TextEditingController courseController =
      TextEditingController();

  // ============================================================
  // SUBJECT ENROLLMENT
  // ============================================================

  final TextEditingController subject1Controller =
      TextEditingController();

  final TextEditingController subject2Controller =
      TextEditingController();

  String subject1Time = '';
  String subject2Time = '';

  // ============================================================
  // FIREBASE
  // ============================================================

  final FirebaseFirestore firestore =
      FirebaseFirestore.instance;

  // ============================================================
  // PAGE CONTROL
  // ============================================================

  int currentPage = 0;

  // ============================================================
  // ANIMATION
  // ============================================================

  late AnimationController pageAnimationController;
  late AnimationController successAnimationController;

  late Animation<double> pageFadeAnimation;
  late Animation<Offset> pageSlideAnimation;
  late Animation<double> successScaleAnimation;

  bool isSaving = false;

  // ============================================================
  // COLORS
  // ============================================================

  static const Color primaryRed = Color(0xFF8F2638);
  static const Color darkRed = Color(0xFF681D2B);
  static const Color softRed = Color(0xFFF7EAED);
  static const Color lightRed = Color(0xFFFCF5F6);

  static const Color background = Color(0xFFF8F7F7);
  static const Color textDark = Color(0xFF292426);
  static const Color textMuted = Color(0xFF81777A);
  static const Color border = Color(0xFFE5DDDF);

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    pageAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    pageFadeAnimation = CurvedAnimation(
      parent: pageAnimationController,
      curve: Curves.easeOut,
    );

    pageSlideAnimation = Tween<Offset>(
      begin: const Offset(0.05, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: pageAnimationController,
        curve: Curves.easeOutCubic,
      ),
    );

    successAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    successScaleAnimation = CurvedAnimation(
      parent: successAnimationController,
      curve: Curves.elasticOut,
    );

    pageAnimationController.forward();
  }

  // ============================================================
  // NEXT PAGE
  // ============================================================

  void nextPage() {
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

    if (currentPage == 1) {
      if (subject1Controller.text.trim().isEmpty ||
          subject1Time.isEmpty) {
        showMessage(
          'Please fill in Subject #1 and Time.',
        );
        return;
      }
    }

    if (currentPage < 2) {
      setState(() {
        currentPage++;
      });

      pageAnimationController.reset();
      pageAnimationController.forward();
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

      pageAnimationController.reset();
      pageAnimationController.forward();
    }
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(
          16,
          0,
          16,
          18,
        ),
        backgroundColor: const Color(0xFF3B3033),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        content: Row(
          children: [
            const Icon(
              Icons.info_outline_rounded,
              color: Colors.white,
              size: 21,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // TIME PICKER
  // ============================================================

  Future<void> pickTimeRange(
    int subjectNumber,
  ) async {
    TimeOfDay? startTime =
        await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      helpText: 'Select START time',
    );

    if (startTime == null) {
      return;
    }

    TimeOfDay? endTime =
        await showTimePicker(
      context: context,
      initialTime: startTime,
      helpText: 'Select END time',
    );

    if (endTime == null) {
      return;
    }

    final String formattedStart =
        startTime.format(context);

    final String formattedEnd =
        endTime.format(context);

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
    if (isSaving) {
      return;
    }

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

    setState(() {
      isSaving = true;
    });

    try {
      await firestore.collection('act3').add({
        'name': nameController.text.trim(),
        'section': sectionController.text.trim(),
        'course': courseController.text.trim(),

        'subject1':
            subject1Controller.text.trim(),

        'subject1Time':
            subject1Time,

        'subject2':
            subject2Controller.text.trim(),

        'subject2Time':
            subject2Time,

        'createdAt':
            FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      setState(() {
        isSaving = false;
      });

      await showSuccessDialog();

    } catch (e) {
      if (!mounted) return;

      setState(() {
        isSaving = false;
      });

      showMessage(
        'Error saving data: $e',
      );
    }
  }

  // ============================================================
  // SUCCESS DIALOG
  // ============================================================

  Future<void> showSuccessDialog() async {
    successAnimationController.reset();

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        successAnimationController.forward();

        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding:
              const EdgeInsets.symmetric(
            horizontal: 24,
          ),
          child: ScaleTransition(
            scale: successScaleAnimation,
            child: Container(
              width: 420,
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black
                        .withOpacity(0.12),
                    blurRadius: 30,
                    offset:
                        const Offset(0, 15),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize:
                    MainAxisSize.min,
                children: [
                  Container(
                    width: 78,
                    height: 78,
                    decoration:
                        BoxDecoration(
                      color: softRed,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: primaryRed,
                      size: 45,
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    'Registration Complete',
                    textAlign:
                        TextAlign.center,
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight:
                          FontWeight.w700,
                      color: textDark,
                    ),
                  ),

                  const SizedBox(height: 9),

                  const Text(
                    'Your student information has been successfully submitted to the university system.',
                    textAlign:
                        TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.5,
                      color: textMuted,
                    ),
                  ),

                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(
                          context,
                        );

                        clearForm();

                        setState(() {
                          currentPage = 0;
                        });

                        pageAnimationController
                            .reset();

                        pageAnimationController
                            .forward();
                      },
                      style:
                          ElevatedButton.styleFrom(
                        backgroundColor:
                            primaryRed,
                        foregroundColor:
                            Colors.white,
                        elevation: 0,
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius
                                  .circular(13),
                        ),
                      ),
                      child: const Text(
                        'Return to Registration',
                        style: TextStyle(
                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
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
    pageAnimationController.dispose();
    successAnimationController.dispose();

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
      backgroundColor: background,
      body: SafeArea(
        child: Column(
          children: [
            // Minimal top spacing
            const SizedBox(height: 14),

            // Progress indicator
            buildProgressIndicator(),

            Expanded(
              child: SingleChildScrollView(
                physics:
                    const BouncingScrollPhysics(),
                padding:
                    const EdgeInsets.fromLTRB(
                  16,
                  20,
                  16,
                  32,
                ),
                child: SlideTransition(
                  position:
                      pageSlideAnimation,
                  child: FadeTransition(
                    opacity:
                        pageFadeAnimation,
                    child:
                        buildCurrentPage(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // PROGRESS INDICATOR
  // ============================================================

  Widget buildProgressIndicator() {
    final List<String> titles = [
      'Registration',
      'Subjects',
      'Verification',
    ];

    return Padding(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 24,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints:
              const BoxConstraints(
            maxWidth: 430,
          ),
          child: Row(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: List.generate(
              titles.length,
              (index) {
                final bool active =
                    currentPage == index;

                final bool completed =
                    currentPage > index;

                return Expanded(
                  child: Row(
                    children: [
                      Column(
                        mainAxisSize:
                            MainAxisSize.min,
                        children: [
                          AnimatedContainer(
                            duration:
                                const Duration(
                              milliseconds: 300,
                            ),
                            curve:
                                Curves.easeOut,
                            width:
                                active ? 36 : 30,
                            height:
                                active ? 36 : 30,
                            decoration:
                                BoxDecoration(
                              color: active ||
                                      completed
                                  ? primaryRed
                                  : const Color(
                                      0xFFE7E1E3,
                                    ),
                              shape:
                                  BoxShape.circle,
                              boxShadow: active
                                  ? [
                                      BoxShadow(
                                        color:
                                            primaryRed
                                                .withOpacity(
                                          0.18,
                                        ),
                                        blurRadius:
                                            10,
                                        offset:
                                            const Offset(
                                          0,
                                          4,
                                        ),
                                      ),
                                    ]
                                  : null,
                            ),
                            child:
                                AnimatedSwitcher(
                              duration:
                                  const Duration(
                                milliseconds:
                                    220,
                              ),
                              child: completed
                                  ? const Icon(
                                      Icons
                                          .check_rounded,
                                      key: ValueKey(
                                        'check',
                                      ),
                                      size: 17,
                                      color:
                                          Colors.white,
                                    )
                                  : Text(
                                      '${index + 1}',
                                      key: ValueKey(
                                        index,
                                      ),
                                      style:
                                          TextStyle(
                                        color: active
                                            ? Colors
                                                .white
                                            : const Color(
                                                0xFF968A8E,
                                              ),
                                        fontSize: 12,
                                        fontWeight:
                                            FontWeight
                                                .w700,
                                      ),
                                    ),
                            ),
                          ),

                          const SizedBox(
                            height: 6,
                          ),

                          Text(
                            titles[index],
                            textAlign:
                                TextAlign.center,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: active
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: active
                                  ? primaryRed
                                  : textMuted,
                            ),
                          ),
                        ],
                      ),

                      if (index <
                          titles.length - 1)
                        Expanded(
                          child:
                              AnimatedContainer(
                            duration:
                                const Duration(
                              milliseconds: 300,
                            ),
                            height: 2,
                            margin:
                                const EdgeInsets.only(
                              bottom: 22,
                              left: 7,
                              right: 7,
                            ),
                            decoration:
                                BoxDecoration(
                              color: currentPage >
                                      index
                                  ? primaryRed
                                  : const Color(
                                      0xFFE5DDDF,
                                    ),
                              borderRadius:
                                  BorderRadius
                                      .circular(20),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
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
  // ============================================================

  Widget buildPage1() {
    return FormContainer(
      title: 'Student Registration',
      subtitle:
          'Provide your basic student information.',
      icon: Icons.person_outline_rounded,
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          buildTextField(
            controller: nameController,
            label: 'Name',
            icon:
                Icons.person_outline_rounded,
          ),

          buildTextField(
            controller: sectionController,
            label: 'Section',
            icon: Icons.class_outlined,
          ),

          buildTextField(
            controller: courseController,
            label: 'Course',
            icon:
                Icons.menu_book_outlined,
          ),

          const SizedBox(height: 8),

          buildPrimaryButton(
            text: 'Continue',
            icon:
                Icons.arrow_forward_rounded,
            onPressed: nextPage,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PAGE 2
  // ============================================================

  Widget buildPage2() {
    return FormContainer(
      title: 'Subject Enrollment',
      subtitle:
          'Enter the subjects you want to enroll in.',
      icon:
          Icons.calendar_month_outlined,
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          buildSectionHeader(
            'Subject #1',
            Icons.looks_one_outlined,
          ),

          const SizedBox(height: 12),

          buildTextField(
            controller:
                subject1Controller,
            label: 'Subject',
            icon: Icons.book_outlined,
          ),

          buildTimeField(
            label: 'Time',
            value: subject1Time,
            onTap: () {
              pickTimeRange(1);
            },
          ),

          const SizedBox(height: 12),

          buildSectionHeader(
            'Subject #2',
            Icons.looks_two_outlined,
          ),

          const SizedBox(height: 12),

          buildTextField(
            controller:
                subject2Controller,
            label: 'Subject',
            icon: Icons.book_outlined,
          ),

          buildTimeField(
            label: 'Time',
            value: subject2Time,
            onTap: () {
              pickTimeRange(2);
            },
          ),

          const SizedBox(height: 8),

          Row(
            children: [
              Expanded(
                child:
                    buildSecondaryButton(
                  text: 'Back',
                  icon:
                      Icons.arrow_back_rounded,
                  onPressed:
                      previousPage,
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child:
                    buildPrimaryButton(
                  text: 'Continue',
                  icon:
                      Icons.arrow_forward_rounded,
                  onPressed: nextPage,
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
  // ============================================================

  Widget buildPage3() {
    return FormContainer(
      title: 'Review & Verification',
      subtitle:
          'Review your information before submitting.',
      icon:
          Icons.fact_check_outlined,
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          // Information notice
          Container(
            padding:
                const EdgeInsets.all(13),
            decoration:
                BoxDecoration(
              color: softRed,
              borderRadius:
                  BorderRadius.circular(13),
              border: Border.all(
                color:
                    const Color(0xFFEBD5DA),
              ),
            ),
            child: Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  color: primaryRed,
                  size: 20,
                ),

                const SizedBox(width: 9),

                Expanded(
                  child: Text(
                    'Please check your information carefully. Once submitted, the registration will be saved to the university system.',
                    style:
                        const TextStyle(
                      fontSize: 12,
                      height: 1.45,
                      color:
                          Color(0xFF654C53),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 22),

          buildSectionHeader(
            'Student Information',
            Icons.person_outline_rounded,
          ),

          const SizedBox(height: 12),

          buildOutput(
            'Name',
            nameController.text,
            Icons.person_outline,
          ),

          buildOutput(
            'Section',
            sectionController.text,
            Icons.class_outlined,
          ),

          buildOutput(
            'Course',
            courseController.text,
            Icons.menu_book_outlined,
          ),

          const SizedBox(height: 8),

          const Divider(
            color: border,
          ),

          const SizedBox(height: 16),

          buildSectionHeader(
            'Subject #1',
            Icons.looks_one_outlined,
          ),

          const SizedBox(height: 12),

          buildOutput(
            'Subject',
            subject1Controller.text,
            Icons.book_outlined,
          ),

          buildOutput(
            'Time',
            subject1Time,
            Icons.access_time_rounded,
          ),

          const SizedBox(height: 8),

          const Divider(
            color: border,
          ),

          const SizedBox(height: 16),

          buildSectionHeader(
            'Subject #2',
            Icons.looks_two_outlined,
          ),

          const SizedBox(height: 12),

          buildOutput(
            'Subject',
            subject2Controller.text.isEmpty
                ? 'Not provided'
                : subject2Controller.text,
            Icons.book_outlined,
          ),

          buildOutput(
            'Time',
            subject2Time.isEmpty
                ? 'Not provided'
                : subject2Time,
            Icons.access_time_rounded,
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child:
                    buildSecondaryButton(
                  text: 'Back',
                  icon:
                      Icons.arrow_back_rounded,
                  onPressed: isSaving
                      ? null
                      : previousPage,
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child:
                    buildPrimaryButton(
                  text: isSaving
                      ? 'Submitting...'
                      : 'Submit',
                  icon: isSaving
                      ? Icons
                          .hourglass_top_rounded
                      : Icons
                          .check_circle_outline_rounded,
                  onPressed: isSaving
                      ? null
                      : saveData,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SECTION HEADER
  // ============================================================

  Widget buildSectionHeader(
    String title,
    IconData icon,
  ) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: softRed,
            borderRadius:
                BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: primaryRed,
            size: 19,
          ),
        ),

        const SizedBox(width: 9),

        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: textDark,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // TEXT INPUT
  // ============================================================

  Widget buildTextField({
    required TextEditingController
        controller,
    required String label,
    required IconData icon,
  }) {
    return Padding(
      padding:
          const EdgeInsets.only(
        bottom: 13,
      ),
      child: TextField(
        controller: controller,
        textInputAction:
            TextInputAction.next,
        style: const TextStyle(
          color: textDark,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        decoration:
            InputDecoration(
          labelText: label,
          labelStyle:
              const TextStyle(
            color: textMuted,
            fontSize: 13,
          ),

          floatingLabelStyle:
              const TextStyle(
            color: primaryRed,
            fontSize: 13,
            fontWeight:
                FontWeight.w600,
          ),

          prefixIcon: Icon(
            icon,
            color: const Color(
              0xFF958A8E,
            ),
            size: 20,
          ),

          filled: true,
          fillColor: Colors.white,

          contentPadding:
              const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 15,
          ),

          border:
              OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(13),
            borderSide:
                const BorderSide(
              color: border,
            ),
          ),

          enabledBorder:
              OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(13),
            borderSide:
                const BorderSide(
              color: border,
            ),
          ),

          focusedBorder:
              OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(13),
            borderSide:
                const BorderSide(
              color: primaryRed,
              width: 1.5,
            ),
          ),
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
      padding:
          const EdgeInsets.only(
        bottom: 13,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius:
              BorderRadius.circular(13),
          child: InputDecorator(
            decoration:
                InputDecoration(
              labelText: label,
              labelStyle:
                  const TextStyle(
                color: textMuted,
                fontSize: 13,
              ),

              floatingLabelStyle:
                  const TextStyle(
                color: primaryRed,
                fontSize: 13,
                fontWeight:
                    FontWeight.w600,
              ),

              prefixIcon:
                  const Icon(
                Icons.access_time_rounded,
                color: Color(0xFF958A8E),
                size: 20,
              ),

              suffixIcon:
                  const Icon(
                Icons
                    .keyboard_arrow_down_rounded,
                color: Color(0xFF958A8E),
                size: 21,
              ),

              filled: true,
              fillColor: Colors.white,

              contentPadding:
                  const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 15,
              ),

              border:
                  OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(13),
                borderSide:
                    const BorderSide(
                  color: border,
                ),
              ),

              enabledBorder:
                  OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(13),
                borderSide:
                    const BorderSide(
                  color: border,
                ),
              ),
            ),

            child: Text(
              value.isEmpty
                  ? 'Select time'
                  : value,
              style: TextStyle(
                color: value.isEmpty
                    ? const Color(
                        0xFF958A8E,
                      )
                    : textDark,
                fontSize: 14,
                fontWeight: value.isEmpty
                    ? FontWeight.normal
                    : FontWeight.w600,
              ),
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
    IconData icon,
  ) {
    return Container(
      margin:
          const EdgeInsets.only(
        bottom: 8,
      ),
      padding:
          const EdgeInsets.symmetric(
        horizontal: 13,
        vertical: 12,
      ),
      decoration:
          BoxDecoration(
        color: lightRed,
        borderRadius:
            BorderRadius.circular(12),
        border: Border.all(
          color: border,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration:
                BoxDecoration(
              color: softRed,
              borderRadius:
                  BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 17,
              color: primaryRed,
            ),
          ),

          const SizedBox(width: 10),

          SizedBox(
            width: 60,
            child: Text(
              label,
              style:
                  const TextStyle(
                fontSize: 11,
                fontWeight:
                    FontWeight.w600,
                color: textMuted,
              ),
            ),
          ),

          const SizedBox(width: 8),

          Expanded(
            child: Text(
              value.isEmpty
                  ? 'Not provided'
                  : value,
              style:
                  const TextStyle(
                fontSize: 13,
                fontWeight:
                    FontWeight.w600,
                color: textDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PRIMARY BUTTON
  // ============================================================

  Widget buildPrimaryButton({
    required String text,
    required IconData icon,
    required VoidCallback? onPressed,
  }) {
    return SizedBox(
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style:
            ElevatedButton.styleFrom(
          backgroundColor: primaryRed,
          foregroundColor: Colors.white,
          disabledBackgroundColor:
              const Color(0xFFC6A5AC),
          disabledForegroundColor:
              Colors.white,
          elevation: 0,
          padding:
              const EdgeInsets.symmetric(
            horizontal: 14,
          ),
          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(13),
          ),
        ),
        child: AnimatedSwitcher(
          duration:
              const Duration(
            milliseconds: 200,
          ),
          child: Row(
            key: ValueKey(text),
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  text,
                  overflow:
                      TextOverflow.ellipsis,
                  style:
                      const TextStyle(
                    fontSize: 13,
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),
              ),

              const SizedBox(width: 7),

              Icon(
                icon,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // SECONDARY BUTTON
  // ============================================================

  Widget buildSecondaryButton({
    required String text,
    required IconData icon,
    required VoidCallback? onPressed,
  }) {
    return SizedBox(
      height: 50,
      child: OutlinedButton(
        onPressed: onPressed,
        style:
            OutlinedButton.styleFrom(
          foregroundColor: darkRed,
          backgroundColor:
              Colors.white,
          disabledForegroundColor:
              const Color(0xFFB5A9AD),
          side:
              const BorderSide(
            color: border,
          ),
          padding:
              const EdgeInsets.symmetric(
            horizontal: 12,
          ),
          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(13),
          ),
        ),
        child: Row(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
            ),

            const SizedBox(width: 7),

            Flexible(
              child: Text(
                text,
                overflow:
                    TextOverflow.ellipsis,
                style:
                    const TextStyle(
                  fontSize: 13,
                  fontWeight:
                      FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================================================================
// FORM CONTAINER
// ================================================================

class FormContainer
    extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Widget child;

  const FormContainer({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(
      BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints:
            const BoxConstraints(
          maxWidth: 600,
        ),
        child: Container(
          width: double.infinity,
          decoration:
              BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.circular(20),
            border: Border.all(
              color: border,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black
                    .withOpacity(0.035),
                blurRadius: 22,
                offset:
                    const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              // ==================================================
              // MINIMAL FORM HEADER
              // ==================================================

              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.fromLTRB(
                  20,
                  20,
                  20,
                  18,
                ),
                decoration:
                    const BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.only(
                    topLeft:
                        Radius.circular(20),
                    topRight:
                        Radius.circular(20),
                  ),
                  border: Border(
                    bottom: BorderSide(
                      color: border,
                    ),
                  ),
                ),
                child: Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration:
                          BoxDecoration(
                        color: softRed,
                        borderRadius:
                            BorderRadius.circular(
                          12,
                        ),
                      ),
                      child: Icon(
                        icon,
                        color: primaryRed,
                        size: 22,
                      ),
                    ),

                    const SizedBox(
                      width: 12,
                    ),

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                        children: [
                          Text(
                            title,
                            style:
                                const TextStyle(
                              fontSize: 19,
                              fontWeight:
                                  FontWeight.w700,
                              color: textDark,
                              letterSpacing:
                                  -0.2,
                            ),
                          ),

                          const SizedBox(
                            height: 4,
                          ),

                          Text(
                            subtitle,
                            style:
                                const TextStyle(
                              fontSize: 12,
                              height: 1.35,
                              color: textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ==================================================
              // CONTENT
              // ==================================================

              Padding(
                padding:
                    const EdgeInsets.fromLTRB(
                  20,
                  20,
                  20,
                  22,
                ),
                child: child,
              ),
            ],
          ),
        ),
      ),
    );
  }
}