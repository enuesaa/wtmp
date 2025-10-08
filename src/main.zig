const std = @import("std");
const wtmp = @import("wtmp");

pub fn main() !void {
    std.debug.print("start\n", .{});

    // create tmp dir here.
    try wtmp.mkdir();

    // start shell
    try wtmp.shell();

    // delete tmp dir here.
    try wtmp.rmdir();
}
