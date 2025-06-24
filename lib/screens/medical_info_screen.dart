import 'package:flutter/material.dart';
import '../models/medical_info_model.dart';
import '../services/firebase_service.dart';

class MedicalInfoScreen extends StatefulWidget {
  const MedicalInfoScreen({super.key});

  @override
  State<MedicalInfoScreen> createState() => _MedicalInfoScreenState();
}

class _MedicalInfoScreenState extends State<MedicalInfoScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _bloodTypeController = TextEditingController();
  final _allergiesController = TextEditingController();
  final _conditionsController = TextEditingController();
  final _medicationsController = TextEditingController();
  final _emergencyContactController = TextEditingController();
  final _doctorNameController = TextEditingController();
  final _doctorPhoneController = TextEditingController();
  final _insuranceInfoController = TextEditingController();
  final _additionalNotesController = TextEditingController();

  bool _isLoading = true;
  MedicalInfoModel? _medicalInfo;

  @override
  void initState() {
    super.initState();
    _loadMedicalInfo();
  }

  Future<void> _loadMedicalInfo() async {
    setState(() {
      _isLoading = true;
    });
    final data = await FirebaseService.getMedicalInfo();
    if (data != null) {
      final medicalInfo = MedicalInfoModel.fromMap(data, 'primary'); // doc id is 'primary'

      setState(() {
        _medicalInfo = medicalInfo;
        _bloodTypeController.text = medicalInfo.bloodGroup ?? '';
        _allergiesController.text = (medicalInfo.allergies ?? []).join(', ');
        _conditionsController.text = (medicalInfo.conditions ?? []).join(', ');
        _medicationsController.text = (medicalInfo.medications ?? []).join(', ');
        _emergencyContactController.text = medicalInfo.emergencyContact ?? '';
        _doctorNameController.text = medicalInfo.doctorName ?? '';
        _doctorPhoneController.text = medicalInfo.doctorPhone ?? '';
        _insuranceInfoController.text = medicalInfo.insuranceInfo ?? '';
        _additionalNotesController.text = medicalInfo.additionalNotes ?? '';
      });
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _saveMedicalInfo() async {
    if (!_formKey.currentState!.validate()) return;

    final newInfo = (_medicalInfo ?? MedicalInfoModel(id: 'primary')).copyWith(
      bloodGroup: _bloodTypeController.text.trim(),
      allergies: _allergiesController.text.isEmpty
          ? []
          : _allergiesController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
      medications: _medicationsController.text.isEmpty
          ? []
          : _medicationsController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
      conditions: _conditionsController.text.isEmpty
          ? []
          : _conditionsController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
      emergencyContact: _emergencyContactController.text.trim(),
      doctorName: _doctorNameController.text.trim(),
      doctorPhone: _doctorPhoneController.text.trim(),
      insuranceInfo: _insuranceInfoController.text.trim(),
      additionalNotes: _additionalNotesController.text.trim(),
      lastUpdated: DateTime.now(),
    );

    await FirebaseService.updateMedicalInfo(newInfo.toMap());
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Medical info saved.')));
      // No need to reload, the state is already updated.
    }
  }

  @override
  void dispose() {
    _bloodTypeController.dispose();
    _allergiesController.dispose();
    _conditionsController.dispose();
    _medicationsController.dispose();
    _emergencyContactController.dispose();
    _doctorNameController.dispose();
    _doctorPhoneController.dispose();
    _insuranceInfoController.dispose();
    _additionalNotesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Medical Info')),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField(_bloodTypeController, 'Blood Type'),
              _buildTextField(_allergiesController, 'Allergies (comma separated)'),
              _buildTextField(_conditionsController, 'Medical Conditions (comma separated)'),
              _buildTextField(_medicationsController, 'Medications (comma separated)'),
              _buildTextField(_emergencyContactController, 'Emergency Contact'),
              _buildTextField(_doctorNameController, 'Doctor Name'),
              _buildTextField(_doctorPhoneController, 'Doctor Phone'),
              _buildTextField(_insuranceInfoController, 'Insurance Info'),
              _buildTextField(_additionalNotesController, 'Additional Notes'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveMedicalInfo,
                child: Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(labelText: label, border: OutlineInputBorder()),
        validator: (value) {
          if (label != 'Blood Type' && (value == null || value.isEmpty)) {
            return 'This field cannot be empty';
          }
          return null;
        },
      ),
    );
  }
}
