// lib/data/graphql/documents/mutations/register_device_mutation.dart

/// GraphQL mutation for registering a device for push notifications
const String registerDeviceMutation = r'''
  mutation RegisterDevice($input: RegisterDeviceInput!) {
    registerDevice(input: $input) {
      device {
        id
        fcmToken
        deviceName
        platform
      }
      errors
    }
  }
''';
