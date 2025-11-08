const std = @import("std");
const pkgtmpdir = @import("tmpdir.zig");

fn startShell(allocator: std.mem.Allocator, workdir: std.fs.Dir) !void {
    const argv = &[_][]const u8{"zsh"};

    var child = std.process.Child.init(argv, allocator);
    child.cwd_dir = workdir;

    var env = try std.process.getEnvMap(allocator);
    try env.put("AAA", "bbb");
    defer env.deinit();
    child.env_map = &env;

    const term = try child.spawnAndWait();
    std.debug.print("exit: {d}\n", .{term.Exited});
    std.debug.print("\n", .{});

    // TODO: prompt archive or not.
    // TODO: change name here.
    if (try askPin()) {
        std.debug.print("ok pin this session\n", .{});
    }
    const name = try askName(allocator);
    defer allocator.free(name);
    std.debug.print("name is {s}\n", .{name});
}

fn askName(allocator: std.mem.Allocator) ![]const u8 {
    const stdin = std.fs.File.stdin();

    const defaultName = "aaa";
    std.debug.print("Name? (default:{s}): ", .{defaultName});

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

fn askPin() !bool {
    const stdout = std.fs.File.stdout();
    const stdin = std.fs.File.stdin();

    _ = try stdout.write("Pin? [y/n] (default:n): ");

    var buf: [1]u8 = undefined;
    const n = try stdin.read(&buf);

    if (n == 0) {
        return false;
    }
    if (buf[0] == '\n') {
        return false;
    }

    // discard the input of `Enter` after `y` or `n`
    var discard: [1]u8 = undefined;
    while (true) {
        const k = try stdin.read(&discard);
        if (k == 0 or discard[0] == '\n') break;
    }
    if (buf[0] == 'y') {
        return true;
    }
    return false;
}

pub fn start(tmppath: []u8) !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const workdir = try std.fs.openDirAbsolute(tmppath, .{});
    try startShell(allocator, workdir);
}
