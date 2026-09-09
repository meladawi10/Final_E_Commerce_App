import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';

import 'package:t_store/core/utils/constants/sizes.dart';
import 'package:t_store/features/personalization/presentation/cubit/addresses_cubit.dart';
import 'package:t_store/features/personalization/presentation/cubit/addresses_state.dart';

class NewAddressForm extends StatefulWidget {
  const NewAddressForm({super.key});

  @override
  State<NewAddressForm> createState() => _NewAddressFormState();
}

class _NewAddressFormState extends State<NewAddressForm> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _streetController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _countryController = TextEditingController();

  bool _isDefault = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _streetController.dispose();
    _postalCodeController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  void _saveAddress() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    context.read<AddressesCubit>().addAddress(
          fullName: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
          addressLine1: _streetController.text.trim(),
          addressLine2: null,
          city: _cityController.text.trim(),
          state: _stateController.text.trim().isEmpty
              ? null
              : _stateController.text.trim(),
          postalCode: _postalCodeController.text.trim().isEmpty
              ? null
              : _postalCodeController.text.trim(),
          country: _countryController.text.trim(),
          isDefault: _isDefault,
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AddressesCubit, AddressesState>(
      listener: (context, state) {
        if (state is AddressAdded) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Address saved successfully'),
            ),
          );

          Navigator.of(context).pop(true);
        }

        if (state is AddressesError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
            ),
          );
        }
      },
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                prefixIcon: Icon(Iconsax.user),
                labelText: "Name",
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your name';
                }
                return null;
              },
            ),

            const SizedBox(
              height: TSizes.spaceBtwInputFields,
            ),

            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                prefixIcon: Icon(Iconsax.mobile),
                labelText: "Phone Number",
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your phone number';
                }
                return null;
              },
            ),

            const SizedBox(
              height: TSizes.spaceBtwInputFields,
            ),

            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _streetController,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Iconsax.building_31),
                      labelText: "Street",
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Required';
                      }
                      return null;
                    },
                  ),
                ),

                const SizedBox(
                  width: TSizes.spaceBtwInputFields,
                ),

                Expanded(
                  child: TextFormField(
                    controller: _postalCodeController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Iconsax.code),
                      labelText: "Postal Code",
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: TSizes.spaceBtwInputFields,
            ),

            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _cityController,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Iconsax.building),
                      labelText: "City",
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Required';
                      }
                      return null;
                    },
                  ),
                ),

                const SizedBox(
                  width: TSizes.spaceBtwInputFields,
                ),

                Expanded(
                  child: TextFormField(
                    controller: _stateController,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Iconsax.activity),
                      labelText: "State",
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: TSizes.spaceBtwInputFields,
            ),

            TextFormField(
              controller: _countryController,
              decoration: const InputDecoration(
                prefixIcon: Icon(Iconsax.global),
                labelText: "Country",
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your country';
                }
                return null;
              },
            ),

            const SizedBox(
              height: TSizes.spaceBtwInputFields,
            ),

            CheckboxListTile(
              value: _isDefault,
              onChanged: (value) {
                setState(() {
                  _isDefault = value ?? false;
                });
              },
              title: const Text('Set as default address'),
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
            ),

            const SizedBox(
              height: TSizes.defaultSpace,
            ),

            BlocBuilder<AddressesCubit, AddressesState>(
              builder: (context, state) {
                final isLoading = state is AddressAdding;

                return SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _saveAddress,
                    child: isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Text("Save"),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}