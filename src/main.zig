const std = @import("std");
const ttm = @import("ttm");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    // first argument is the binary name like `ttm`
    if (args.len == 1) {
        try ttm.workInTmp();
        return;
    }
    try ttm.launchCLI();
}
