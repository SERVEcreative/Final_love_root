# Custom Profile Images

This folder is for storing custom profile images for the romantic dating app.

## How to Add Custom Images:

### 1. **Local Assets (Recommended for demo)**
- Place your images in this folder: `assets/images/`
- Supported formats: JPG, PNG, WebP
- Update the `pubspec.yaml` to include your images:

```yaml
flutter:
  assets:
    - assets/images/
```

### 2. **Local File Paths (For real app)**
- Use absolute paths to images on device storage
- Example: `/storage/emulated/0/Pictures/profile.jpg`
- Make sure to request storage permissions

### 3. **Network URLs**
- Use HTTPS URLs for online images
- Example: `https://example.com/profile.jpg`

## Image Requirements:
- **Recommended size**: 300x300 pixels or larger
- **Format**: JPG, PNG, WebP
- **Aspect ratio**: Square (1:1) works best
- **File size**: Keep under 2MB for performance

## Example Usage in Code:
```dart
UserProfile(
  name: 'Sarah',
  age: 25,
  image: 'assets/images/sarah_profile.jpg', // Local asset
  // OR
  image: '/storage/emulated/0/Pictures/sarah.jpg', // Local file
  // OR
  image: 'https://example.com/sarah.jpg', // Network image
)
```

## Fallback Behavior:
If an image fails to load, the app will show:
- A person icon
- The first letter of the person's name
- A subtle grey background
