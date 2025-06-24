import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/medical_info_model.dart';

class MedicalInfoScreen extends StatefulWidget {
  final String userId;

  const MedicalInfoScreen({super.key, required this.userId});

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
  late DocumentReference _docRef;

  @override
  void initState() {
    super.initState();
    _docRef = FirebaseFirestore.instance.collection('medical_info').doc(widget.userId);
    _loadMedicalInfo();
  }

  Future<void> _loadMedicalInfo() async {
    final doc = await _docRef.get();
    if (doc.exists) {
      final data = doc.data() as Map<String, dynamic>;
      final medicalInfo = MedicalInfoModel.fromMap(data, doc.id);

      setState(() {
        _bloodTypeController.text = medicalInfo.bloodGroup ?? '';
        _allergiesController.text = medicalInfo.allergies?.join(', ') ?? '';
        _conditionsController.text = medicalInfo.conditions?.join(', ') ?? '';
        _medicationsController.text = medicalInfo.medications?.join(', ') ?? '';
        _emergencyContactController.text = medicalInfo.emergencyContact ?? '';
        _doctorNameController.text = medicalInfo.doctorName ?? '';
        _doctorPhoneController.text = medicalInfo.doctorPhone ?? '';
        _insuranceInfoController.text = medicalInfo.insuranceInfo ?? '';
        _additionalNotesController.text = medicalInfo.additionalNotes ?? '';
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveMedicalInfo() async {
    if (!_formKey.currentState!.validate()) return;

    final medicalInfo = MedicalInfoModel(
      id: widget.userId,
      bloodGroup: _bloodTypeController.text.trim(),
      allergies: _allergiesController.text.split(',').map((e) => e.trim()).toList(),
      medications: _medicationsController.text.split(',').map((e) => e.trim()).toList(),
      conditions: _conditionsController.text.split(',').map((e) => e.trim()).toList(),
      emergencyContact: _emergencyContactController.text.trim(),
      doctorName: _doctorNameController.text.trim(),
      doctorPhone: _doctorPhoneController.text.trim(),
      insuranceInfo: _insuranceInfoController.text.trim(),
      additionalNotes: _additionalNotesController.text.trim(),
      lastUpdated: DateTime.now(),
      createdAt: DateTime.now(),
    );

    await _docRef.set(medicalInfo.toMap());
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Medical info saved.')));
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
        validator: (value) => value == null || value.isEmpty ? 'Required' : null,
      ),
    );
  }
}
