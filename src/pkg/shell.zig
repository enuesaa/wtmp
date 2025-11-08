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
    if (try askContinue()) {
        std.debug.print("ok continue\n", .{});
    } else {
        std.debug.print("not continue\n", .{});
    }
}

fn askContinue() !bool {
    const stdout = std.fs.File.stdout();
    const stdin = std.fs.File.stdin();

    _ = try stdout.write("Proceed? (y/n): ");

    var buf: [1]u8 = undefined;
    const n = try stdin.read(&buf);

    if (n == 0) {
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
