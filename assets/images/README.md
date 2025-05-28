# Role Images System

This folder contains character images that are randomly shown on the role reveal screen AFTER players reveal their actual roles.

## ✅ IMPORTANT: Game Security

**Spy images are ONLY shown to actual spies!** 
- Saboteurs and team members will show role-specific icons until you add their images
- This prevents accidental spoilers during the game

## Folder Structure

- **spies/**: Images shown ONLY to players revealed as spies/impostors  
- **saboteurs/**: Images shown ONLY to players revealed as saboteurs (currently shows icons)
- **teammembers/**: Images shown ONLY to players revealed as civilians/detectives (currently shows icons)

## How It Works

1. Player clicks "Rolle aufdecken" to reveal their role privately
2. IF the player is a spy AND spy images exist → random spy image is shown
3. IF the player is saboteur/teammember AND their images exist → random appropriate image
4. IF no images exist for that role → shows role-specific icon (safe fallback)

## Adding More Images

To add images for any role:

1. Add image files to the appropriate folder with naming convention (role_X.png)
2. Update the corresponding list in `lib/presentation/screens/role_reveal_screen.dart`:
   - `_spyImages` for spy images
   - `_saboteurImages` for saboteur images  
   - `_teammemberImages` for teammember images

## Current Status

- ✅ **Spies**: Have images (spy_1.png working)
- ⭕ **Saboteurs**: Show orange warning icon (safe - no spoilers)
- ⭕ **Team Members**: Show green group icon (safe - no spoilers)

## Image Requirements

- Format: PNG recommended
- Size: 200x200px to 500x500px
- Aspect ratio: Square preferred
- Style: Should match the game's theme and be appropriate for the role type
