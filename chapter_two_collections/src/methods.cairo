#[derive(Drop)]
struct Rectangle {
    width: u32,
    height: u32,
    length: u32,
}

// trait RectangleTrait {
//     fn area(ref self: Rectangle) -> u32;
//     fn volume(ref self: Rectangle) -> u32;
// }

#[generate_trait] // provided to save from writing traits which can be cumbersome, code is cleaner
impl RectangleImpl of RectangleTrait {
    // class method and not instance method this called with impl::new instead of instance.new 
    fn new(width: u32, height: u32, length: u32) -> Rectangle {
        Rectangle { width, height, length }
    }

    fn area(ref self: Rectangle) -> u32 {
        self.width * (self.length)
    }
    fn volume(ref self: Rectangle) -> u32 {
        self.width * (self.height) * (self.length)
    }
    fn can_hold(self: @Rectangle, other: @Rectangle) -> bool {
        (*self.width) > (*other.width) && (*self.height) > (*other.height)
    }
}

fn main() {
    let mut rectangle1 = RectangleImpl::new(3, 4, 5);
    let rectangle2 = RectangleImpl::new(12, 5, 15);
    let area: u32 = rectangle1.area();
    let vol: u32 = rectangle1.volume();
    let can_hold = rectangle1.can_hold(@rectangle2);
    println!(
        "The area of rectangle 1 is {} and its volume is {} and can it hold rectangle 2? {}",
        area,
        vol,
        can_hold
    );
}
