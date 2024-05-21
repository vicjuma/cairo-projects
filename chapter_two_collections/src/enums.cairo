// Each variant represents a distinct value the Direction type
#[derive(Drop)]
enum Direction { // note that values must not be of the same type
    North,
    East,
    South,
    West,
}

// Each variant represents a distinct value the Sex type
#[derive(Drop)]
enum Sex {
    Male: ByteArray,
    Female: ByteArray,
}

#[generate_trait]
impl SexImpl of SexTrait {
    fn process(self: Sex) {
        match self {
            Sex::Male(x) => { println!("The student {} is male", x); },
            Sex::Female(y) => { println!("The student {} is female", y); },
        }
    }
}

#[generate_trait]
impl DirectionImpl of DirectionTrait {
    fn direction_to_church(self: Direction) {
        match self {
            Direction::North => { println!("Move North"); },
            Direction::East => { println!("Move East"); },
            Direction::West => { println!("Move West"); },
            Direction::South => { println!("Move South"); },
        }
    }
}

#[derive(Drop, Debug)]
enum UsState {
    Alaska,
    Alabama,
}

fn main() {
    let sex: Sex = Sex::Male("Victor");
    sex.process();
}
