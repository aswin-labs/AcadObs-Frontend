import 'package:acadobs/features/superadmin/data/models/classes_model.dart';
import 'package:acadobs/features/superadmin/data/models/school_model.dart';
import 'package:acadobs/features/superadmin/data/models/school_subject_model.dart';
import 'package:acadobs/features/superadmin/presentation/school_classes/screens/add_class_screen.dart';
import 'package:acadobs/features/superadmin/presentation/school_classes/screens/edit_class_screen.dart';
import 'package:acadobs/features/superadmin/presentation/school_subjects/screens/add_subject_screen.dart';
import 'package:acadobs/features/superadmin/presentation/school_subjects/screens/edit_subject_screen.dart';
import 'package:acadobs/features/superadmin/presentation/schools/screens/add_school_screen.dart';
import 'package:acadobs/features/superadmin/presentation/schools/screens/edit_school_screen.dart';
import 'package:acadobs/routes/router_constants.dart';
import 'package:go_router/go_router.dart';

final List<GoRoute> superAdminRoutes = [
  // ***************Schools********************
  GoRoute(
    path: '/addSchool',
    name: RouteConstants.addSchool,
    builder: (context, state) => AddSchoolScreen(),
  ),
  GoRoute(
    path: '/editSchool',
    name: RouteConstants.editSchool,
    builder: (context, state) {
      final School school = state.extra as School;
      return EditSchoolScreen(school: school);
    },
  ),
  // ***************Classes********************
  GoRoute(
    path: '/addClass',
    name: RouteConstants.addClass,
    builder: (context, state) {
      return AddClassScreen();
    },
  ),
  GoRoute(
    path: '/editClass',
    name: RouteConstants.editClass,
    builder: (context, state) {
      final SchoolClass schoolClass = state.extra as SchoolClass;
      return EditClassScreen(schoolClass: schoolClass);
    },
  ),
  // ***************Subjects********************
  GoRoute(
    path: '/addSubject',
    name: RouteConstants.addSubject,
    builder: (context, state) {
      return AddSubjectScreen();
    },
  ),
  GoRoute(
    path: '/editSubject',
    name: RouteConstants.editSubject,
    builder: (context, state) {
      final SchoolSubject schoolSubject = state.extra as SchoolSubject;
      return EditSubjectScreen(subject: schoolSubject);
    },
  ),
];
