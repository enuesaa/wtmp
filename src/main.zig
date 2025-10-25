const std = @import("std");
const wtmp = @import("wtmp");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    // first argument is the binary name like `wtmp`
    if (args.len == 1) {
        try wtmp.workInTmp();
        return;
    }
    try wtmp.launchCLI();
}
