import 'package:acadobs/presentation/providers/dropdown_provider.dart';
import 'package:acadobs/presentation/providers/file_picker_provider.dart';
import 'package:acadobs/presentation/bottom_nav/controller/bottom_navbar_controller.dart';
import 'package:acadobs/features/superadmin/presentation/school_classes/controller/school_classes_controller.dart';
import 'package:acadobs/features/superadmin/presentation/school_subjects/controller/school_subjects_controller.dart';
import 'package:acadobs/features/superadmin/presentation/schools/controller/school_controller.dart';
import 'package:provider/provider.dart';

getProviders() {
  return [
    //**********COMMON PROVIDERS************//
    ChangeNotifierProvider(create: (_) => BottomNavbarController()),
    ChangeNotifierProvider(create: (_) => FilePickerProvider()),
    ChangeNotifierProvider(create: (_) => DropdownProvider()),
    
    //*************SUPER ADMIN*************//
    ChangeNotifierProvider(create: (_) => SchoolController()),
    ChangeNotifierProvider(create: (_) => SchoolClassController()),
    ChangeNotifierProvider(create: (_) => SchoolSubjectsController()),
  ];
}
