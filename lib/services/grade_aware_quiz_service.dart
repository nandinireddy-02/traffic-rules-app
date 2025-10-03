import 'package:flutter/material.dart';
import '../models/quiz.dart';

class GradeAwareQuizService extends ChangeNotifier {
  List<Quiz> _quizzes = [];
  List<Question> _allQuestions = [];
  Quiz? _currentQuiz;
  QuizResult? _lastResult;
  
  List<Quiz> get quizzes => _quizzes;
  Quiz? get currentQuiz => _currentQuiz;
  QuizResult? get lastResult => _lastResult;

  // Initialize with grade-appropriate sample data
  Future<void> initialize() async {
    await _loadGradeAppropriateQuestions();
    await _generateGradeSpecificQuizzes();
    notifyListeners();
  }

  // Load age-appropriate questions by grade level
  Future<void> _loadGradeAppropriateQuestions() async {
    _allQuestions = [
      // GRADE 2: Basic Traffic Light Meanings (Ages 7-8)
      Question(
        id: 'tl_g2_001',
        text: '🚦 What does the RED traffic light mean?',
        options: ['Go fast! 🏃‍♂️', 'Stop! ✋', 'Slow down 🐌', 'Turn around ↩️'],
        correctAnswerIndex: 1,
        explanation: 'Red light means STOP! Cars and people must wait until it changes. 🛑',
        topic: 'Basic Traffic Light Meanings',
        difficulty: 'easy',
        gradeLevel: [2],
      ),
      Question(
        id: 'tl_g2_002',
        text: '🚦 What does the GREEN traffic light mean?',
        options: ['Stop right now ✋', 'Go carefully! 👀', 'Sleep time 😴', 'Dance party 💃'],
        correctAnswerIndex: 1,
        explanation: 'Green light means GO! But always look both ways first for safety. 👀',
        topic: 'Basic Traffic Light Meanings',
        difficulty: 'easy',
        gradeLevel: [2],
      ),
      Question(
        id: 'tl_g2_003',
        text: '🚦 What does the YELLOW traffic light mean?',
        options: ['Speed up! 🏃‍♂️', 'Jump up and down! 🦘', 'Get ready to stop! ⚠️', 'Close your eyes 👀'],
        correctAnswerIndex: 2,
        explanation: 'Yellow light means "get ready to stop!" It\'s like a warning before red. ⏰',
        topic: 'Basic Traffic Light Meanings',
        difficulty: 'easy',
        gradeLevel: [2],
      ),
      Question(
        id: 'cross_g2_001',
        text: '🚶‍♀️ How do you cross the road safely?',
        options: ['Run fast across 🏃‍♀️', 'Look left, right, left again 👀', 'Close your eyes and walk 😵', 'Cross anywhere you want 🤷‍♀️'],
        correctAnswerIndex: 1,
        explanation: 'Always look LEFT, RIGHT, LEFT again before crossing. Make sure no cars are coming! 👀',
        topic: 'How to Cross the Road Safely',
        difficulty: 'easy',
        gradeLevel: [2],
      ),
      Question(
        id: 'cross_g2_002',
        text: '🚶‍♀️ Who should help you cross busy streets?',
        options: ['Your toy bear 🧸', 'A grown-up you trust 👨‍👩‍👧‍👦', 'Your friend only 👫', 'Nobody - do it alone 😤'],
        correctAnswerIndex: 1,
        explanation: 'Always ask a grown-up to help you cross busy streets. They can see better and keep you safe! 👨‍👩‍👧‍👦',
        topic: 'How to Cross the Road Safely',
        difficulty: 'easy',
        gradeLevel: [2],
      ),
      Question(
        id: 'stop_g2_001',
        text: '🛑 What shape is a STOP sign?',
        options: ['Round like a ball ⚽', 'Square like a box 📦', 'Eight sides like an octopus 🐙', 'Triangle like pizza 🍕'],
        correctAnswerIndex: 2,
        explanation: 'STOP signs have 8 sides (octagon) and are bright red with white letters! 🛑🐙',
        topic: 'Understanding STOP Signs',
        difficulty: 'easy',
        gradeLevel: [2],
      ),
      Question(
        id: 'stop_g2_002',
        text: '� What does a STOP sign tell drivers to do?',
        options: ['Go faster 🏃‍♂️', 'Stop completely and look 👀', 'Turn on music 🎵', 'Honk the horn 📯'],
        correctAnswerIndex: 1,
        explanation: 'STOP signs tell drivers to stop their car completely and look for people and other cars! 🛑',
        topic: 'Understanding STOP Signs',
        difficulty: 'easy',
        gradeLevel: [2],
      ),
      Question(
        id: 'stop_g2_003',
        text: '🛑 What color is a STOP sign?',
        options: ['Blue like the sky 💙', 'Green like grass 💚', 'Red like a fire truck 🚒', 'Yellow like the sun ☀️'],
        correctAnswerIndex: 2,
        explanation: 'STOP signs are bright RED so everyone can see them easily! Red means STOP! 🚒🛑',
        topic: 'Understanding STOP Signs',
        difficulty: 'easy',
        gradeLevel: [2],
      ),

      // GRADE 3: Basic Traffic Light Meanings, Road Crossing, STOP Signs (Ages 7-8)
      Question(
        id: 'tl_g3_001',
        text: '🚦 If you see a RED light, what should you do?',
        options: ['Keep walking 🚶‍♀️', 'Stop and wait ✋', 'Run across quickly 🏃‍♀️', 'Look at your phone 📱'],
        correctAnswerIndex: 1,
        explanation: 'When the light is RED, everyone must STOP and wait for it to turn GREEN! 🛑',
        topic: 'Basic Traffic Light Meanings',
        difficulty: 'easy',
        gradeLevel: [3],
      ),
      Question(
        id: 'tl_g3_002',
        text: '🚦 What should you do when the light turns GREEN?',
        options: ['Run as fast as you can 🏃‍♀️', 'Look both ways first, then go �', 'Wait for red light 🛑', 'Take a nap 😴'],
        correctAnswerIndex: 1,
        explanation: 'Even when it\'s GREEN, always look both ways first to make sure it\'s safe! 👀',
        topic: 'Basic Traffic Light Meanings',
        difficulty: 'easy',
        gradeLevel: [3],
      ),
      Question(
        id: 'cross_g3_001',
        text: '🚶‍♀️ What is the safest place to cross a street?',
        options: ['Anywhere you want 🤷‍♀️', 'At a crosswalk or corner 🎯', 'In the middle of the block 📍', 'Behind parked cars 🚗'],
        correctAnswerIndex: 1,
        explanation: 'Crosswalks and corners are the safest places because drivers expect to see people there! 🎯',
        topic: 'How to Cross the Road Safely',
        difficulty: 'easy',
        gradeLevel: [3],
      ),
      Question(
        id: 'cross_g3_002',
        text: '🚶‍♀️ Before crossing, what should you listen for?',
        options: ['Birds singing 🐦', 'Cars coming 🚗', 'Music playing 🎵', 'People talking 💬'],
        correctAnswerIndex: 1,
        explanation: 'Listen carefully for cars, trucks, or motorcycles that might be coming! 🚗👂',
        topic: 'How to Cross the Road Safely',
        difficulty: 'easy',
        gradeLevel: [3],
      ),
      Question(
        id: 'stop_g3_001',
        text: '🛑 Where do you usually see STOP signs?',
        options: ['In your bedroom 🛏️', 'At intersections where roads meet 🛣️', 'In the playground 🏀', 'At the grocery store 🛒'],
        correctAnswerIndex: 1,
        explanation: 'STOP signs are at intersections where roads meet so cars can take turns safely! �️',
        topic: 'Understanding STOP Signs',
        difficulty: 'easy',
        gradeLevel: [3],
      ),
      Question(
        id: 'stop_g3_002',
        text: '🛑 What should you do when you see a STOP sign while walking?',
        options: ['Ignore it completely 🙄', 'Stop and look for cars 👀', 'Take a photo 📸', 'Touch the sign 🤚'],
        correctAnswerIndex: 1,
        explanation: 'Even when walking, STOP signs remind us to stop and look for cars before crossing! 👀',
        topic: 'Understanding STOP Signs',
        difficulty: 'easy',
        gradeLevel: [3],
      ),

      // GRADE 2 VIDEO ENHANCED QUESTIONS - Traffic Lights Learning
      Question(
        id: 'tl_g2_video_001',
        text: '📺 Watch the Traffic Light Song! What do you do when you see RED? 🚦',
        options: ['🏃‍♀️ Run across!', '✋ STOP and wait!', '🚗 Drive faster!', '👀 Close my eyes!'],
        correctAnswerIndex: 1,
        explanation: 'RED means STOP! Just like in the song - we stop and stay safe! 🛑✨',
        topic: 'Video Learning',
        difficulty: 'easy',
        gradeLevel: [2],
        videoUrl: 'https://www.youtube.com/watch?v=0Rqw4krMOug',
        videoDescription: '🎵 Learn the Traffic Light Song! Red means STOP, Green means GO!',
      ),
      Question(
        id: 'tl_g2_video_002', 
        text: '📺 After watching the video, what does GREEN light tell cars to do? 🚦',
        options: ['🛑 Stop right now!', '⏰ Wait a little!', '🚗 Go carefully!', '📱 Use phone!'],
        correctAnswerIndex: 2,
        explanation: 'GREEN means GO! But cars must still be careful and watch for people. 🚗💚',
        topic: 'Video Learning',
        difficulty: 'easy',
        gradeLevel: [2],
        videoUrl: 'https://www.youtube.com/watch?v=b6UIZjG-fEE',
        videoDescription: '🚦 Learn how traffic lights keep everyone safe on the road!',
      ),
      Question(
        id: 'tl_g2_video_003',
        text: '📺 Watch how to cross the street safely! What should you do FIRST? 🚶‍♀️',
        options: ['🏃‍♀️ Run fast across!', '👀 Look both ways!', '📱 Play games!', '🎵 Sing loud songs!'],
        correctAnswerIndex: 1,
        explanation: 'Always look LEFT, RIGHT, LEFT again before crossing! Safety first! 👀✨',
        topic: 'Video Learning',
        difficulty: 'easy', 
        gradeLevel: [2],
        videoUrl: 'https://www.youtube.com/watch?v=lX6RRoyAVCg',
        videoDescription: '🚶‍♀️ Learn the safe way to cross streets with grown-ups!',
      ),
      Question(
        id: 'tl_g2_video_004',
        text: '📺 Watch about STOP signs! What shape is a STOP sign? 🛑',
        options: ['🔵 Circle like a ball!', '🔺 Triangle like pizza!', '🛑 8 sides like octopus!', '⭐ Star like twinkle!'],
        correctAnswerIndex: 2,
        explanation: 'STOP signs have 8 sides like an octopus! They\'re red and say STOP! 🛑🐙',
        topic: 'Video Learning',
        difficulty: 'easy',
        gradeLevel: [2],
        videoUrl: 'https://www.youtube.com/watch?v=SYc8gjcrB-4',
        videoDescription: '🛑 Learn about different traffic signs and what they mean!',
      ),
      Question(
        id: 'tl_g2_video_005',
        text: '📺 Watch about seatbelts! Why do we wear seatbelts in the car? 🚗',
        options: ['🎀 To look pretty!', '🛡️ To stay safe!', '🎮 To play games!', '🍎 To eat snacks!'],
        correctAnswerIndex: 1,
        explanation: 'Seatbelts are like superhero belts that keep us safe in cars! 🦸‍♀️🚗',
        topic: 'Video Learning',
        difficulty: 'easy',
        gradeLevel: [2],
        videoUrl: 'https://www.youtube.com/watch?v=kUjKxtJd0Wk',
        videoDescription: '🚗 Learn why seatbelts are important for staying safe in cars!',
      ),

      // GRADE 4-5: Pedestrian Crossing Rules, School Zone Safety, Bicycle Safety Basics (Ages 9-10)
      Question(
        id: 'ped_g45_001',
        text: '🚶‍♀️ What is the safest way to cross at a crosswalk?',
        options: ['Run across quickly 🏃‍♀️', 'Wait for the walk signal, look both ways, then walk 🚦👀', 'Cross when cars are coming 🚗', 'Cross while looking at your phone �'],
        correctAnswerIndex: 1,
        explanation: 'Wait for the WALK signal, look both ways even with the signal, then walk across steadily.',
        topic: 'Pedestrian Crossing Rules',
        difficulty: 'medium',
        gradeLevel: [4, 5],
      ),
      Question(
        id: 'ped_g45_002',
        text: '🚶‍♀️ What should you do if the DON\'T WALK signal starts flashing while you\'re crossing?',
        options: ['Run back to where you started 🏃‍♀️', 'Stop in the middle of the street 🛑', 'Continue walking quickly to the other side 🚶‍♀️', 'Sit down and wait 🪑'],
        correctAnswerIndex: 2,
        explanation: 'If you\'re already crossing, continue walking quickly but safely to the other side. Don\'t run back!',
        topic: 'Pedestrian Crossing Rules',
        difficulty: 'medium',
        gradeLevel: [4, 5],
      ),
      Question(
        id: 'ped_g45_003',
        text: '🚶‍♀️ Why should you make eye contact with drivers before crossing?',
        options: ['To say hello 👋', 'To make sure they see you 👀', 'To ask them questions 🤔', 'To take a photo 📸'],
        correctAnswerIndex: 1,
        explanation: 'Making eye contact with drivers helps ensure they see you and will stop for you to cross safely.',
        topic: 'Pedestrian Crossing Rules',
        difficulty: 'medium',
        gradeLevel: [4, 5],
      ),
      Question(
        id: 'school_g45_001',
        text: '🏫 What should drivers do in a school zone during school hours?',
        options: ['Drive faster to get through quickly 🏃‍♀️', 'Drive slower and watch for children 🐌👀', 'Honk their horn loudly 📯', 'Use their phone 📱'],
        correctAnswerIndex: 1,
        explanation: 'School zones have lower speed limits and drivers must be extra careful to watch for children.',
        topic: 'School Zone Safety',
        difficulty: 'medium',
        gradeLevel: [4, 5],
      ),
      Question(
        id: 'school_g45_002',
        text: '🏫 What are school crossing guards there to do?',
        options: ['Direct traffic only 🚗', 'Help students cross safely 🚸', 'Give out homework 📚', 'Clean the street 🧹'],
        correctAnswerIndex: 1,
        explanation: 'School crossing guards help students cross the street safely by stopping traffic when needed.',
        topic: 'School Zone Safety',
        difficulty: 'easy',
        gradeLevel: [4, 5],
      ),
      Question(
        id: 'school_g45_003',
        text: '🏫 When is it safest to walk to school?',
        options: ['In the dark without lights 🌙', 'With bright clothing and a trusted adult or friend 🌟👫', 'While running in the street 🏃‍♀️', 'While wearing headphones with loud music 🎧'],
        correctAnswerIndex: 1,
        explanation: 'Bright clothing helps drivers see you, and walking with others is always safer than walking alone.',
        topic: 'School Zone Safety',
        difficulty: 'medium',
        gradeLevel: [4, 5],
      ),
      Question(
        id: 'bike_g45_001',
        text: '🚲 What is the most important safety gear when riding a bicycle?',
        options: ['Cool sunglasses 😎', 'A properly fitted helmet ⛑️', 'Fancy gloves 🧤', 'A bell 🔔'],
        correctAnswerIndex: 1,
        explanation: 'A properly fitted helmet is the most important safety gear - it protects your head in case of falls.',
        topic: 'Bicycle Safety Basics',
        difficulty: 'easy',
        gradeLevel: [4, 5],
      ),
      Question(
        id: 'bike_g45_002',
        text: '🚲 Where should you ride your bicycle?',
        options: ['On the sidewalk with pedestrians 🚶‍♀️', 'In bike lanes or on the right side of the road 🛣️', 'In the middle of busy roads 🚗', 'Anywhere you want 🤷‍♀️'],
        correctAnswerIndex: 1,
        explanation: 'Bicycles should use bike lanes when available, or ride on the right side of the road with traffic.',
        topic: 'Bicycle Safety Basics',
        difficulty: 'medium',
        gradeLevel: [4, 5],
      ),
      Question(
        id: 'bike_g45_003',
        text: '🚲 What should you do before turning on your bicycle?',
        options: ['Just turn without looking 🔄', 'Look behind you and signal with your hand 👀✋', 'Ring your bell loudly 🔔', 'Close your eyes and hope 😵'],
        correctAnswerIndex: 1,
        explanation: 'Always look behind you for cars and signal with your hand to let others know where you\'re going.',
        topic: 'Bicycle Safety Basics',
        difficulty: 'medium',
        gradeLevel: [4, 5],
      ),

      // GRADE 6-7: Road Signs, Traffic Rules for Cyclists, Understanding Traffic Flow (Ages 11-12)
      Question(
        id: 'signs_g67_001',
        text: '🛑 What does a red octagonal sign with white letters mean?',
        options: ['Slow down', 'Yield to other traffic', 'Stop completely', 'Merge carefully'],
        correctAnswerIndex: 2,
        explanation: 'A red octagonal (8-sided) sign always means STOP completely, look both ways, then proceed when safe.',
        topic: 'Road Signs and Their Meanings',
        difficulty: 'easy',
        gradeLevel: [6, 7],
      ),
      Question(
        id: 'signs_g67_002',
        text: '⚠️ What do yellow diamond-shaped signs usually indicate?',
        options: ['Construction zones', 'Warning of hazards ahead', 'Speed limit changes', 'No parking zones'],
        correctAnswerIndex: 1,
        explanation: 'Yellow diamond signs are warning signs that alert drivers to potential hazards like curves, hills, or crossings.',
        topic: 'Road Signs and Their Meanings',
        difficulty: 'medium',
        gradeLevel: [6, 7],
      ),
      Question(
        id: 'signs_g67_003',
        text: '🚸 What does a yellow sign with children crossing symbols mean?',
        options: ['Children play area', 'School zone - watch for children', 'Daycare center nearby', 'Children\'s hospital'],
        correctAnswerIndex: 1,
        explanation: 'This sign warns drivers to slow down and watch carefully for children who may be crossing the street.',
        topic: 'Road Signs and Their Meanings',
        difficulty: 'medium',
        gradeLevel: [6, 7],
      ),
      Question(
        id: 'signs_g67_004',
        text: '📍 What do white rectangular signs usually tell you?',
        options: ['Warnings about dangers', 'Rules and regulations', 'Distance to cities', 'Construction information'],
        correctAnswerIndex: 1,
        explanation: 'White rectangular signs show rules and regulations like speed limits, no parking, or lane restrictions.',
        topic: 'Road Signs and Their Meanings',
        difficulty: 'medium',
        gradeLevel: [6, 7],
      ),
      Question(
        id: 'cycle_g67_001',
        text: '🚲 When cycling on the road, which direction should you travel?',
        options: ['Against traffic to see cars coming', 'With traffic in the same direction', 'Either direction is fine', 'Only on sidewalks'],
        correctAnswerIndex: 1,
        explanation: 'Bicycles must travel WITH traffic, not against it. This makes you more predictable to drivers.',
        topic: 'Traffic Rules for Young Cyclists',
        difficulty: 'medium',
        gradeLevel: [6, 7],
      ),
      Question(
        id: 'cycle_g67_002',
        text: '🚲 What should you do when approaching a stop sign on your bicycle?',
        options: ['Slow down but keep going', 'Stop completely, just like a car would', 'Ring your bell and continue', 'Ride around it'],
        correctAnswerIndex: 1,
        explanation: 'Bicycles must follow the same traffic rules as cars - stop completely at stop signs.',
        topic: 'Traffic Rules for Young Cyclists',
        difficulty: 'medium',
        gradeLevel: [6, 7],
      ),
      Question(
        id: 'cycle_g67_003',
        text: '🚲 How should you signal a right turn while cycling?',
        options: ['Point your left arm down', 'Point your right arm out to the right', 'Ring your bell twice', 'No signal needed'],
        correctAnswerIndex: 1,
        explanation: 'Point your right arm straight out to the right to signal a right turn. Make sure drivers can see you!',
        topic: 'Traffic Rules for Young Cyclists',
        difficulty: 'medium',
        gradeLevel: [6, 7],
      ),
      Question(
        id: 'flow_g67_001',
        text: '🚗 What is traffic flow?',
        options: ['How fast cars go', 'How cars move together on roads', 'The number of cars on the road', 'When traffic lights change'],
        correctAnswerIndex: 1,
        explanation: 'Traffic flow is how vehicles move together smoothly and safely on roads, like a river flowing.',
        topic: 'Understanding Traffic Flow',
        difficulty: 'medium',
        gradeLevel: [6, 7],
      ),
      Question(
        id: 'flow_g67_002',
        text: '🚗 Why do roads have multiple lanes?',
        options: ['To make roads look bigger', 'To allow different speeds and turning movements', 'To confuse drivers', 'To use more paint'],
        correctAnswerIndex: 1,
        explanation: 'Multiple lanes help traffic flow by separating faster/slower traffic and allowing for turns.',
        topic: 'Understanding Traffic Flow',
        difficulty: 'medium',
        gradeLevel: [6, 7],
      ),
      Question(
        id: 'flow_g67_003',
        text: '🚗 What causes traffic jams?',
        options: ['Too many cars for the road to handle smoothly', 'Cars going too slowly', 'Too many traffic lights', 'Bad weather only'],
        correctAnswerIndex: 0,
        explanation: 'Traffic jams happen when there are more cars than the road can handle smoothly, causing backups.',
        topic: 'Understanding Traffic Flow',
        difficulty: 'medium',
        gradeLevel: [6, 7],
      ),

      // GRADE 8-10: Advanced Traffic Laws, Driver's Education Prep, Road Infrastructure (Ages 13-15)
      Question(
        id: 'adv_g810_001',
        text: '🚗 What is the legal following distance behind another vehicle in good weather?',
        options: ['1 second', '2-3 seconds', '5 seconds', '10 seconds'],
        correctAnswerIndex: 1,
        explanation: 'The 2-3 second rule gives you enough time to stop safely if the car ahead brakes suddenly.',
        topic: 'Advanced Traffic Laws',
        difficulty: 'hard',
        gradeLevel: [8, 9, 10],
      ),
      Question(
        id: 'adv_g810_002',
        text: '🚗 What does yielding the right-of-way mean?',
        options: ['Going first always', 'Letting other traffic go first when required by law', 'Honking your horn', 'Driving faster'],
        correctAnswerIndex: 1,
        explanation: 'Yielding means giving the legal right to go first to other vehicles, pedestrians, or cyclists as required by traffic laws.',
        topic: 'Advanced Traffic Laws',
        difficulty: 'hard',
        gradeLevel: [8, 9, 10],
      ),
      Question(
        id: 'adv_g810_003',
        text: '🚗 When are you legally required to use headlights?',
        options: ['Only at night', '30 minutes before sunset to 30 minutes after sunrise', 'Only in rain', 'Whenever you want'],
        correctAnswerIndex: 1,
        explanation: 'Most states require headlights from 30 minutes before sunset to 30 minutes after sunrise, and in poor weather.',
        topic: 'Advanced Traffic Laws',
        difficulty: 'hard',
        gradeLevel: [8, 9, 10],
      ),
      Question(
        id: 'driver_g810_001',
        text: '🎓 At what age can you typically get a learner\'s permit?',
        options: ['13-14 years old', '15-16 years old', '17-18 years old', '21 years old'],
        correctAnswerIndex: 1,
        explanation: 'Most states allow learner\'s permits between ages 15-16, but requirements vary by state.',
        topic: 'Preparing for Driver\'s Education',
        difficulty: 'medium',
        gradeLevel: [8, 9, 10],
      ),
      Question(
        id: 'driver_g810_002',
        text: '🎓 What is the purpose of a learner\'s permit?',
        options: ['To drive alone immediately', 'To practice driving with a licensed adult', 'To drive to school only', 'To drive at night only'],
        correctAnswerIndex: 1,
        explanation: 'A learner\'s permit allows you to practice driving under supervision of a licensed adult driver.',
        topic: 'Preparing for Driver\'s Education',
        difficulty: 'medium',
        gradeLevel: [8, 9, 10],
      ),
      Question(
        id: 'driver_g810_003',
        text: '🎓 What skills should you practice before taking a driving test?',
        options: ['Only parallel parking', 'Parking, turning, signaling, and following traffic laws', 'Only highway driving', 'Only night driving'],
        correctAnswerIndex: 1,
        explanation: 'Driving tests cover basic skills like parking, turning, proper signaling, and following all traffic laws safely.',
        topic: 'Preparing for Driver\'s Education',
        difficulty: 'medium',
        gradeLevel: [8, 9, 10],
      ),
      Question(
        id: 'infra_g810_001',
        text: '🏗️ What is the purpose of traffic lights at intersections?',
        options: ['To make roads colorful', 'To control traffic flow and prevent accidents', 'To slow down all traffic', 'To generate electricity'],
        correctAnswerIndex: 1,
        explanation: 'Traffic lights control the flow of traffic at intersections, giving each direction a turn to go safely.',
        topic: 'Understanding Road Infrastructure',
        difficulty: 'medium',
        gradeLevel: [8, 9, 10],
      ),
      Question(
        id: 'infra_g810_002',
        text: '🏗️ Why do highways have multiple lanes?',
        options: ['To look more impressive', 'To allow for different speeds and reduce traffic congestion', 'To use more materials', 'To confuse drivers'],
        correctAnswerIndex: 1,
        explanation: 'Multiple lanes allow faster and slower traffic to coexist, and provide space for passing and merging.',
        topic: 'Understanding Road Infrastructure',
        difficulty: 'medium',
        gradeLevel: [8, 9, 10],
      ),
      Question(
        id: 'infra_g810_003',
        text: '🏗️ What are rumble strips designed to do?',
        options: ['Make noise for fun', 'Alert drivers when they\'re leaving their lane', 'Slow down all traffic', 'Mark parking spots'],
        correctAnswerIndex: 1,
        explanation: 'Rumble strips create noise and vibration to alert drivers when they\'re drifting out of their lane.',
        topic: 'Understanding Road Infrastructure',
        difficulty: 'medium',
        gradeLevel: [8, 9, 10],
      ),
      Question(
        id: 'infra_g810_004',
        text: '🏗️ What is the purpose of road medians?',
        options: ['To plant flowers', 'To separate opposing traffic and provide refuge for pedestrians', 'To make roads wider', 'To collect rainwater'],
        correctAnswerIndex: 1,
        explanation: 'Medians separate opposing traffic lanes and can provide safe spaces for pedestrians crossing wide roads.',
        topic: 'Understanding Road Infrastructure',
        difficulty: 'medium',
        gradeLevel: [8, 9, 10],
      ),

      // Additional questions for older grades
      Question(
        id: 'adv_g810_001',
        text: 'What is defensive driving?',
        options: ['Driving aggressively', 'Driving to protect yourself and others', 'Driving fast', 'Driving with music loud'],
        correctAnswerIndex: 1,
        explanation: 'Defensive driving means being alert, following rules, and anticipating what other drivers might do wrong.',
        topic: 'Defensive Driving',
        difficulty: 'medium',
        gradeLevel: [9, 10],
      ),
      Question(
        id: 'adv_g810_002',
        text: 'What is the "3-second rule"?',
        options: ['Count to 3 at lights', 'Wait 3 seconds to honk', 'Keep 3 seconds distance behind cars', 'Stop for 3 seconds'],
        correctAnswerIndex: 2,
        explanation: 'The 3-second rule helps you keep a safe following distance behind other vehicles.',
        topic: 'Defensive Driving',
        difficulty: 'hard',
        gradeLevel: [9, 10],
      ),
    ];
  }

  // Generate grade-specific quizzes
  Future<void> _generateGradeSpecificQuizzes() async {
    _quizzes = [
      // Grade 2-3: Traffic Lights only
      Quiz(
        id: 'grade23_traffic_lights',
        title: '🚦 Traffic Lights for Little Learners',
        description: 'Learn what red, yellow, and green lights mean! 🌈',
        topic: 'Traffic Lights',
        difficulty: 'easy',
        questions: _getQuestionsByGradeAndTopic([2, 3], 'Traffic Lights'),
        timeLimit: 10,
      ),

      // Grade 2: Video Learning Experience - NEW!
      Quiz(
        id: 'grade2_video_learning',
        title: '📺 Watch & Learn Traffic Safety!',
        description: 'Watch fun videos and learn about staying safe! 🎬✨',
        topic: 'Video Learning',
        difficulty: 'easy',
        questions: _getQuestionsByGradeAndTopic([2], 'Video Learning'),
        timeLimit: 15,
      ),

      // Grade 4-5: Traffic Lights + Basic Signs
      Quiz(
        id: 'grade45_traffic_signs',
        title: '🚦 Traffic Lights & Basic Signs',
        description: 'Master traffic lights and learn about stop signs!',
        topic: 'Traffic Signs',
        difficulty: 'easy',
        questions: _getQuestionsByGrade([4, 5]),
        timeLimit: 12,
      ),

      // Grade 6-7: Road Safety
      Quiz(
        id: 'grade67_road_safety',
        title: '🚴‍♀️ Road Safety Champions',
        description: 'Learn important safety rules for walking and biking!',
        topic: 'Safety Rules',
        difficulty: 'medium',
        questions: _getQuestionsByGrade([6, 7]),
        timeLimit: 15,
      ),

      // Grade 8-10: Comprehensive Rules
      Quiz(
        id: 'grade810_comprehensive',
        title: '🚗 Complete Traffic Rules',
        description: 'Master all traffic rules and become a safety expert!',
        topic: 'Comprehensive',
        difficulty: 'hard',
        questions: _getQuestionsByGrade([8, 9, 10]).take(6).toList(),
        timeLimit: 20,
      ),
      Quiz(
        id: 'grade910_advanced',
        title: '🏆 Advanced Traffic Knowledge',
        description: 'Challenge yourself with complex traffic scenarios!',
        topic: 'Advanced Rules',
        difficulty: 'hard',
        questions: _getQuestionsByGrade([9, 10]),
        timeLimit: 18,
      ),
    ];
  }

  // Get questions appropriate for specific grade levels
  List<Question> _getQuestionsByGrade(List<int> targetGrades) {
    return _allQuestions.where((question) {
      return question.gradeLevel.any((grade) => targetGrades.contains(grade));
    }).toList();
  }

  // Get questions by grade and topic
  List<Question> _getQuestionsByGradeAndTopic(List<int> targetGrades, String topic) {
    return _allQuestions.where((question) {
      final gradeMatch = question.gradeLevel.any((grade) => targetGrades.contains(grade));
      final topicMatch = question.topic.toLowerCase().contains(topic.toLowerCase());
      return gradeMatch && topicMatch;
    }).toList();
  }

  // Get quizzes appropriate for a student's grade
  List<Quiz> getQuizzesForGrade(int studentGrade) {
    return _quizzes.where((quiz) {
      // Check if any question in the quiz is appropriate for the student's grade
      return quiz.questions.any((question) => 
        question.gradeLevel.contains(studentGrade));
    }).toList();
  }

  // Get quiz by ID
  Quiz? getQuizById(String quizId) {
    try {
      return _quizzes.firstWhere((quiz) => quiz.id == quizId);
    } catch (e) {
      return null;
    }
  }

  // Start a quiz
  void startQuiz(String quizId) {
    _currentQuiz = getQuizById(quizId);
    _lastResult = null;
    notifyListeners();
  }

  // Submit quiz answers and calculate result
  QuizResult submitQuiz({
    required String userId,
    required Map<String, int> userAnswers,
    required int timeSpentSeconds,
  }) {
    if (_currentQuiz == null) {
      throw Exception('No active quiz');
    }

    int score = 0;
    Map<String, bool> correctAnswers = {};

    for (final question in _currentQuiz!.questions) {
      final userAnswer = userAnswers[question.id];
      final isCorrect = userAnswer == question.correctAnswerIndex;
      
      if (isCorrect) score++;
      correctAnswers[question.id] = isCorrect;
    }

    _lastResult = QuizResult(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      quizId: _currentQuiz!.id,
      quizTitle: _currentQuiz!.title,
      score: score,
      totalQuestions: _currentQuiz!.totalQuestions,
      timeSpentSeconds: timeSpentSeconds,
      completedAt: DateTime.now(),
      userAnswers: userAnswers,
      correctAnswers: correctAnswers,
      topic: _currentQuiz!.topic,
      difficulty: _currentQuiz!.difficulty,
    );

    notifyListeners();
    return _lastResult!;
  }

  // Clear current quiz
  void clearCurrentQuiz() {
    _currentQuiz = null;
    _lastResult = null;
    notifyListeners();
  }

  // Get available topics for a grade
  List<String> getAvailableTopicsForGrade(int grade) {
    final gradeQuestions = _getQuestionsByGrade([grade]);
    final topics = gradeQuestions.map((q) => q.topic).toSet().toList();
    topics.sort();
    return topics;
  }

  // Search quizzes by title or description for a specific grade
  List<Quiz> searchQuizzesForGrade(String query, int grade) {
    final gradeQuizzes = getQuizzesForGrade(grade);
    
    if (query.isEmpty) return gradeQuizzes;
    
    return gradeQuizzes.where((quiz) => 
      quiz.title.toLowerCase().contains(query.toLowerCase()) ||
      quiz.description.toLowerCase().contains(query.toLowerCase()) ||
      quiz.topic.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }
}