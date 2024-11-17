import 'package:flutter/material.dart';
import 'package:video_tape_store/utils/constants.dart';
import 'package:video_tape_store/models/video_tape.dart';
import 'package:video_tape_store/widgets/custom_textfield.dart';
import 'package:video_tape_store/widgets/custom_button.dart';

class AddEditVideoPage extends StatefulWidget {
  final VideoTape? tape;

  const AddEditVideoPage({
    super.key,
    this.tape,
  });

  @override
  State<AddEditVideoPage> createState() => _AddEditVideoPageState();
}

class _AddEditVideoPageState extends State<AddEditVideoPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  final List<String> _imageUrls = [];

  late final TextEditingController _titleController;
  late final TextEditingController _priceController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _stockController;
  String _selectedGenre = VideoGenre.action.displayName;
  int _selectedLevel = 1;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.tape?.title);
    _priceController = TextEditingController(
      text: widget.tape?.price.toStringAsFixed(2),
    );
    _descriptionController = TextEditingController(
      text: widget.tape?.description,
    );
    _stockController = TextEditingController(
      text: widget.tape?.stockQuantity.toString(),
    );

    if (widget.tape != null) {
      _selectedGenre = widget.tape!.genreName;
      _selectedLevel = widget.tape!.level;
      _imageUrls.addAll(widget.tape!.imageUrls);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  Future<void> _saveVideoTape() async {
    if (!_formKey.currentState!.validate()) return;
    if (_imageUrls.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one image'),
          backgroundColor: AppColors.errorColor,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Video tape saved successfully'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to save video tape'),
            backgroundColor: AppColors.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _addImage() async {
    setState(() {
      _imageUrls
          .add('https://picsum.photos/400/300?random=${_imageUrls.length + 1}');
    });
  }

  void _removeImage(int index) {
    setState(() {
      _imageUrls.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceColor,
        title: Text(
          widget.tape == null ? 'Add Video Tape' : 'Edit Video Tape',
          style: AppTextStyles.headingMedium,
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppDimensions.paddingMedium),
          children: [
            _buildImagesSection(),
            const SizedBox(height: AppDimensions.marginLarge),
            const Text(
              'Basic Information',
              style: AppTextStyles.headingSmall,
            ),
            const SizedBox(height: AppDimensions.marginMedium),
            CustomTextField(
              controller: _titleController,
              label: 'Title',
              hint: 'Enter video tape title',
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Title is required';
                }
                return null;
              },
            ),
            const SizedBox(height: AppDimensions.marginMedium),
            CustomTextField(
              controller: _priceController,
              label: 'Price',
              hint: 'Enter price',
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Price is required';
                }
                final price = double.tryParse(value!);
                if (price == null || price <= 0) {
                  return 'Please enter a valid price';
                }
                return null;
              },
            ),
            const SizedBox(height: AppDimensions.marginMedium),
            CustomTextField(
              controller: _stockController,
              label: 'Stock Quantity',
              hint: 'Enter stock quantity',
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Stock quantity is required';
                }
                final stock = int.tryParse(value!);
                if (stock == null || stock < 0) {
                  return 'Please enter a valid stock quantity';
                }
                return null;
              },
            ),
            const SizedBox(height: AppDimensions.marginMedium),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingMedium,
                vertical: AppDimensions.paddingSmall,
              ),
              decoration: BoxDecoration(
                color: AppColors.surfaceColor,
                borderRadius:
                    BorderRadius.circular(AppDimensions.borderRadiusSmall),
                border: Border.all(color: AppColors.dividerColor),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: _selectedGenre,
                  hint: const Text('Select Genre'),
                  items: VideoGenre.values.map((genre) {
                    return DropdownMenuItem(
                      value: genre.displayName,
                      child: Text(genre.displayName),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedGenre = value);
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.marginMedium),
            const Text(
              'Level',
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: AppDimensions.marginSmall),
            Wrap(
              spacing: AppDimensions.marginSmall,
              children: VideoLevel.values.map((level) {
                final isSelected = _selectedLevel == level.value;
                return ChoiceChip(
                  label: Text(level.displayName),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _selectedLevel = level.value);
                    }
                  },
                  selectedColor: AppColors.primaryColor,
                  backgroundColor: AppColors.surfaceColor,
                );
              }).toList(),
            ),
            const SizedBox(height: AppDimensions.marginLarge),
            const Text(
              'Description',
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: AppDimensions.marginSmall),
            TextFormField(
              controller: _descriptionController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Enter video tape description',
                filled: true,
                fillColor: AppColors.surfaceColor,
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(AppDimensions.borderRadiusSmall),
                  borderSide: const BorderSide(color: AppColors.dividerColor),
                ),
              ),
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Description is required';
                }
                if (value!.length < 20) {
                  return 'Description must be at least 20 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: AppDimensions.marginLarge * 2),
            CustomButton(
              onPressed: _isLoading ? null : _saveVideoTape,
              text: 'Save Video Tape',
              isLoading: _isLoading,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Images',
          style: AppTextStyles.headingSmall,
        ),
        const SizedBox(height: AppDimensions.marginMedium),
        Container(
          height: 120,
          decoration: BoxDecoration(
            color: AppColors.surfaceColor,
            borderRadius:
                BorderRadius.circular(AppDimensions.borderRadiusSmall),
            border: Border.all(color: AppColors.dividerColor),
          ),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(AppDimensions.paddingSmall),
            itemCount: _imageUrls.length + 1,
            itemBuilder: (context, index) {
              if (index == _imageUrls.length) {
                return _buildAddImageButton();
              }
              return _buildImageCard(index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAddImageButton() {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: AppDimensions.marginSmall),
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusSmall),
        border: Border.all(color: AppColors.primaryColor),
      ),
      child: InkWell(
        onTap: _addImage,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.add_photo_alternate_outlined,
              size: 32,
              color: AppColors.primaryColor,
            ),
            const SizedBox(height: AppDimensions.marginSmall),
            Text(
              'Add Image',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageCard(int index) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: AppDimensions.marginSmall),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusSmall),
        image: DecorationImage(
          image: NetworkImage(_imageUrls[index]),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 4,
            right: 4,
            child: InkWell(
              onTap: () => _removeImage(index),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: AppColors.errorColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
