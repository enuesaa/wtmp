const std = @import("std");
const pkgtmpdir = @import("tmpdir.zig");

pub fn startPinPrompt(allocator: std.mem.Allocator, from: []u8) !void {
    const name = try askName(allocator);
    defer allocator.free(name);

    if (std.mem.eql(u8, name, "")) {
        return;
    }
    std.debug.print("pin {s} as {s}\n", .{ from, name });

    var tmpdir = pkgtmpdir.get(allocator, from) catch {
        std.debug.print("tmpdir not found\n", .{});
        return;
    };
    try tmpdir.rename(name);
}

fn askName(allocator: std.mem.Allocator) ![]const u8 {
    const stdin = std.fs.File.stdin();

    const defaultName = "";
    std.debug.print("? Name: ", .{});

    var buf: [100]u8 = undefined;
    var idx: usize = 0;

    while (idx < buf.len) {
        var b: [1]u8 = undefined;
        const n = try stdin.read(&b);
        if (n == 0 or b[0] == '\n') {
            break;
        }
        buf[idx] = b[0];
        idx += 1;
    }
    if (idx == 0) {
        return defaultName;
    }
    return try allocator.dupe(u8, buf[0..idx]);
}

// fn askPin() !bool {
//     const stdout = std.fs.File.stdout();
//     const stdin = std.fs.File.stdin();

//     _ = try stdout.write("Pin? [y/n] (default:n): ");

//     var buf: [1]u8 = undefined;
//     const n = try stdin.read(&buf);

//     if (n == 0) {
//         return false;
//     }
//     if (buf[0] == '\n') {
//         return false;
//     }

//     // discard the input of `Enter` after `y` or `n`
//     var discard: [1]u8 = undefined;
//     while (true) {
//         const k = try stdin.read(&discard);
//         if (k == 0 or discard[0] == '\n') break;
//     }
//     if (buf[0] == 'y') {
//         return true;
//     }
//     return false;
// }
