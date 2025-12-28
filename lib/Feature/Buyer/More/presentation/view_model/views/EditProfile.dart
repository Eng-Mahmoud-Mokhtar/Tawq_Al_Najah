import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import '../../../../../../Core/Widgets/AppBar.dart';
import '../../../../../../Core/Widgets/countryList.dart';
import '../../../../../../Core/utiles/Colors.dart';
import '../../../../../../generated/l10n.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final Dio _dio = Dio();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final ImagePicker _picker = ImagePicker();

  XFile? _profileImageXFile;
  Uint8List? _profileImageBytes;
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _countryController;
  late TextEditingController _cityController;
  late TextEditingController _locationController;
  String? _currentImageUrl;

  bool _isLoading = true;
  bool _isUpdating = false;
  String? _errorMessage;
  String? _nameError;
  String? _emailError;
  String? _phoneError;
  String? _countryError;
  String? _cityError;
  String? _locationError;
  String _selectedCountryCode = '20';
  String _selectedCountryFlag = '🇪🇬';
  bool _hasChanges = false;
  Map<String, dynamic> _originalData = {};
  late TextEditingController _searchController;
  List<Map<String, String>> _filteredCountries = List.from(countryList);

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _countryController = TextEditingController();
    _cityController = TextEditingController();
    _locationController = TextEditingController();
    _searchController = TextEditingController();
    _nameController.addListener(_checkForChanges);
    _emailController.addListener(_checkForChanges);
    _phoneController.addListener(_checkForChanges);
    _countryController.addListener(_checkForChanges);
    _cityController.addListener(_checkForChanges);
    _locationController.addListener(_checkForChanges);
    _loadUserProfile();
  }

  @override
  void dispose() {
    _nameController.removeListener(_checkForChanges);
    _emailController.removeListener(_checkForChanges);
    _phoneController.removeListener(_checkForChanges);
    _countryController.removeListener(_checkForChanges);
    _cityController.removeListener(_checkForChanges);
    _locationController.removeListener(_checkForChanges);
    _searchController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _countryController.dispose();
    _cityController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _checkForChanges() {
    final hasChanged =
        _nameController.text != (_originalData['name'] ?? '') ||
            _emailController.text != (_originalData['email'] ?? '') ||
            _phoneController.text != (_originalData['phone'] ?? '') ||
            _countryController.text != (_originalData['country'] ?? '') ||
            _cityController.text != (_originalData['city'] ?? '') ||
            _locationController.text != (_originalData['location'] ?? '') ||
            _selectedCountryCode != (_originalData['code_phone']?.toString().replaceAll('+', '') ?? '20') ||
            _profileImageBytes != null;

    if (_hasChanges != hasChanged) {
      setState(() {
        _hasChanges = hasChanged;
      });
    }
  }

  bool _validateForm() {
    bool isValid = true;
    setState(() {
      _nameError = null;
      _emailError = null;
      _phoneError = null;
      _countryError = null;
      _cityError = null;
      _locationError = null;
    });

    if (_nameController.text.isEmpty) {
      setState(() {
        _nameError = S.of(context).nameRequired;
      });
      isValid = false;
    } else if (_nameController.text.length < 3) {
      setState(() {
        _nameError = S.of(context).nameMinLength;
      });
      isValid = false;
    }

    if (_emailController.text.isEmpty) {
      setState(() {
        _emailError = S.of(context).emailRequired;
      });
      isValid = false;
    } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(_emailController.text)) {
      setState(() {
        _emailError = S.of(context).emailInvalid;
      });
      isValid = false;
    }

    if (_phoneController.text.isEmpty) {
      setState(() {
        _phoneError = S.of(context).phoneRequired;
      });
      isValid = false;
    } else if (!RegExp(r'^\d+$').hasMatch(_phoneController.text)) {
      setState(() {
        _phoneError = S.of(context).phoneNumbersOnly;
      });
      isValid = false;
    }

    if (_countryController.text.isEmpty) {
      setState(() {
        _countryError = S.of(context).countryRequired;
      });
      isValid = false;
    }

    if (_cityController.text.isEmpty) {
      setState(() {
        _cityError = S.of(context).cityRequired;
      });
      isValid = false;
    }

    if (_locationController.text.isEmpty) {
      setState(() {
        _locationError = S.of(context).locationRequired;
      });
      isValid = false;
    }

    return isValid;
  }

  Future<String?> _getToken() async {
    try {
      final token = await _secureStorage.read(key: 'user_token');

      if (token != null && token.isNotEmpty) {
        if (token.startsWith('Bearer ')) {
          return token.substring(7);
        }
        return token;
      }
      return null;
    } catch (e) {
      print('❌ Error reading token: $e');
      return null;
    }
  }

  Future<void> _loadUserProfile() async {
    print('=== Loading user profile ===');

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final token = await _getToken();

      if (token == null || token.isEmpty) {
        print('⚠️ No token available');
        setState(() {
          _errorMessage = S.of(context).profileDataNotAvailable;
          _isLoading = false;
        });
        return;
      }

      _dio.options.headers = {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      };

      _dio.options.connectTimeout = const Duration(seconds: 30);
      _dio.options.receiveTimeout = const Duration(seconds: 30);

      final response = await _dio.get(
        'https://toknagah.viking-iceland.online/api/user/show-profile',
      );

      print('✅ API Response received');
      print('Status Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = response.data;
        print('Response data: $data');

        if (data['status'] == 200) {
          final userData = data['data'];
          print('✅ User data loaded successfully');

          // حفظ البيانات الأصلية
          _originalData = {
            'name': userData['name']?.toString() ?? '',
            'email': userData['email']?.toString() ?? '',
            'phone': userData['phone']?.toString() ?? '',
            'country': userData['country']?.toString() ?? '',
            'city': userData['city']?.toString() ?? '',
            'location': userData['location']?.toString() ?? '',
            'image': userData['image']?.toString() ?? '',
            'code_phone': userData['code_phone']?.toString() ?? '+20',
          };

          setState(() {
            _nameController.text = _originalData['name'] ?? '';
            _emailController.text = _originalData['email'] ?? '';
            _phoneController.text = _originalData['phone'] ?? '';
            _countryController.text = _originalData['country'] ?? '';
            _cityController.text = _originalData['city'] ?? '';
            _locationController.text = _originalData['location'] ?? '';
            _currentImageUrl = _originalData['image'] ?? '';
            _isLoading = false;
            _hasChanges = false;
          });

          final countryCode = _originalData['code_phone'] ?? '+20';
          print('Country code from API: $countryCode');

          final codeWithoutPlus = countryCode.replaceAll('+', '');

          setState(() {
            _selectedCountryCode = codeWithoutPlus;
          });

          final country = countryList.firstWhere(
                (c) => c['code'] == codeWithoutPlus,
            orElse: () => countryList.firstWhere(
                  (c) => c['short'] == 'EG',
              orElse: () => countryList.first,
            ),
          );

          print('Selected country: ${country['name']} (${country['code']})');

          setState(() {
            _selectedCountryFlag = country['flag']!;
          });

        } else {
          print('❌ API returned error: ${data['message']}');
          setState(() {
            _errorMessage = data['message'] ?? S.of(context).failedToLoadData;
            _isLoading = false;
          });
        }
      } else {
        print('❌ HTTP Error: ${response.statusCode}');
        setState(() {
          _errorMessage = '${S.of(context).connectionError}: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } on DioException catch (e) {
      print('❌ DioException: ${e.message}');
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        setState(() {
          _errorMessage = S.of(context).connectionTimeout;
          _isLoading = false;
        });
      } else if (e.type == DioExceptionType.connectionError) {
        setState(() {
          _errorMessage = S.of(context).cannotConnectToServer;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = '${S.of(context).connectionError}: ${e.message}';
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Unexpected error: $e');
      setState(() {
        _errorMessage = '${S.of(context).connectionError}: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _pickImage() async {
    try {
      print('🟢 Starting image picker...');

      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 800,
        maxHeight: 800,
      );

      if (pickedFile != null) {
        print('✅ Image picked successfully: ${pickedFile.name}');

        final bytes = await pickedFile.readAsBytes();
        print('✅ Image bytes loaded: ${bytes.length} bytes');

        setState(() {
          _profileImageXFile = pickedFile;
          _profileImageBytes = bytes;
          _hasChanges = true;
        });
      } else {
        print('ℹ️ No image selected');
      }
    } catch (e, stackTrace) {
      print('❌ Error picking image: $e');
      print('❌ Stack trace: $stackTrace');
      // لا تظهر رسالة خطأ
    }
  }

  Future<void> _updateProfile() async {
    if (!_validateForm()) {
      return;
    }

    setState(() {
      _isUpdating = true;
      _errorMessage = null;
    });

    try {
      final token = await _getToken();
      if (token == null || token.isEmpty) {
        setState(() {
          _isUpdating = false;
        });
        return;
      }

      FormData formData = FormData();

      if (_nameController.text != (_originalData['name'] ?? '')) {
        formData.fields.add(MapEntry('username', _nameController.text));
      }

      if (_emailController.text != (_originalData['email'] ?? '')) {
        formData.fields.add(MapEntry('email', _emailController.text));
      }

      final originalCode = _originalData['code_phone']?.toString().replaceAll('+', '') ?? '20';
      if (_selectedCountryCode != originalCode) {
        formData.fields.add(MapEntry('code_phone', '+$_selectedCountryCode'));
      }

      if (_phoneController.text != (_originalData['phone'] ?? '')) {
        formData.fields.add(MapEntry('phone', _phoneController.text));
      }

      if (_countryController.text != (_originalData['country'] ?? '')) {
        formData.fields.add(MapEntry('country', _countryController.text));
      }

      if (_cityController.text != (_originalData['city'] ?? '')) {
        formData.fields.add(MapEntry('city', _cityController.text));
      }

      if (_locationController.text != (_originalData['location'] ?? '')) {
        formData.fields.add(MapEntry('location', _locationController.text));
      }

      print('📦 Form data to send:');
      if (_nameController.text != _originalData['name']) {
        print('- Name: ${_nameController.text} (changed)');
      }
      if (_emailController.text != _originalData['email']) {
        print('- Email: ${_emailController.text} (changed)');
      }
      if (_selectedCountryCode != originalCode) {
        print('- Country Code: +$_selectedCountryCode (changed)');
      }
      if (_phoneController.text != _originalData['phone']) {
        print('- Phone: ${_phoneController.text} (changed)');
      }
      if (_countryController.text != _originalData['country']) {
        print('- Country: ${_countryController.text} (changed)');
      }
      if (_cityController.text != _originalData['city']) {
        print('- City: ${_cityController.text} (changed)');
      }
      if (_locationController.text != _originalData['location']) {
        print('- Location: ${_locationController.text} (changed)');
      }

      if (_profileImageBytes != null) {
        print('📸 Adding image to form data (${_profileImageBytes!.length} bytes)');

        formData.files.add(MapEntry(
          'image',
          MultipartFile.fromBytes(
            _profileImageBytes!,
            filename: _profileImageXFile?.name ?? 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg',
          ),
        ));
      }

      _dio.options.headers = {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      };
      final response = await _dio.post(
        'https://toknagah.viking-iceland.online/api/user/update-profile',
        data: formData,
        options: Options(
          validateStatus: (status) => status! < 500,
        ),
      );
      print('✅ Update response: ${response.statusCode}');
      print('Response data: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['status'] == 200) {
          // تحديث البيانات المحلية بدون إظهار رسالة
          if (data['data'] != null) {
            final updatedData = data['data'];

            setState(() {
              _originalData = {
                'name': updatedData['username']?.toString() ?? _originalData['name'],
                'email': updatedData['email']?.toString() ?? _originalData['email'],
                'phone': updatedData['phone']?.toString() ?? _originalData['phone'],
                'country': updatedData['country']?.toString() ?? _originalData['country'],
                'city': updatedData['city']?.toString() ?? _originalData['city'],
                'location': updatedData['location']?.toString() ?? _originalData['location'],
                'image': updatedData['image']?.toString() ?? _originalData['image'],
                'code_phone': updatedData['code_phone']?.toString() ?? _originalData['code_phone'],
              };

              _nameController.text = _originalData['name'] ?? '';
              _emailController.text = _originalData['email'] ?? '';
              _phoneController.text = _originalData['phone'] ?? '';
              _countryController.text = _originalData['country'] ?? '';
              _cityController.text = _originalData['city'] ?? '';
              _locationController.text = _originalData['location'] ?? '';
              _currentImageUrl = _originalData['image'] ?? '';
              _profileImageXFile = null;
              _profileImageBytes = null;
              _hasChanges = false;
              _nameError = null;
              _emailError = null;
              _phoneError = null;
              _countryError = null;
              _cityError = null;
              _locationError = null;
            });

            final newCode = _originalData['code_phone']?.toString().replaceAll('+', '') ?? '20';
            final country = countryList.firstWhere(
                  (c) => c['code'] == newCode,
              orElse: () => countryList.firstWhere(
                    (c) => c['short'] == 'EG',
                orElse: () => countryList.first,
              ),
            );

            setState(() {
              _selectedCountryCode = newCode;
              _selectedCountryFlag = country['flag']!;
            });
          }

        } else {
          String errorMsg = data['message'] ?? S.of(context).failedToUpdateProfile;
          _handleApiError(errorMsg);
        }
      } else if (response.statusCode == 422) {
        final errorData = response.data;
        String errorMsg = errorData['message'] ?? S.of(context).invalidData;
        _handleApiError(errorMsg);
      } else if (response.statusCode == 401) {
        setState(() {
          _errorMessage = S.of(context).sessionExpired;
        });
      } else if (response.statusCode == 404) {
        setState(() {
          _errorMessage = S.of(context).serviceUnavailable;
        });
      } else if (response.statusCode != null && response.statusCode! >= 500) {
        setState(() {
          _errorMessage = S.of(context).serverError;
        });
      } else {
        setState(() {
          _errorMessage = '${S.of(context).connectionError}: ${response.statusCode}';
        });
      }
    } on DioException catch (e) {
      print('❌ DioException during update: ${e.message}');

      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        setState(() {
          _errorMessage = S.of(context).connectionTimeout;
        });
      } else if (e.type == DioExceptionType.connectionError) {
        setState(() {
          _errorMessage = S.of(context).cannotConnectToServer;
        });
      } else if (e.response != null) {
        final errorData = e.response!.data;
        String errorMsg = errorData['message'] ?? S.of(context).failedToUpdateProfile;
        _handleApiError(errorMsg);
      } else {
        setState(() {
          _errorMessage = '${S.of(context).connectionError}: ${e.message}';
        });
      }
    } catch (e) {
      print('❌ Unexpected error during update: $e');
      setState(() {
        _errorMessage = '${S.of(context).connectionError}: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isUpdating = false;
        });
      }
    }
  }

  void _handleApiError(String errorMsg) {
    if (errorMsg.contains('phone') || errorMsg.contains('رقم') || errorMsg.contains('مستخدم')) {
      setState(() {
        _phoneError = S.of(context).phoneAlreadyUsed;
        _errorMessage = S.of(context).phoneAlreadyUsed;
      });
    } else if (errorMsg.contains('email') || errorMsg.contains('بريد')) {
      setState(() {
        _emailError = S.of(context).emailAlreadyUsed;
        _errorMessage = S.of(context).emailAlreadyUsed;
      });
    } else if (errorMsg.contains('name') || errorMsg.contains('اسم')) {
      setState(() {
        _nameError = S.of(context).nameInvalid;
        _errorMessage = S.of(context).nameInvalid;
      });
    } else {
      setState(() {
        _errorMessage = errorMsg;
      });
    }
  }

  void _filterCountries(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredCountries = List.from(countryList);
      } else {
        _filteredCountries = countryList.where((country) {
          return country['name']!.toLowerCase().contains(query.toLowerCase()) ||
              country['code']!.contains(query) ||
              country['short']!.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  void _showCountryPicker() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    _filteredCountries = List.from(countryList);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              height: screenHeight * 0.8,
              padding: EdgeInsets.all(screenWidth * 0.04),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        S.of(context).chooseCountryCode,
                        style: TextStyle(
                          fontSize: screenWidth * 0.04,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.close,
                          size: screenWidth * 0.05,
                          color: Colors.grey,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  SizedBox(height: screenWidth * 0.02),
                  Container(
                    height: screenWidth * 0.12,
                    decoration: BoxDecoration(
                      color: const Color(0xffFAFAFA),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xffE9E9E9)),
                    ),
                    child: TextField(
                      controller: _searchController,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: screenWidth * 0.03,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: InputDecoration(
                        hintText: S.of(context).searchCountry,
                        hintStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: screenWidth * 0.03,
                          fontWeight: FontWeight.bold,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          vertical: screenWidth * 0.035,
                        ),
                        prefixIcon: Icon(
                          Icons.search_outlined,
                          color: Colors.grey,
                          size: screenWidth * 0.05,
                        ),
                      ),
                      onChanged: (query) {
                        if (query.isEmpty) {
                          setState(() {
                            _filteredCountries = List.from(countryList);
                          });
                        } else {
                          setState(() {
                            _filteredCountries = countryList.where((country) {
                              return country['name']!.toLowerCase().contains(query.toLowerCase()) ||
                                  country['code']!.contains(query) ||
                                  country['short']!.toLowerCase().contains(query.toLowerCase());
                            }).toList();
                          });
                        }
                      },
                    ),
                  ),
                  SizedBox(height: screenWidth * 0.02),
                  Expanded(
                    child: Directionality(
                      textDirection: TextDirection.ltr,
                      child: _filteredCountries.isEmpty
                          ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: screenWidth * 0.2,
                              color: Colors.grey,
                            ),
                            SizedBox(height: screenWidth * 0.04),
                            Text(
                              S.of(context).noResultsToShow,
                              style: TextStyle(
                                fontSize: screenWidth * 0.035,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      )
                          : ListView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: _filteredCountries.length,
                        itemBuilder: (context, index) {
                          var country = _filteredCountries[index];
                          return ListTile(
                            title: Row(
                              children: [
                                Text(
                                  country['flag']!,
                                  style: TextStyle(
                                    fontSize: screenWidth * 0.05,
                                  ),
                                ),
                                SizedBox(width: screenWidth * 0.04),
                                SizedBox(
                                  width: screenWidth * 0.15,
                                  child: Text(
                                    '+${country['code']!}',
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.035,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                SizedBox(width: screenWidth * 0.04),
                                Expanded(
                                  child: Text(
                                    country['name']!,
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.035,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            onTap: () {
                              this.setState(() {
                                _selectedCountryCode = country['code']!;
                                _selectedCountryFlag = country['flag']!;
                                _hasChanges = true;
                              });
                              Navigator.pop(context);
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    ).whenComplete(() {
      _searchController.clear();
      _filterCountries('');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SecoundColor,
      appBar: CustomAppBar(
        title: S.of(context).editProfile,
      ),
      body: _isLoading
          ? _buildShimmerLoading()
          : Padding(
        padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
        child: SingleChildScrollView(
          child: Column(
            children: [
              if (_errorMessage != null)
                _buildErrorWidget(),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              buildProfileImage(),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              buildNameField(),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              buildEmailField(),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              buildPhoneNumberField(),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              buildCountryCityFields(),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              buildLocationField(),
              SizedBox(height: MediaQuery.of(context).size.height * 0.04),

              if (_hasChanges) buildActionButtons(),

              SizedBox(height: MediaQuery.of(context).size.height * 0.05),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerLoading() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Padding(
      padding: EdgeInsets.all(screenWidth * 0.04),
      child: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: screenHeight * 0.02),
            Center(
              child: Container(
                width: screenWidth * 0.3,
                height: screenWidth * 0.3,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey.shade300,
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.02),
            ...List.generate(6, (index) => Column(
              children: [
                Container(
                  height: screenWidth * 0.12,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
              ],
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    final screenWidth = MediaQuery.of(context).size.width;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(screenWidth * 0.04),
      margin: EdgeInsets.only(bottom: screenWidth * 0.04),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.orange[800]),
          SizedBox(width: screenWidth * 0.02),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  S.of(context).error,
                  style: TextStyle(
                    color: Colors.orange[800],
                    fontSize: screenWidth * 0.05,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _errorMessage!,
                  style: TextStyle(
                    color: Colors.orange[800],
                    fontSize: screenWidth * 0.03,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildProfileImage() {
    final screenWidth = MediaQuery.of(context).size.width;

    return Center(
      child: Stack(
        children: [
          // الدائرة الرئيسية (بدون GestureDetector)
          CircleAvatar(
            radius: screenWidth * 0.15,
            backgroundColor: Colors.grey.shade300,
            backgroundImage: _getProfileImage(),
            child: shouldShowPlaceholder()
                ? Icon(
              Icons.person,
              size: screenWidth * 0.15,
              color: ThirdColor,
            )
                : null,
          ),

          // زر إضافة الصورة
          Positioned(
            right: 0,
            bottom: screenWidth * 0.04,
            child: GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: screenWidth * 0.07,
                height: screenWidth * 0.07,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: KprimaryColor,
                ),
                child: Icon(
                  Icons.add,
                  color: Colors.white,
                  size: screenWidth * 0.05,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  ImageProvider? _getProfileImage() {
    if (_profileImageBytes != null) {
      return MemoryImage(_profileImageBytes!);
    } else if (_currentImageUrl != null && _currentImageUrl!.isNotEmpty) {
      return NetworkImage(_currentImageUrl!);
    }
    return null;
  }

  bool shouldShowPlaceholder() {
    return _profileImageBytes == null &&
        (_currentImageUrl == null || _currentImageUrl!.isEmpty);
  }

  Widget buildNameField() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          S.of(context).fullName,
          style: TextStyle(
            color: KprimaryText,
            fontSize: screenWidth * 0.035,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: screenHeight * 0.01),
        SizedBox(
          height: screenWidth * 0.12,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: const Color(0xffFAFAFA),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _nameError != null ? Colors.red : const Color(0xffE9E9E9),
              ),
            ),
            child: TextFormField(
              controller: _nameController,
              style: TextStyle(
                fontSize: screenWidth * 0.03,
                color: KprimaryText,
                fontWeight: FontWeight.bold,
              ),
              decoration: InputDecoration(
                hintStyle: TextStyle(
                  fontSize: screenWidth * 0.03,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade600,
                ),
                hintText: S.of(context).fullName,
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  vertical: screenWidth * 0.035,
                  horizontal: screenWidth * 0.035,
                ),
              ),
            ),
          ),
        ),
        if (_nameError != null)
          Padding(
            padding: EdgeInsets.only(top: 4),
            child: Text(
              _nameError!,
              style: TextStyle(
                color: Colors.red,
                fontSize: screenWidth * 0.025,
              ),
            ),
          ),
      ],
    );
  }

  Widget buildEmailField() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          S.of(context).email,
          style: TextStyle(
            color: Colors.black,
            fontSize: screenWidth * 0.035,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: screenHeight * 0.01),
        SizedBox(
          height: screenWidth * 0.12,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: const Color(0xffFAFAFA),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _emailError != null ? Colors.red : const Color(0xffE9E9E9),
              ),
            ),
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: TextFormField(
                controller: _emailController,
                textDirection: TextDirection.ltr,
                style: TextStyle(
                  fontSize: screenWidth * 0.03,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
                decoration: InputDecoration(
                  hintStyle: TextStyle(
                    fontSize: screenWidth * 0.03,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                  hintText: 'example@email.com',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    vertical: screenWidth * 0.035,
                    horizontal: screenWidth * 0.035,
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
            ),
          ),
        ),
        if (_emailError != null)
          Padding(
            padding: EdgeInsets.only(top: 4),
            child: Text(
              _emailError!,
              style: TextStyle(
                color: Colors.red,
                fontSize: screenWidth * 0.025,
              ),
            ),
          ),
      ],
    );
  }

  Widget buildPhoneNumberField() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          S.of(context).phoneNumber,
          style: TextStyle(
            color: Colors.black,
            fontSize: screenWidth * 0.035,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: screenHeight * 0.01),
        SizedBox(
          height: screenWidth * 0.12,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: const Color(0xffFAFAFA),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _phoneError != null ? Colors.red : const Color(0xffE9E9E9),
              ),
            ),
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: Row(
                children: [
                  GestureDetector(
                    onTap: _showCountryPicker,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.02,
                      ),
                      child: Row(
                        children: [
                          Text(
                            _selectedCountryFlag,
                            style: TextStyle(
                              fontSize: screenWidth * 0.04,
                            ),
                          ),
                          SizedBox(width: screenWidth * 0.01),
                          Text(
                            '+$_selectedCountryCode',
                            style: TextStyle(
                              fontSize: screenWidth * 0.03,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Icon(
                            Icons.keyboard_arrow_down,
                            size: screenWidth * 0.05,
                            color: Colors.grey.shade500,
                          ),
                          SizedBox(width: screenWidth * 0.01),
                          Container(
                            height: screenWidth * 0.1,
                            width: 1.0,
                            color: Colors.grey.shade300,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: TextFormField(
                      controller: _phoneController,
                      textDirection: TextDirection.ltr,
                      style: TextStyle(
                        fontSize: screenWidth * 0.03,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: InputDecoration(
                        hintStyle: TextStyle(
                          fontSize: screenWidth * 0.03,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                        hintText: '1001234567',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          vertical: screenWidth * 0.035,
                        ),
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (_phoneError != null)
          Padding(
            padding: EdgeInsets.only(top: 4),
            child: Text(
              _phoneError!,
              style: TextStyle(
                color: Colors.red,
                fontSize: screenWidth * 0.025,
              ),
            ),
          ),
      ],
    );
  }

  Widget buildCountryCityFields() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    S.of(context).country,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: screenWidth * 0.035,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  SizedBox(
                    height: screenWidth * 0.12,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: const Color(0xffFAFAFA),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _countryError != null ? Colors.red : const Color(0xffE9E9E9),
                        ),
                      ),
                      child: TextFormField(
                        controller: _countryController,
                        style: TextStyle(
                          fontSize: screenWidth * 0.03,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: InputDecoration(
                          hintStyle: TextStyle(
                            fontSize: screenWidth * 0.03,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade600,
                          ),
                          hintText: S.of(context).country,
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            vertical: screenWidth * 0.035,
                            horizontal: screenWidth * 0.035,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: screenWidth * 0.04),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    S.of(context).city,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: screenWidth * 0.035,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  SizedBox(
                    height: screenWidth * 0.12,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: const Color(0xffFAFAFA),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _cityError != null ? Colors.red : const Color(0xffE9E9E9),
                        ),
                      ),
                      child: TextFormField(
                        controller: _cityController,
                        style: TextStyle(
                          fontSize: screenWidth * 0.03,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: InputDecoration(
                          hintStyle: TextStyle(
                            fontSize: screenWidth * 0.03,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade600,
                          ),
                          hintText: S.of(context).city,
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            vertical: screenWidth * 0.035,
                            horizontal: screenWidth * 0.035,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: screenHeight * 0.01),
        Row(
          children: [
            if (_countryError != null)
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(top: 4),
                  child: Text(
                    _countryError!,
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: screenWidth * 0.025,
                    ),
                  ),
                ),
              ),
            SizedBox(width: screenWidth * 0.04),
            if (_cityError != null)
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(top: 4),
                  child: Text(
                    _cityError!,
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: screenWidth * 0.025,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget buildLocationField() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          S.of(context).location,
          style: TextStyle(
            color: KprimaryText,
            fontSize: screenWidth * 0.035,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: screenHeight * 0.01),
        SizedBox(
          height: screenWidth * 0.12,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: const Color(0xffFAFAFA),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _locationError != null ? Colors.red : const Color(0xffE9E9E9),
              ),
            ),
            child: TextFormField(
              controller: _locationController,
              style: TextStyle(
                fontSize: screenWidth * 0.03,
                color: KprimaryText,
                fontWeight: FontWeight.bold,
              ),
              decoration: InputDecoration(
                hintStyle: TextStyle(
                  fontSize: screenWidth * 0.03,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade600,
                ),
                hintText: S.of(context).location,
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  vertical: screenWidth * 0.035,
                  horizontal: screenWidth * 0.035,
                ),
              ),
            ),
          ),
        ),
        if (_locationError != null)
          Padding(
            padding: EdgeInsets.only(top: 4),
            child: Text(
              _locationError!,
              style: TextStyle(
                color: Colors.red,
                fontSize: screenWidth * 0.025,
              ),
            ),
          ),
      ],
    );
  }

  Widget buildActionButtons() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // ================= SAVE BUTTON =================
        Expanded(
          child: ElevatedButton(
            onPressed: _isUpdating ? null : _updateProfile,
            style: ElevatedButton.styleFrom(
              backgroundColor: KprimaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: EdgeInsets.symmetric(vertical: screenHeight * 0.025),
            ),
            child: _isUpdating
                ? SizedBox(
              width: screenWidth * 0.05,
              height: screenWidth * 0.05,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: Colors.white,
              ),
            )
                : Text(
              S.of(context).save,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: screenWidth * 0.035,
              ),
            ),
          ),
        ),

        SizedBox(width: screenWidth * 0.04),

        // ================= CANCEL BUTTON =================
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              setState(() {
                _nameController.text = _originalData['name'] ?? '';
                _emailController.text = _originalData['email'] ?? '';
                _phoneController.text = _originalData['phone'] ?? '';
                _countryController.text = _originalData['country'] ?? '';
                _cityController.text = _originalData['city'] ?? '';
                _locationController.text = _originalData['location'] ?? '';

                final originalCode = _originalData['code_phone']
                    ?.toString()
                    .replaceAll('+', '') ??
                    '20';
                _selectedCountryCode = originalCode;

                final country = countryList.firstWhere(
                      (c) => c['code'] == originalCode,
                  orElse: () => countryList.firstWhere(
                        (c) => c['short'] == 'EG',
                    orElse: () => countryList.first,
                  ),
                );
                _selectedCountryFlag = country['flag']!;
                _profileImageXFile = null;
                _profileImageBytes = null;
                _hasChanges = false;
                _nameError = null;
                _emailError = null;
                _phoneError = null;
                _countryError = null;
                _cityError = null;
                _locationError = null;
                _errorMessage = null;
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: SecoundColor,
              side: const BorderSide(color: Color(0xffE72929)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: EdgeInsets.symmetric(vertical: screenHeight * 0.025),
            ),
            child: Text(
              S.of(context).cancel,
              style: TextStyle(
                color: Color(0xffE72929),
                fontWeight: FontWeight.bold,
                fontSize: screenWidth * 0.035,
              ),
            ),
          ),
        ),
      ],
    );
  }
}