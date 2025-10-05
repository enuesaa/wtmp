const std = @import("std");
const wtmp = @import("wtmp");

pub fn main() !void {
    std.debug.print("hello {s}.\n", .{"hello"});
    // try wtmp.mkdir();

    if (wtmp.isDirExists()) {
        std.debug.print("dir exists\n", .{});
    }

    // try wtmp.shell();
}
