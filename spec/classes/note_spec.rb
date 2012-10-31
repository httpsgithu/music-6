require 'spec_helper'
include Music

describe Music::Note do

  describe "#new" do
    it "should allow note strings to initalize notes" do
      Note.new('E0').frequency.should == 20.60
      Note.new('Bb3').frequency.should == 233.08
    end

    it "should allow frequencies to initalize notes" do
      Note.new(698.46).note_string.should == 'F5'
      Note.new(1975.53).note_string.should == 'B6'
    end
  end

  describe "Comparing notes" do
    it "should compare notes by their frequencies" do
      Note.new(698.46).should < Note.new(1975.53)
      Note.new('B5').should > Note.new('B2')
      Note.new(698.46).should == Note.new('F5')
    end
  end

  describe '#note_string' do
    it 'Should return the letter, accidental, and octave as a string' do
      Note.new(698.46).note_string.should == 'F5'
      Note.new('C#6').note_string.should == 'C#6'
    end

    it 'Should return the flat version if asked' do
      Note.new('C#6').note_string(true).should == 'Db6'
    end
  end

  describe '#letter' do
    it 'Should return just the letter' do
      Note.new('E0').letter.should == 'E'
      Note.new(698.46).letter.should == 'F'
      Note.new(1975.53).letter.should == 'B'
    end

    it 'Should return the letter based on if asked for the flat' do
      Note.new('Bb3').letter.should == 'A'
      Note.new('Bb3').letter(true).should == 'B'
    end
  end

  describe '#accidental' do
    it 'Should return just the accidental' do
      Note.new('A#4').accidental.should == '#'
    end

    it 'Should return the flat if asked for' do
      Note.new('Bb3').accidental.should == '#'
      Note.new('Bb3').accidental(true).should == 'b'
    end

    it 'Should return nil for no accidental' do
      Note.new('B2').accidental.should == nil
      Note.new('G2').accidental.should == nil
    end
  end

  describe '#octave' do
    it 'Should return the octave' do
      Note.new('A#4').octave.should == 4
      Note.new('B7').octave.should == 7
      Note.new('Gb1').octave.should == 1
      Note.new('E0').octave.should == 0
    end
  end

  describe ".parse_note_string(note_string)" do
    it "Should split note letter, accidental, and octave" do
      Note.parse_note_string('A#1').should == ['A', '#', 1]
      Note.parse_note_string('Cb4').should == ['C', 'b', 4]
    end

    it "Should allow for lower case notes" do
      Note.parse_note_string('g#1').should == ['G', '#', 1]
    end

    it "Should allow for an assumed octave" do
      Note.parse_note_string('A', 4).should == ['A', nil, 4]
      Note.parse_note_string('C#', 6).should == ['C', '#', 6]
    end

    it "Should ignore the assumed octave if there is a octave" do
      Note.parse_note_string('B3', 4).should == ['B', nil, 3]
      Note.parse_note_string('Gb6', 2).should == ['G', 'b', 6]
    end

    it "Should not allow notes above G" do
      expect { Note.parse_note_string('HB1') }.to raise_error ArgumentError
    end

    it "Should not allow extraneous characters" do
      expect { Note.parse_note_string(' Ab1') }.to raise_error ArgumentError
      expect { Note.parse_note_string('%Hb1') }.to raise_error ArgumentError
      expect { Note.parse_note_string('Hb1-') }.to raise_error ArgumentError
    end

    it "Should not allow for upper case flats" do
      expect { Note.parse_note_string('AB1') }.to raise_error ArgumentError
      expect { Note.parse_note_string('aB1') }.to raise_error ArgumentError
    end

    it "Should return nil when there is no accidental" do
      Note.parse_note_string('C4').should == ['C', nil, 4]
    end

    it "Should not allow note above octave 8" do
      Note.parse_note_string('G#8').should == ['G', '#', 8]
      expect { Note.parse_note_string('Ab9') }.to raise_error ArgumentError
      expect { Note.parse_note_string('Ab', 9) }.to raise_error ArgumentError
    end
  end

  describe ".note_distance(note_string1, note_string2)" do
    {
      ['A4', 'A#4'] => 1,
      ['A4', 'Ab4'] => -1,
      ['B0', 'B0'] => 0,
      ['G#1', 'Ab1'] => 0,
      ['Bb1', 'A#1'] => 0,
      ['A3', 'A4'] => 12,
      ['a3', 'A4'] => 12,
      ['B1', 'F1'] => -6,
      ['B1', 'f1'] => -6,
      ['A4', 'Eb0'] => -54,
      ['a4', 'eb0'] => -54,
      ['A2', 'C4'] => 15
    }.each do |notes, distance|
      it "Should return #{distance} between #{notes[0]} and #{notes[1]}" do
        Note.note_distance(*notes).should == distance
      end
    end

    it "Should not allow invalid note strings" do
      expect { Note.note_distance('H0', 'A0') }.to raise_error ArgumentError
      expect { Note.note_distance('A0', 'I#0') }.to raise_error ArgumentError
      expect { Note.note_distance('A%0', 'A0') }.to raise_error ArgumentError
    end
  end

  describe '#distance_to(note)' do
    it 'Should find the distance between the subject note object and the note passed in' do
      Note.new('A2').distance_to(Note.new('C4')).should == 15
    end
  end

  describe 'interval calculations' do
    let(:c4) { Note.new('C4') }
    let(:b4) { Note.new('B4') }
    
    it { c4.should have_an_interval :minor_second, 'C#4' }
    it { b4.should have_an_interval :minor_second, 'C5' }

    it { c4.should have_an_interval :major_second, 'D4' }
    it { b4.should have_an_interval :major_second, 'C#5' }


    it { c4.should have_an_interval :minor_third, 'D#4' }
    it { b4.should have_an_interval :minor_third, 'D5' }

    it { c4.should have_an_interval :major_third, 'E4' }
    it { b4.should have_an_interval :major_third, 'D#5' }

    it { c4.should have_an_interval :perfect_fourth, 'F4' }
    it { b4.should have_an_interval :perfect_fourth, 'E5' }

    # Enharmonic equivalents
    it { c4.should have_an_interval :tritone, 'F#4' }
    it { b4.should have_an_interval :tritone, 'F5' }
    it { c4.should have_an_interval :diminished_fifth, 'F#4' }
    it { b4.should have_an_interval :diminished_fifth, 'F5' }
    it { c4.should have_an_interval :flat_fifth, 'F#4' }
    it { b4.should have_an_interval :flat_fifth, 'F5' }
    it { c4.should have_an_interval :augmented_fourth, 'F#4' }
    it { b4.should have_an_interval :augmented_fourth, 'F5' }

    it { c4.should have_an_interval :perfect_fifth, 'G4' }
    it { b4.should have_an_interval :perfect_fifth, 'F#5' }

    # Enharmonic equivalents
    it { c4.should have_an_interval :augmented_fifth, 'G#4' }
    it { b4.should have_an_interval :augmented_fifth, 'G5' }
    it { c4.should have_an_interval :minor_sixth, 'G#4' }
    it { b4.should have_an_interval :minor_sixth, 'G5' }

    it { c4.should have_an_interval :major_sixth, 'A4' }
    it { b4.should have_an_interval :major_sixth, 'G#5' }

    it { c4.should have_an_interval :diminished_seventh, 'A4' }
    it { b4.should have_an_interval :diminished_seventh, 'G#5' }

    it { c4.should have_an_interval :minor_seventh, 'A#4' }
    it { b4.should have_an_interval :minor_seventh, 'A5' }

    it { c4.should have_an_interval :major_seventh, 'B4' }
    it { b4.should have_an_interval :major_seventh, 'A#5' }
  end


  describe 'scales from notes (as scale key)' do
    describe '#major_scale' do
      Note.new('C4').major_scale.should == [
        Note.new('C4'),
        Note.new('D4'),
        Note.new('E4'),
        Note.new('F4'),
        Note.new('G4'),
        Note.new('A4'),
        Note.new('B4')
      ]

      Note.new('G4').major_scale.should == [
        Note.new('G4'),
        Note.new('A4'),
        Note.new('B4'),
        Note.new('C5'),
        Note.new('D5'),
        Note.new('E5'),
        Note.new('F#5')
      ]
    end

    describe '#minor_scale' do
      Note.new('C4').minor_scale.should == [
        Note.new('C4'),
        Note.new('D4'),
        Note.new('D#4'),
        Note.new('F4'),
        Note.new('G4'),
        Note.new('G#4'),
        Note.new('A#4')
      ]

      Note.new('G4').minor_scale.should == [
        Note.new('G4'),
        Note.new('A4'),
        Note.new('A#4'),
        Note.new('C5'),
        Note.new('D5'),
        Note.new('D#5'),
        Note.new('F5')
      ]
    end
  end

  describe 'chords from notes' do
    c4 = Note.new('C4')
    
    c_minor = Chord.new(['C4', 'Eb4', 'G4'])
    c_major = Chord.new(['C4', 'E4', 'G4'])
    c_diminished = Chord.new(['C4', 'Eb4', 'Gb4'])
    c_augmented = Chord.new(['C4', 'E4', 'G#4'])
    c_major_seventh = Chord.new(['C4', 'E4', 'G4', 'B4'])
    c_minor_seventh = Chord.new(['C4', 'Eb4', 'G4', 'Bb4'])
    c_diminished_seventh = Chord.new(['C4', 'Eb4', 'Gb4', 'A4'])
    c_augmented_seventh = Chord.new(['C4', 'E4', 'G#4', 'Bb4'])
    c_half_diminished_seventh = Chord.new(['C4', 'Eb4', 'Gb4', 'Bb4'])

    describe 'chords from notes' do
      describe '#chord' do
        it 'should recognize minor chords' do
          c4.chord(:minor).should == c_minor
          c4.chord('Minor').should == c_minor
          c4.chord('minor').should == c_minor
          c4.chord('min').should == c_minor
          c4.chord('MIN').should == c_minor
          c4.chord('m').should == c_minor
        end

        it 'should recognize major chords' do
          c4.chord(:major).should == c_major
          c4.chord('Major').should == c_major
          c4.chord('major').should == c_major
          c4.chord('maj').should == c_major
          c4.chord('MAJ').should == c_major
          c4.chord('M').should == c_major
          c4.chord('').should == c_major
        end

        it 'should recognize diminished chords' do
          c4.chord(:diminished).should == c_diminished
          c4.chord('Diminished').should == c_diminished
          c4.chord('diminished').should == c_diminished
          c4.chord('dim').should == c_diminished
          c4.chord('DIM').should == c_diminished
        end

        it 'should recognize augmented chords' do
          c4.chord(:augmented).should == c_augmented
          c4.chord('Augmented').should == c_augmented
          c4.chord('augmented').should == c_augmented
          c4.chord('aug').should == c_augmented
          c4.chord('AUG').should == c_augmented
          c4.chord('+').should == c_augmented
        end

        it 'should recognize major seventh chords' do
          c4.chord(:major_seventh).should == c_major_seventh
          c4.chord('major_seventh').should == c_major_seventh
          c4.chord('major seventh').should == c_major_seventh
          c4.chord('Major seventh').should == c_major_seventh
          c4.chord('maj seventh').should == c_major_seventh
          c4.chord('maj 7').should == c_major_seventh
          c4.chord('maj 7th').should == c_major_seventh
          c4.chord('maj7').should == c_major_seventh
          c4.chord('maj7th').should == c_major_seventh
          c4.chord('MAJ7').should == c_major_seventh
          c4.chord('M7').should == c_major_seventh
        end

        it 'should recognize minor seventh chords' do
          c4.chord(:minor_seventh).should == c_minor_seventh
          c4.chord('minor_seventh').should == c_minor_seventh
          c4.chord('minor seventh').should == c_minor_seventh
          c4.chord('minor seventh').should == c_minor_seventh
          c4.chord('min seventh').should == c_minor_seventh
          c4.chord('min 7').should == c_minor_seventh
          c4.chord('min 7th').should == c_minor_seventh
          c4.chord('min7').should == c_minor_seventh
          c4.chord('min7th').should == c_minor_seventh
          c4.chord('min7').should == c_minor_seventh
          c4.chord('m7').should == c_minor_seventh
        end

        it 'should recognize diminished seventh chords' do
          c4.chord(:diminished_seventh).should == c_diminished_seventh
          c4.chord('diminished_seventh').should == c_diminished_seventh
          c4.chord('diminished seventh').should == c_diminished_seventh
          c4.chord('diminished seventh').should == c_diminished_seventh
          c4.chord('dim seventh').should == c_diminished_seventh
          c4.chord('dim 7').should == c_diminished_seventh
          c4.chord('dim 7th').should == c_diminished_seventh
          c4.chord('dim7').should == c_diminished_seventh
          c4.chord('dim7th').should == c_diminished_seventh
          c4.chord('dim7').should == c_diminished_seventh
          c4.chord('d7').should == c_diminished_seventh
        end

        it 'should recognize augmented seventh chords' do
          c4.chord(:augmented_seventh).should == c_augmented_seventh
          c4.chord('augmented_seventh').should == c_augmented_seventh
          c4.chord('augmented seventh').should == c_augmented_seventh
          c4.chord('augmented seventh').should == c_augmented_seventh
          c4.chord('aug seventh').should == c_augmented_seventh
          c4.chord('aug 7').should == c_augmented_seventh
          c4.chord('aug 7th').should == c_augmented_seventh
          c4.chord('aug7').should == c_augmented_seventh
          c4.chord('aug7th').should == c_augmented_seventh
          c4.chord('aug7').should == c_augmented_seventh
          c4.chord('+7').should == c_augmented_seventh
        end

        it 'should recognize half diminished seventh chords' do
          c4.chord(:half_diminished_seventh).should == c_half_diminished_seventh
          c4.chord('half_diminished_7').should == c_half_diminished_seventh
          c4.chord('half_diminished_7th').should == c_half_diminished_seventh
          c4.chord('half-diminished seventh').should == c_half_diminished_seventh
          c4.chord('half-diminished 7').should == c_half_diminished_seventh
          c4.chord('half-diminished 7th').should == c_half_diminished_seventh
          c4.chord('half_dim seventh').should == c_half_diminished_seventh
          c4.chord('half_dim 7').should == c_half_diminished_seventh
          c4.chord('half_dim 7th').should == c_half_diminished_seventh
          c4.chord('half_dim7').should == c_half_diminished_seventh
          c4.chord('half_dim7th').should == c_half_diminished_seventh
          c4.chord('half_dim7').should == c_half_diminished_seventh
        end
      end

      describe 'chord methods' do
        it 'should have minor methods' do
          c4.minor_chord.should == c_minor
          c4.min_chord.should == c_minor
          c4.m_chord.should == c_minor
        end

        it 'should have major methods' do
          c4.major_chord.should == c_major
          c4.maj_chord.should == c_major
          c4.M_chord.should == c_major
        end

        it 'should have diminished methods' do
          c4.diminished_chord.should == c_diminished
          c4.dim_chord.should == c_diminished
        end

        it 'should have augmented methods' do
          c4.augmented_chord.should == c_augmented
          c4.aug_chord.should == c_augmented
        end

        it 'should have major seventh methods' do
          c4.major_seventh_chord.should == c_major_seventh
          c4.maj_seventh_chord.should == c_major_seventh
          c4.maj_7_chord.should == c_major_seventh
          c4.maj_7th_chord.should == c_major_seventh
          c4.maj7_chord.should == c_major_seventh
          c4.maj7th_chord.should == c_major_seventh
          c4.M7_chord.should == c_major_seventh
        end

        it 'should have minor seventh methods' do
          c4.minor_seventh_chord.should == c_minor_seventh
          c4.min_seventh_chord.should == c_minor_seventh
          c4.min_7_chord.should == c_minor_seventh
          c4.min_7th_chord.should == c_minor_seventh
          c4.min7_chord.should == c_minor_seventh
          c4.min7th_chord.should == c_minor_seventh
          c4.m7_chord.should == c_minor_seventh
        end

        it 'should have diminished seventh methods' do
          c4.diminished_seventh_chord.should == c_diminished_seventh
          c4.dim_seventh_chord.should == c_diminished_seventh
          c4.dim_7_chord.should == c_diminished_seventh
          c4.dim_7th_chord.should == c_diminished_seventh
          c4.dim7_chord.should == c_diminished_seventh
          c4.dim7th_chord.should == c_diminished_seventh
          c4.d7_chord.should == c_diminished_seventh
        end

        it 'should have augmented seventh methods' do
          c4.augmented_seventh_chord.should == c_augmented_seventh
          c4.aug_seventh_chord.should == c_augmented_seventh
          c4.aug_7_chord.should == c_augmented_seventh
          c4.aug_7th_chord.should == c_augmented_seventh
          c4.aug7_chord.should == c_augmented_seventh
          c4.aug7th_chord.should == c_augmented_seventh
          c4.send('+7_chord').should == c_augmented_seventh
        end

        it 'should have half diminished seventh methods' do
          c4.half_diminished_seventh_chord.should == c_half_diminished_seventh
          c4.half_diminished_7_chord.should == c_half_diminished_seventh
          c4.half_diminished_7th_chord.should == c_half_diminished_seventh
          c4.half_dim_seventh_chord.should == c_half_diminished_seventh
          c4.half_dim_7_chord.should == c_half_diminished_seventh
          c4.half_dim_7th_chord.should == c_half_diminished_seventh
          c4.half_dim7_chord.should == c_half_diminished_seventh
          c4.half_dim7th_chord.should == c_half_diminished_seventh
        end
      end
    end

  end

  describe ".calculate_frequency(letter, accidental, octave)" do
    {
      ['C', nil, 0] => 16.35,
      ['E', 'b', 0] => 19.45,
      ['A', '#', 1] => 58.27,
      ['B', 'b', 1] => 58.27,
      ['A', 'b', 4] => 415.30,
      ['A', nil, 4] => 440.00,
      ['A', '#', 4] => 466.16,
      ['B', nil, 6] => 1975.53,
      ['C', nil, 7] => 2093.00,
      ['E', 'b', 8] => 4978.03
    }.each do |note_array, frequency|
      it "Should return #{frequency} for #{note_array.join}" do
        Note.calculate_frequency(*note_array).should == frequency
      end
    end

    it "Should take note strings as an argument" do
      Note.calculate_frequency('A#1').should == 58.27
      Note.calculate_frequency('A4').should == 440.00
      Note.calculate_frequency('C7').should == 2093.00
    end

    it "Should allow lower case notes" do
      Note.calculate_frequency('a#1').should == 58.27
      Note.calculate_frequency('db2').should == 69.3
      Note.calculate_frequency('e', nil, 3).should == 164.81
    end

    it "Should not take argument lengths above 3" do
      expect { Note.calculate_frequency('A', nil, 0, 0) }.to raise_error ArgumentError
    end

    it "Should not allow invalid notes" do
      expect { Note.calculate_frequency('H', nil, 0) }.to raise_error ArgumentError
      expect { Note.calculate_frequency('I', nil, 0) }.to raise_error ArgumentError
    end

    it "Should not allow invalid accidentals" do
      expect { Note.calculate_frequency('A', 5, 0) }.to raise_error ArgumentError
      expect { Note.calculate_frequency('A', '&', 0) }.to raise_error ArgumentError
    end

    it "Should not allow invalid octaves" do
      expect { Note.calculate_frequency('A', nil, -1) }.to raise_error ArgumentError
      expect { Note.calculate_frequency('A', nil, 9) }.to raise_error ArgumentError
    end
  end

  # TODO: Should return accurracy
  # Thought: ((frequency off) / (distance to next note's frequency)) * 2.0?
  describe ".calculate_note(frequency)" do
    test_frequencies = {
      [16.35] => ['C', nil, 0],
      [19.45, true] => ['E', 'b', 0],
      [58.27] => ['A', '#', 1],
      [58.27, true] => ['B', 'b', 1],
      [415.30, true] => ['A', 'b', 4],
      [440.00] => ['A', nil, 4],
      [466.16] => ['A', '#', 4],
      [1975.53] => ['B', nil, 6],
      [2093.00] => ['C', nil, 7],
      [4978.03, true] => ['E', 'b', 8]
    }

    test_frequencies.each do |args, note_string|
      it "Should return #{note_string} for #{args[0]}#{args[1] && ' (giving flat)'}" do
        Note.calculate_note(*args).should == note_string
      end
    end

    it "Should calculate the closest note near to a frequency" do
      Note.calculate_note(420, true).should == ['A', 'b', 4]
      Note.calculate_note(430).should == ['A', nil, 4]
    end
  end

  describe ".nearest_note_frequency(frequency)" do
    it 'should return the frequency if it is the frequency of a note' do
      Note.nearest_note_frequency(2093.00).should == 2093.00
    end

    it 'should return the nearest frequency which matches a note' do
      Note.nearest_note_frequency(41.00).should == 41.20
      Note.nearest_note_frequency(40.50).should == 41.20
      Note.nearest_note_frequency(40.00).should == 38.89
      Note.nearest_note_frequency(39.00).should == 38.89
    end
  end

  describe ".frequency_adjustment(start_frequency, distance)" do
    it "Should find frequencies based on start frequency and distance" do
      Note.frequency_adjustment(440.0, 0).should == 440.0
      Note.frequency_adjustment(440.0, 15).should == 1046.50
      Note.frequency_adjustment(440.0, -10).should == 246.94

      Note.frequency_adjustment(1479.98, -6).should == 1046.50
      Note.frequency_adjustment(1479.98, 7).should == 2217.46
    end
  end

  describe "Getting adjacent notes" do
    it "should allow getting of next note" do
      Note.new(698.46).next.should == Note.new(739.99)
      Note.new(698.46).succ.should == Note.new(739.99)
    end

    it "should allow getting of previous note" do
      Note.new(739.99).pred.should == Note.new(698.46)
    end
  end
end
