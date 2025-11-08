const std = @import("std");
const pkgtmpdir = @import("tmpdir.zig");

pub fn startPinPrompt(allocator: std.mem.Allocator, from: []u8) !void {
    std.debug.print("*********************************************\n", .{});
    std.debug.print("* Session ended\n", .{});
    std.debug.print("* \n", .{});
    std.debug.print("* To pin this session, please provide a name,\n", .{});
    std.debug.print("* otherwise the session will be archived\n", .{});
    std.debug.print("*********************************************\n", .{});

    const name = try askName(allocator);
    defer allocator.free(name);

    if (std.mem.eql(u8, name, "")) {
        return;
    }
    std.debug.print("* pin this session as {s}\n", .{name});

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
