import 'package:acadobs/core/controller/dropdown_provider.dart';
import 'package:acadobs/core/controller/file_picker_provider.dart';
import 'package:acadobs/features/bottom_nav/controller/bottom_navbar_controller.dart';
import 'package:acadobs/features/superadmin/school_classes/controller/school_classes_controller.dart';
import 'package:acadobs/features/superadmin/school_subjects/controller/school_subjects_controller.dart';
import 'package:acadobs/features/superadmin/schools/controller/school_controller.dart';
import 'package:provider/provider.dart';

getProviders() {
  return [
    ChangeNotifierProvider(create: (_) => FilePickerProvider()),
    ChangeNotifierProvider(create: (_) => DropdownProvider()),
    
    //**********SUPER ADMIN************//
    ChangeNotifierProvider(create: (_) => BottomNavbarController()),
    ChangeNotifierProvider(create: (_) => SchoolController()),
    ChangeNotifierProvider(create: (_) => SchoolClassController()),
    ChangeNotifierProvider(create: (_) => SchoolSubjectsController()),
  ];
}
