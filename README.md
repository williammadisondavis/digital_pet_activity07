# Activity 07 - Digital Pet

Student: Will Davis  
Pathway: Undergraduate

This project is a digital pet app made with Flutter. The user can name their pet, feed it, play with it, pause the game, restart the game, and watch the pet's happiness and hunger change over time.

## Main Features

The pet has a happiness meter and hunger meter that both stay between 0 and 100. The pet can also be given a custom name.

The Feed button lowers hunger and changes happiness. The Play button increases happiness but also makes the pet more hungry.

Hunger automatically increases by 5 every 30 seconds.

The pet's mood is based on happiness:

- Below 30 = Sad and red
- 30 through 70 = Content and yellow
- Above 70 = Happy and green

The pet also has a text mood label so the mood is not communicated by color alone.

The player wins if the pet stays above 80 happiness for three continuous minutes.

The game ends in a loss if hunger reaches 100 while happiness is 10 or lower.

After a win or loss, the care buttons are disabled until the game is restarted.

## Advanced Features

For my first advanced feature, I added session controls. The user can pause and resume the game. When the game is paused, the timers stop and the Feed and Play buttons cannot be used. When the game resumes, the hunger timer starts again.

For my second advanced feature, I added visual polish and accessible motion. The pet has a small animation when it is fed or played with, the meter changes are animated, and reaction emojis appear after actions. The pet also changes slightly in size depending on its mood. The app checks the device's reduced-motion setting so unnecessary animations can be disabled.

## Testing

I tested the main state boundaries of the app.

Happiness 29 showed the pet as Sad and red.

Happiness 30 showed the pet as Content and yellow.

Happiness 70 showed the pet as Content and yellow.

Happiness 71 showed the pet as Happy and green.

I also tested that happiness and hunger stay between 0 and 100.

The pause and resume controls worked correctly.

The win condition was tested by temporarily shortening the three-minute timer during development and then restoring it to three minutes.

The game-over condition was tested with hunger at 100 and happiness at 10 or lower.

Restart returned the pet to its starting values.

The production version uses a 30-second hunger timer and a three-minute win timer.

## Starting Values

Happiness: 60  
Hunger: 40

## Asset Information

Pet image source: PNGWing  
Source page: https://www.pngwing.com/en/free-png-dktxz

Usage information shown on source page: Non-commercial use, DMCA.

The image is being used only for this non-commercial class project.

## Running the Project

Get the Flutter packages:

flutter pub get

Run the app:

flutter run

Check the project:

flutter analyze

Run tests:

flutter test

Build the release APK:

flutter build apk --release

## GitHub Work

I used separate branches for the main parts of the project.

The `care-systems` branch was used for the pet state, Feed and Play actions, meters, timers, game rules, and reset behavior.

The `pet-personality` branch was used for the pause and resume controls, visual feedback, animations, and accessibility features.

I completed this version individually because I was absent from the in-class team activity. I used the assignment's separate workstream structure, but I am not claiming that another student completed work or reviewed my project.