import 'models/exercise.dart';
import 'models/workout.dart';

class DemoRepository {
  DemoRepository._();

  /// User-provided FitWithSaju exercise catalog (v14).
  /// Metadata and instructions are sourced from assets/exercises/data/exercises.json.
  static const exercises = <Exercise>[
    Exercise(
      id: '2ORFMoR',
      name: 'Hack Calf Raise',
      targetMuscles: <String>['calves'],
      bodyParts: <String>['lower legs'],
      equipments: <String>['sled machine'],
      secondaryMuscles: <String>['hamstrings', 'glutes'],
      instructionSteps: <String>[
        'Step:1 Adjust the sled machine to a comfortable weight.',
        'Step:2 Stand on the sled machine with your toes on the platform and your heels hanging off.',
        'Step:3 Hold onto the handles for stability.',
        'Step:4 Raise your heels as high as possible by pushing through the balls of your feet.',
        'Step:5 Pause for a moment at the top, then slowly lower your heels back down to the starting position.',
        'Step:6 Repeat for the desired number of repetitions.'
      ],
      thumbnailAsset: 'assets/exercises/thumbs/2ORFMoR.gif',
      mediaAsset: 'assets/exercises/media/2ORFMoR.gif',
    ),
    Exercise(
      id: '2Qh2J1e',
      name: 'Sled 45° Leg Press (side Pov)',
      targetMuscles: <String>['glutes'],
      bodyParts: <String>['upper legs'],
      equipments: <String>['sled machine'],
      secondaryMuscles: <String>['quadriceps', 'hamstrings', 'calves'],
      instructionSteps: <String>[
        'Step:1 Adjust the seat of the sled machine so that your knees are at a 90-degree angle when your feet are on the footplate.',
        'Step:2 Sit on the sled machine with your back flat against the backrest and your feet shoulder-width apart on the footplate.',
        'Step:3 Grip the handles on the sides of the seat for stability.',
        'Step:4 Push against the footplate to extend your legs, straightening them completely.',
        'Step:5 Pause for a moment at the top, then slowly bend your knees to lower the footplate back to the starting position.',
        'Step:6 Repeat for the desired number of repetitions.'
      ],
      thumbnailAsset: 'assets/exercises/thumbs/2Qh2J1e.gif',
      mediaAsset: 'assets/exercises/media/2Qh2J1e.gif',
    ),
    Exercise(
      id: '3eGE2JC',
      name: 'Dumbbell Front Raise',
      targetMuscles: <String>['delts'],
      bodyParts: <String>['shoulders'],
      equipments: <String>['dumbbell'],
      secondaryMuscles: <String>['biceps', 'trapezius'],
      instructionSteps: <String>[
        'Step:1 Stand with your feet shoulder-width apart, holding a dumbbell in each hand with your palms facing your thighs.',
        'Step:2 Keeping your arms straight, exhale and lift the dumbbells in front of you until they are at shoulder level.',
        'Step:3 Pause for a moment at the top, then inhale and slowly lower the dumbbells back down to the starting position.',
        'Step:4 Repeat for the desired number of repetitions.'
      ],
      thumbnailAsset: 'assets/exercises/thumbs/3eGE2JC.gif',
      mediaAsset: 'assets/exercises/media/3eGE2JC.gif',
    ),
    Exercise(
      id: '3tAXPQ6',
      name: 'Dumbbell Over Bench Revers Wrist Curl',
      targetMuscles: <String>['forearms'],
      bodyParts: <String>['lower arms'],
      equipments: <String>['dumbbell'],
      secondaryMuscles: <String>['biceps', 'brachialis'],
      instructionSteps: <String>[
        'Step:1 Sit on a bench with your feet flat on the ground and hold a dumbbell in each hand, palms facing down.',
        'Step:2 Rest your forearms on the bench, allowing your wrists to hang off the edge.',
        'Step:3 Slowly curl your wrists upward, bringing the dumbbells towards your body.',
        'Step:4 Pause for a moment at the top, then slowly lower the dumbbells back down to the starting position.',
        'Step:5 Repeat for the desired number of repetitions.'
      ],
      thumbnailAsset: 'assets/exercises/thumbs/3tAXPQ6.gif',
      mediaAsset: 'assets/exercises/media/3tAXPQ6.gif',
    ),
    Exercise(
      id: '3TZduzM',
      name: 'Barbell Incline Bench Press',
      targetMuscles: <String>['pectorals'],
      bodyParts: <String>['chest'],
      equipments: <String>['barbell'],
      secondaryMuscles: <String>['shoulders', 'triceps'],
      instructionSteps: <String>[
        'Step:1 Set up an incline bench at a 45-degree angle.',
        'Step:2 Lie down on the bench with your feet flat on the ground.',
        'Step:3 Grasp the barbell with an overhand grip, slightly wider than shoulder-width apart.',
        'Step:4 Unrack the barbell and lower it slowly towards your chest, keeping your elbows at a 45-degree angle.',
        'Step:5 Pause for a moment at the bottom, then push the barbell back up to the starting position.',
        'Step:6 Repeat for the desired number of repetitions.'
      ],
      thumbnailAsset: 'assets/exercises/thumbs/3TZduzM.gif',
      mediaAsset: 'assets/exercises/media/3TZduzM.gif',
    ),
    Exercise(
      id: '3XFdb1Z',
      name: 'Cable Squatting Curl',
      targetMuscles: <String>['biceps'],
      bodyParts: <String>['upper arms'],
      equipments: <String>['cable'],
      secondaryMuscles: <String>['forearms'],
      instructionSteps: <String>[
        'Step:1 Attach a cable handle to the lowest setting on a cable machine.',
        'Step:2 Stand facing the machine with your feet shoulder-width apart.',
        'Step:3 Hold the cable handle with an underhand grip, palms facing up, and arms fully extended.',
        'Step:4 Lower your body into a squat position, keeping your back straight and knees behind your toes.',
        'Step:5 As you squat down, curl the cable handle towards your shoulders, keeping your elbows close to your sides.',
        'Step:6 Pause for a moment at the top of the curl, squeezing your biceps.',
        'Step:7 Slowly lower the cable handle back to the starting position, fully extending your arms.',
        'Step:8 Repeat for the desired number of repetitions.'
      ],
      thumbnailAsset: 'assets/exercises/thumbs/3XFdb1Z.gif',
      mediaAsset: 'assets/exercises/media/3XFdb1Z.gif',
    ),
    Exercise(
      id: '4dF3maG',
      name: 'Dumbbell One Arm Hammer Preacher Curl',
      targetMuscles: <String>['biceps'],
      bodyParts: <String>['upper arms'],
      equipments: <String>['dumbbell'],
      secondaryMuscles: <String>['forearms'],
      instructionSteps: <String>[
        'Step:1 Sit on a preacher bench with a dumbbell in one hand and your upper arm resting on the pad.',
        'Step:2 Hold the dumbbell with a neutral grip (palms facing your body).',
        'Step:3 Keeping your upper arm stationary, exhale and curl the dumbbell up towards your shoulder.',
        'Step:4 Pause for a moment at the top, squeezing your biceps.',
        'Step:5 Inhale and slowly lower the dumbbell back to the starting position.',
        'Step:6 Repeat for the desired number of repetitions, then switch arms.'
      ],
      thumbnailAsset: 'assets/exercises/thumbs/4dF3maG.gif',
      mediaAsset: 'assets/exercises/media/4dF3maG.gif',
    ),
    Exercise(
      id: '4dUn2iv',
      name: 'Barbell Standing Close Grip Curl',
      targetMuscles: <String>['biceps'],
      bodyParts: <String>['upper arms'],
      equipments: <String>['barbell'],
      secondaryMuscles: <String>['forearms'],
      instructionSteps: <String>[
        'Step:1 Stand up straight with your feet shoulder-width apart and hold a barbell with an underhand grip, hands close together.',
        'Step:2 Keep your elbows close to your torso and your upper arms stationary throughout the movement.',
        'Step:3 Exhale as you curl the weights while contracting your biceps. Continue to raise the bar until your biceps are fully contracted and the bar is at shoulder level.',
        'Step:4 Hold the contracted position for a brief pause as you squeeze your biceps.',
        'Step:5 Inhale as you slowly begin to bring the barbell back to the starting position.',
        'Step:6 Repeat for the desired number of repetitions.'
      ],
      thumbnailAsset: 'assets/exercises/thumbs/4dUn2iv.gif',
      mediaAsset: 'assets/exercises/media/4dUn2iv.gif',
    ),
    Exercise(
      id: '5bpPTHv',
      name: 'Kettlebell Pistol Squat',
      targetMuscles: <String>['glutes'],
      bodyParts: <String>['upper legs'],
      equipments: <String>['kettlebell'],
      secondaryMuscles: <String>['quadriceps', 'hamstrings', 'calves'],
      instructionSteps: <String>[
        'Step:1 Stand with your feet shoulder-width apart, holding a kettlebell in front of your chest with both hands.',
        'Step:2 Lift your left foot off the ground and extend it forward, keeping it parallel to the ground.',
        'Step:3 Slowly lower your body down into a squat position, keeping your right foot flat on the ground and your left leg extended.',
        'Step:4 Pause for a moment at the bottom of the squat, then push through your right heel to return to the starting position.',
        'Step:5 Repeat for the desired number of repetitions, then switch legs.'
      ],
      thumbnailAsset: 'assets/exercises/thumbs/5bpPTHv.gif',
      mediaAsset: 'assets/exercises/media/5bpPTHv.gif',
    ),
    Exercise(
      id: '05Cf2v8',
      name: 'Impossible Dips',
      targetMuscles: <String>['triceps'],
      bodyParts: <String>['upper arms'],
      equipments: <String>['body weight'],
      secondaryMuscles: <String>['chest', 'shoulders'],
      instructionSteps: <String>[
        'Step:1 Position yourself between two parallel bars with your arms fully extended and your body suspended in the air.',
        'Step:2 Bend your knees and cross your ankles.',
        'Step:3 Lower your body by bending your elbows until your upper arms are parallel to the ground.',
        'Step:4 Pause for a moment, then push yourself back up to the starting position by straightening your arms.',
        'Step:5 Repeat for the desired number of repetitions.'
      ],
      thumbnailAsset: 'assets/exercises/thumbs/05Cf2v8.gif',
      mediaAsset: 'assets/exercises/media/05Cf2v8.gif',
    ),
    Exercise(
      id: '5uFK1xr',
      name: 'Barbell Seated Overhead Triceps Extension',
      targetMuscles: <String>['triceps'],
      bodyParts: <String>['upper arms'],
      equipments: <String>['barbell'],
      secondaryMuscles: <String>['shoulders'],
      instructionSteps: <String>[
        'Step:1 Sit on a bench with your back straight and feet flat on the ground.',
        'Step:2 Hold a barbell with an overhand grip, hands shoulder-width apart, and raise it overhead.',
        'Step:3 Lower the barbell behind your head by bending your elbows, keeping your upper arms close to your head.',
        'Step:4 Pause for a moment, then extend your arms to raise the barbell back to the starting position.',
        'Step:5 Repeat for the desired number of repetitions.'
      ],
      thumbnailAsset: 'assets/exercises/thumbs/5uFK1xr.gif',
      mediaAsset: 'assets/exercises/media/5uFK1xr.gif',
    ),
    Exercise(
      id: '5v7KYld',
      name: 'Smith Incline Bench Press',
      targetMuscles: <String>['pectorals'],
      bodyParts: <String>['chest'],
      equipments: <String>['smith machine'],
      secondaryMuscles: <String>['shoulders', 'triceps'],
      instructionSteps: <String>[
        'Step:1 Adjust the bench to a 30-45 degree incline.',
        'Step:2 Sit on the bench with your back flat against the pad and feet firmly on the ground.',
        'Step:3 Grasp the barbell with an overhand grip slightly wider than shoulder-width apart.',
        'Step:4 Unrack the barbell and lower it slowly towards your upper chest, keeping your elbows slightly tucked in.',
        'Step:5 Pause for a moment at the bottom, then push the barbell back up to the starting position, fully extending your arms.',
        'Step:6 Repeat for the desired number of repetitions.'
      ],
      thumbnailAsset: 'assets/exercises/thumbs/5v7KYld.gif',
      mediaAsset: 'assets/exercises/media/5v7KYld.gif',
    ),
    Exercise(
      id: '6bOA1Oi',
      name: 'Weighted Side Bend (on Stability Ball)',
      targetMuscles: <String>['abs'],
      bodyParts: <String>['waist'],
      equipments: <String>['weighted'],
      secondaryMuscles: <String>['obliques', 'lower back'],
      instructionSteps: <String>[
        'Step:1 Sit on a stability ball with your feet shoulder-width apart and flat on the ground.',
        'Step:2 Hold a weight in one hand and place your other hand on your hip.',
        'Step:3 Engage your core and slowly bend sideways towards the weighted side, keeping your back straight.',
        'Step:4 Pause for a moment at the bottom, then slowly return to the starting position.',
        'Step:5 Repeat for the desired number of repetitions, then switch sides.'
      ],
      thumbnailAsset: 'assets/exercises/thumbs/6bOA1Oi.gif',
      mediaAsset: 'assets/exercises/media/6bOA1Oi.gif',
    ),
    Exercise(
      id: '6cKQC5E',
      name: 'Dumbbell One Arm Upright Row',
      targetMuscles: <String>['delts'],
      bodyParts: <String>['shoulders'],
      equipments: <String>['dumbbell'],
      secondaryMuscles: <String>['traps', 'biceps'],
      instructionSteps: <String>[
        'Step:1 Stand with your feet shoulder-width apart, holding a dumbbell in one hand with an overhand grip.',
        'Step:2 Let the dumbbell hang at arm\'s length in front of your thighs, with your palm facing your body.',
        'Step:3 Keeping your back straight and your core engaged, exhale and lift the dumbbell straight up towards your chin, leading with your elbow.',
        'Step:4 Pause for a moment at the top, then inhale and slowly lower the dumbbell back down to the starting position.',
        'Step:5 Repeat for the desired number of repetitions, then switch to the other arm.'
      ],
      thumbnailAsset: 'assets/exercises/thumbs/6cKQC5E.gif',
      mediaAsset: 'assets/exercises/media/6cKQC5E.gif',
    ),
    Exercise(
      id: '6HiHHe0',
      name: 'Barbell Standing Rocking Leg Calf Raise',
      targetMuscles: <String>['calves'],
      bodyParts: <String>['lower legs'],
      equipments: <String>['barbell'],
      secondaryMuscles: <String>['hamstrings', 'quadriceps'],
      instructionSteps: <String>[
        'Step:1 Stand with your feet shoulder-width apart and hold a barbell across your upper back.',
        'Step:2 Raise your heels off the ground as high as possible, balancing on the balls of your feet.',
        'Step:3 Slowly lower your heels back down to the starting position.',
        'Step:4 Repeat for the desired number of repetitions.'
      ],
      thumbnailAsset: 'assets/exercises/thumbs/6HiHHe0.gif',
      mediaAsset: 'assets/exercises/media/6HiHHe0.gif',
    ),
    Exercise(
      id: '6kSxYnw',
      name: 'Barbell Wrist Curl V. 2',
      targetMuscles: <String>['forearms'],
      bodyParts: <String>['lower arms'],
      equipments: <String>['barbell'],
      secondaryMuscles: <String>['biceps', 'brachialis'],
      instructionSteps: <String>[
        'Step:1 Sit on a bench with your feet flat on the ground and your knees bent.',
        'Step:2 Hold a barbell with an underhand grip, palms facing up, and your hands shoulder-width apart.',
        'Step:3 Rest your forearms on your thighs, allowing your wrists to hang off the edge.',
        'Step:4 Slowly curl your wrists upward, bringing the barbell towards your forearms.',
        'Step:5 Pause for a moment at the top, then slowly lower the barbell back down to the starting position.',
        'Step:6 Repeat for the desired number of repetitions.'
      ],
      thumbnailAsset: 'assets/exercises/thumbs/6kSxYnw.gif',
      mediaAsset: 'assets/exercises/media/6kSxYnw.gif',
    ),
    Exercise(
      id: '6MfS53i',
      name: 'Dumbbell Lying Single Extension',
      targetMuscles: <String>['triceps'],
      bodyParts: <String>['upper arms'],
      equipments: <String>['dumbbell'],
      secondaryMuscles: <String>['shoulders'],
      instructionSteps: <String>[
        'Step:1 Lie flat on a bench with a dumbbell in one hand and your arm fully extended above your chest.',
        'Step:2 Lower the dumbbell in a controlled manner towards your forehead, keeping your upper arm stationary.',
        'Step:3 Pause briefly at the bottom of the movement, then extend your arm back to the starting position.',
        'Step:4 Repeat for the desired number of repetitions, then switch arms.'
      ],
      thumbnailAsset: 'assets/exercises/thumbs/6MfS53i.gif',
      mediaAsset: 'assets/exercises/media/6MfS53i.gif',
    ),
    Exercise(
      id: '6sMAmNv',
      name: 'Dumbbell Reverse Spider Curl',
      targetMuscles: <String>['biceps'],
      bodyParts: <String>['upper arms'],
      equipments: <String>['dumbbell'],
      secondaryMuscles: <String>['forearms'],
      instructionSteps: <String>[
        'Step:1 Stand up straight with a dumbbell in each hand, palms facing your body and arms fully extended.',
        'Step:2 Keeping your upper arms stationary, exhale and curl the weights while contracting your biceps.',
        'Step:3 Continue to raise the dumbbells until your biceps are fully contracted and the dumbbells are at shoulder level.',
        'Step:4 Hold the contracted position for a brief pause as you squeeze your biceps.',
        'Step:5 Inhale and slowly begin to lower the dumbbells back to the starting position.',
        'Step:6 Repeat for the desired number of repetitions.'
      ],
      thumbnailAsset: 'assets/exercises/thumbs/6sMAmNv.gif',
      mediaAsset: 'assets/exercises/media/6sMAmNv.gif',
    ),
    Exercise(
      id: '6sYyrRX',
      name: 'Bent Knee Lying Twist (male)',
      targetMuscles: <String>['glutes'],
      bodyParts: <String>['upper legs'],
      equipments: <String>['body weight'],
      secondaryMuscles: <String>['obliques', 'hip flexors'],
      instructionSteps: <String>[
        'Step:1 Lie flat on your back with your knees bent and feet flat on the ground.',
        'Step:2 Extend your arms out to the sides, perpendicular to your body.',
        'Step:3 Keeping your knees together, slowly lower them to one side, aiming to touch the ground with your knees.',
        'Step:4 Pause for a moment, then engage your core and slowly lift your knees back to the starting position.',
        'Step:5 Repeat the movement to the other side.',
        'Step:6 Continue alternating sides for the desired number of repetitions.'
      ],
      thumbnailAsset: 'assets/exercises/thumbs/6sYyrRX.gif',
      mediaAsset: 'assets/exercises/media/6sYyrRX.gif',
    ),
    Exercise(
      id: '7F1DVzn',
      name: 'Lever Front Pulldown',
      targetMuscles: <String>['lats'],
      bodyParts: <String>['back'],
      equipments: <String>['leverage machine'],
      secondaryMuscles: <String>['biceps', 'rhomboids', 'rear deltoids'],
      instructionSteps: <String>[
        'Step:1 Adjust the seat height and position yourself on the machine with your knees under the pads and your feet flat on the ground.',
        'Step:2 Grasp the handles with an overhand grip, slightly wider than shoulder-width apart.',
        'Step:3 Sit upright with your chest lifted and your shoulders back, maintaining a slight arch in your lower back.',
        'Step:4 Engage your lats and pull the handles down towards your chest, squeezing your shoulder blades together.',
        'Step:5 Pause for a moment at the bottom of the movement, then slowly release the handles back to the starting position.',
        'Step:6 Repeat for the desired number of repetitions.'
      ],
      thumbnailAsset: 'assets/exercises/thumbs/7F1DVzn.gif',
      mediaAsset: 'assets/exercises/media/7F1DVzn.gif',
    ),
    Exercise(
      id: '7I6LNUG',
      name: 'Lever Seated Row',
      targetMuscles: <String>['upper back'],
      bodyParts: <String>['back'],
      equipments: <String>['leverage machine'],
      secondaryMuscles: <String>['biceps', 'forearms'],
      instructionSteps: <String>[
        'Step:1 Adjust the seat height and footrests to a comfortable position.',
        'Step:2 Sit on the machine with your chest against the pad and your feet on the footrests.',
        'Step:3 Grasp the handles with an overhand grip, shoulder-width apart.',
        'Step:4 Keep your back straight and your core engaged.',
        'Step:5 Pull the handles towards your body, squeezing your shoulder blades together.',
        'Step:6 Pause for a moment at the peak of the movement.',
        'Step:7 Slowly release the handles and return to the starting position.',
        'Step:8 Repeat for the desired number of repetitions.'
      ],
      thumbnailAsset: 'assets/exercises/thumbs/7I6LNUG.gif',
      mediaAsset: 'assets/exercises/media/7I6LNUG.gif',
    ),
    Exercise(
      id: '7inpWch',
      name: 'Dumbbell Standing Concentration Curl',
      targetMuscles: <String>['biceps'],
      bodyParts: <String>['upper arms'],
      equipments: <String>['dumbbell'],
      secondaryMuscles: <String>['forearms'],
      instructionSteps: <String>[
        'Step:1 Stand with your feet shoulder-width apart and hold a dumbbell in one hand, with your arm fully extended and palm facing inwards.',
        'Step:2 Place your opposite hand on your thigh for support.',
        'Step:3 Keeping your upper arm stationary, exhale and curl the dumbbell towards your shoulder by contracting your biceps.',
        'Step:4 Continue to raise the dumbbell until your biceps are fully contracted and the dumbbell is at shoulder level.',
        'Step:5 Hold the contracted position for a brief pause as you squeeze your biceps.',
        'Step:6 Inhale and slowly lower the dumbbell back to the starting position.',
        'Step:7 Repeat for the desired number of repetitions, then switch arms.'
      ],
      thumbnailAsset: 'assets/exercises/thumbs/7inpWch.gif',
      mediaAsset: 'assets/exercises/media/7inpWch.gif',
    ),
    Exercise(
      id: '7saC5zz',
      name: 'Cable Decline Fly',
      targetMuscles: <String>['pectorals'],
      bodyParts: <String>['chest'],
      equipments: <String>['cable'],
      secondaryMuscles: <String>['shoulders', 'triceps'],
      instructionSteps: <String>[
        'Step:1 Adjust the cable machine to a decline position.',
        'Step:2 Stand facing away from the machine with your feet shoulder-width apart.',
        'Step:3 Hold the handles with your palms facing forward and your arms extended straight out in front of you.',
        'Step:4 Keeping a slight bend in your elbows, open your arms out to the sides in a controlled motion.',
        'Step:5 Pause for a moment at the fully extended position, then slowly return to the starting position.',
        'Step:6 Repeat for the desired number of repetitions.'
      ],
      thumbnailAsset: 'assets/exercises/thumbs/7saC5zz.gif',
      mediaAsset: 'assets/exercises/media/7saC5zz.gif',
    ),
    Exercise(
      id: '7zdxRTl',
      name: 'Smith Leg Press',
      targetMuscles: <String>['glutes'],
      bodyParts: <String>['upper legs'],
      equipments: <String>['smith machine'],
      secondaryMuscles: <String>['quadriceps', 'hamstrings', 'calves'],
      instructionSteps: <String>[
        'Step:1 Adjust the seat and footplate of the smith machine to a comfortable position.',
        'Step:2 Sit on the machine with your back against the backrest and your feet shoulder-width apart on the footplate.',
        'Step:3 Grasp the handles or sides of the machine for stability.',
        'Step:4 Push the footplate away from you by extending your legs, keeping your back against the backrest.',
        'Step:5 Pause for a moment at the fully extended position.',
        'Step:6 Slowly bend your knees and lower the footplate back towards you, returning to the starting position.',
        'Step:7 Repeat for the desired number of repetitions.'
      ],
      thumbnailAsset: 'assets/exercises/thumbs/7zdxRTl.gif',
      mediaAsset: 'assets/exercises/media/7zdxRTl.gif',
    ),
    Exercise(
      id: '8eqjhOl',
      name: 'Dumbbell Palms In Incline Bench Press',
      targetMuscles: <String>['triceps'],
      bodyParts: <String>['upper arms'],
      equipments: <String>['dumbbell'],
      secondaryMuscles: <String>['chest', 'shoulders'],
      instructionSteps: <String>[
        'Step:1 Set up an incline bench at a 45-degree angle.',
        'Step:2 Sit on the bench with your back against the backrest and feet flat on the ground.',
        'Step:3 Hold a dumbbell in each hand with an overhand grip, palms facing inwards.',
        'Step:4 Extend your arms straight up above your chest, keeping a slight bend in your elbows.',
        'Step:5 Lower the dumbbells slowly towards your shoulders, keeping your elbows close to your body.',
        'Step:6 Pause for a moment at the bottom, then press the dumbbells back up to the starting position.',
        'Step:7 Repeat for the desired number of repetitions.'
      ],
      thumbnailAsset: 'assets/exercises/thumbs/8eqjhOl.gif',
      mediaAsset: 'assets/exercises/media/8eqjhOl.gif',
    ),
    Exercise(
      id: '8K0w2yA',
      name: 'Assisted Hanging Knee Raise With Throw Down',
      targetMuscles: <String>['abs'],
      bodyParts: <String>['waist'],
      equipments: <String>['assisted'],
      secondaryMuscles: <String>['hip flexors', 'lower back'],
      instructionSteps: <String>[
        'Step:1 Hang from a pull-up bar with your arms fully extended and your palms facing away from you.',
        'Step:2 Engage your core and lift your knees towards your chest, keeping your legs together.',
        'Step:3 Once your knees are at chest level, explosively throw your legs down towards the ground, extending them fully.',
        'Step:4 Allow your legs to swing back up and repeat the movement for the desired number of repetitions.'
      ],
      thumbnailAsset: 'assets/exercises/thumbs/8K0w2yA.gif',
      mediaAsset: 'assets/exercises/media/8K0w2yA.gif',
    ),
    Exercise(
      id: '8oYqOt9',
      name: 'Cable Seated Curl',
      targetMuscles: <String>['biceps'],
      bodyParts: <String>['upper arms'],
      equipments: <String>['cable'],
      secondaryMuscles: <String>['forearms'],
      instructionSteps: <String>[
        'Step:1 Sit on a cable machine with your feet flat on the ground and your back straight.',
        'Step:2 Grasp the cable attachment with an underhand grip, palms facing up, and your arms fully extended.',
        'Step:3 Keeping your upper arms stationary, exhale and curl the cable attachment towards your shoulders, contracting your biceps.',
        'Step:4 Pause for a moment at the top of the movement, squeezing your biceps.',
        'Step:5 Inhale and slowly lower the cable attachment back to the starting position, fully extending your arms.',
        'Step:6 Repeat for the desired number of repetitions.'
      ],
      thumbnailAsset: 'assets/exercises/thumbs/8oYqOt9.gif',
      mediaAsset: 'assets/exercises/media/8oYqOt9.gif',
    ),
    Exercise(
      id: '8ozhUIZ',
      name: 'Barbell Standing Calf Raise',
      targetMuscles: <String>['calves'],
      bodyParts: <String>['lower legs'],
      equipments: <String>['barbell'],
      secondaryMuscles: <String>['hamstrings', 'glutes'],
      instructionSteps: <String>[
        'Step:1 Stand with your feet shoulder-width apart and place a barbell across your upper back.',
        'Step:2 Raise your heels off the ground as high as possible, using only your toes.',
        'Step:3 Pause for a moment at the top, then slowly lower your heels back down to the starting position.',
        'Step:4 Repeat for the desired number of repetitions.'
      ],
      thumbnailAsset: 'assets/exercises/thumbs/8ozhUIZ.gif',
      mediaAsset: 'assets/exercises/media/8ozhUIZ.gif',
    ),
    Exercise(
      id: '8urJS9b',
      name: 'Weighted Hyperextension (on Stability Ball)',
      targetMuscles: <String>['spine'],
      bodyParts: <String>['back'],
      equipments: <String>['weighted'],
      secondaryMuscles: <String>['glutes', 'hamstrings'],
      instructionSteps: <String>[
        'Step:1 Position yourself face down on a stability ball with your hips resting on the ball and your feet against a wall for stability.',
        'Step:2 Place your hands behind your head or cross them over your chest.',
        'Step:3 Engage your core and slowly lift your upper body off the ball, extending your back until your body forms a straight line.',
        'Step:4 Pause for a moment at the top, then slowly lower your upper body back down to the starting position.',
        'Step:5 Repeat for the desired number of repetitions.'
      ],
      thumbnailAsset: 'assets/exercises/thumbs/8urJS9b.gif',
      mediaAsset: 'assets/exercises/media/8urJS9b.gif',
    ),
    Exercise(
      id: '8xUv4J7',
      name: 'Cable Seated Crunch',
      targetMuscles: <String>['abs'],
      bodyParts: <String>['waist'],
      equipments: <String>['cable'],
      secondaryMuscles: <String>['obliques'],
      instructionSteps: <String>[
        'Step:1 Sit on a cable machine with your feet flat on the ground and your knees bent.',
        'Step:2 Hold the cable handle with both hands and position it behind your head.',
        'Step:3 Engage your abs and slowly curl your upper body forward, bringing your chest towards your knees.',
        'Step:4 Pause for a moment at the top, then slowly return to the starting position.',
        'Step:5 Repeat for the desired number of repetitions.'
      ],
      thumbnailAsset: 'assets/exercises/thumbs/8xUv4J7.gif',
      mediaAsset: 'assets/exercises/media/8xUv4J7.gif',
    ),
  ];

  /// Kept only to resolve existing locally-saved v12/v13 plans and tests.
  /// These legacy records are intentionally not shown in the v14 Explore catalog.
  static const _legacyExercises = <Exercise>[
    Exercise(
      id: 'bench_press',
      name: 'Bench Press',
      targetMuscles: <String>['chest'],
      bodyParts: <String>['legacy'],
      equipments: <String>['barbell'],
      instructionSteps: <String>[],
    ),
    Exercise(
      id: 'incline_db_press',
      name: 'Incline Dumbbell Press',
      targetMuscles: <String>['upper chest'],
      bodyParts: <String>['legacy'],
      equipments: <String>['dumbbells'],
      instructionSteps: <String>[],
    ),
    Exercise(
      id: 'lat_pulldown',
      name: 'Lat Pulldown',
      targetMuscles: <String>['back'],
      bodyParts: <String>['legacy'],
      equipments: <String>['cable'],
      instructionSteps: <String>[],
    ),
    Exercise(
      id: 'shoulder_press',
      name: 'Shoulder Press',
      targetMuscles: <String>['shoulders'],
      bodyParts: <String>['legacy'],
      equipments: <String>['dumbbells'],
      instructionSteps: <String>[],
    ),
    Exercise(
      id: 'squat',
      name: 'Back Squat',
      targetMuscles: <String>['legs'],
      bodyParts: <String>['legacy'],
      equipments: <String>['barbell'],
      instructionSteps: <String>[],
    ),
    Exercise(
      id: 'biceps_curl',
      name: 'Dumbbell Curl',
      targetMuscles: <String>['biceps'],
      bodyParts: <String>['legacy'],
      equipments: <String>['dumbbells'],
      instructionSteps: <String>[],
    ),
  ];

  static const bodyPartCatalog = <String>[
    'neck',
    'lower arms',
    'shoulders',
    'cardio',
    'upper arms',
    'chest',
    'lower legs',
    'back',
    'upper legs',
    'waist'
  ];
  static const equipmentCatalog = <String>[
    'stepmill machine',
    'elliptical machine',
    'trap bar',
    'tire',
    'stationary bike',
    'wheel roller',
    'smith machine',
    'hammer',
    'skierg machine',
    'roller',
    'resistance band',
    'bosu ball',
    'weighted',
    'olympic barbell',
    'kettlebell',
    'upper body ergometer',
    'sled machine',
    'ez barbell',
    'dumbbell',
    'rope',
    'barbell',
    'band',
    'stability ball',
    'medicine ball',
    'assisted',
    'leverage machine',
    'cable',
    'body weight'
  ];
  static const muscleCatalog = <String>[
    'shins',
    'hands',
    'sternocleidomastoid',
    'soleus',
    'inner thighs',
    'lower abs',
    'grip muscles',
    'abdominals',
    'wrist extensors',
    'wrist flexors',
    'latissimus dorsi',
    'upper chest',
    'rotator cuff',
    'wrists',
    'groin',
    'brachialis',
    'deltoids',
    'feet',
    'ankles',
    'trapezius',
    'rear deltoids',
    'chest',
    'quadriceps',
    'back',
    'core',
    'shoulders',
    'ankle stabilizers',
    'rhomboids',
    'obliques',
    'lower back',
    'hip flexors',
    'levator scapulae',
    'abductors',
    'serratus anterior',
    'traps',
    'forearms',
    'delts',
    'biceps',
    'upper back',
    'spine',
    'cardiovascular system',
    'triceps',
    'adductors',
    'hamstrings',
    'glutes',
    'pectorals',
    'calves',
    'lats',
    'quads',
    'abs'
  ];

  static List<String> get availableBodyParts {
    final values = <String>{};
    for (final exercise in exercises) {
      values.addAll(exercise.bodyParts);
    }
    final result = values.toList()..sort();
    return result;
  }

  static List<String> get availableEquipments {
    final values = <String>{};
    for (final exercise in exercises) {
      values.addAll(exercise.equipments);
    }
    final result = values.toList()..sort();
    return result;
  }

  static Exercise? findExerciseById(String id) {
    for (final exercise in exercises) {
      if (exercise.id == id) {
        return exercise;
      }
    }
    for (final exercise in _legacyExercises) {
      if (exercise.id == id) {
        return exercise;
      }
    }
    return null;
  }

  static Workout get todaysWorkout {
    final selectedIds = <String>['3TZduzM', '3eGE2JC', '5uFK1xr', '8xUv4J7'];
    final selected =
        selectedIds.map(findExerciseById).whereType<Exercise>().toList();
    return Workout(
      id: 'push_day',
      title: 'Push Day',
      subtitle: 'Chest • Shoulders • Triceps • Core',
      durationMinutes: 45,
      exercises: selected,
    );
  }
}
