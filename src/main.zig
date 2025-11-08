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
        try prompt();
        try ttm.workInTmp();
        return;
    }
    try ttm.launchCLI();
}

fn prompt() !void {
    const stdout = std.fs.File.stdout();
    const stdin = std.fs.File.stdin();

    _ = try stdout.write("Proceed? (y/n): ");

    // var buf: []u8 = undefined;
    // _ = try stdin.read(buf);

    // std.debug.print("read: {s}\n", .{buf});

    // buf = undefined;

    var buf: [1]u8 = undefined;
    const n = try stdin.read(&buf);

    if (n == 0) {
        _ = try stdout.write("received\n");
        return;
    }

    switch (buf[0]) {
        'y', 'Y' => _ = try stdout.write("Confirmed\n"),
        'n', 'N' => _ = try stdout.write("Cancelled\n"),
        else => _ = try stdout.write("Invalid\n"),
    }
}
