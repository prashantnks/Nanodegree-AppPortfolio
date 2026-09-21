class SampleLesson {
  const SampleLesson({
    required this.title,
    required this.body,
  });

  final String title;
  final String body;
}

const samplePhotosynthesis = SampleLesson(
  title: 'Photosynthesis',
  body: '''
Photosynthesis is the process plants use to convert light energy into chemical energy. It mainly occurs in the chloroplasts of plant cells. Chlorophyll is the green pigment that absorbs sunlight. During photosynthesis, plants take in carbon dioxide and water and release oxygen.

The overall chemical equation for photosynthesis is 6CO2 + 6H2O + light energy produces C6H12O6 and 6O2. Glucose is the sugar produced by photosynthesis. The light-dependent reactions take place in the thylakoid membranes. The Calvin cycle is the set of light-independent reactions that produce glucose.

Photosynthesis is essential because it produces most of the oxygen in Earth's atmosphere. Joseph Priestley demonstrated that plants restore air that animals have made unfit for breathing. Water is split during the light reactions, and that step is the source of the released oxygen. Stomata are the tiny pores on leaves that allow carbon dioxide to enter.

The rate of photosynthesis increases with light intensity until another factor becomes limiting. Temperature, carbon dioxide concentration, and water availability also affect the rate of photosynthesis. C4 plants such as maize are adapted to high-light, high-temperature environments. CAM plants such as cacti open their stomata at night to reduce water loss.
''',
);

const sampleSolarSystem = SampleLesson(
  title: 'The Solar System',
  body: '''
The Solar System is the gravitationally bound system of the Sun and the objects that orbit it. The Sun contains more than 99 percent of the Solar System's mass. Mercury is the planet closest to the Sun. Venus is the hottest planet because of a dense carbon dioxide atmosphere. Earth is the only planet known to support life. Mars is often called the Red Planet because of iron oxide on its surface.

Jupiter is the largest planet in the Solar System. Saturn is known for its prominent ring system. Uranus rotates on its side relative to its orbit. Neptune is the farthest known planet from the Sun. Pluto was reclassified as a dwarf planet by the International Astronomical Union in 2006.

An astronomical unit is the average distance from Earth to the Sun. The asteroid belt lies between the orbits of Mars and Jupiter. Comets are icy bodies that develop a glowing coma when they approach the Sun. The Kuiper Belt is a region of icy objects beyond Neptune.
''',
);

const sampleLessons = [samplePhotosynthesis, sampleSolarSystem];
