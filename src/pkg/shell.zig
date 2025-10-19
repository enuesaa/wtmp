const std = @import("std");
const pkgtmpdir = @import("tmpdir.zig");

// How to override PS1
// try envmap.put("ZDOTDIR", "/Users/aaa/tmp");
// try envmap.put("PROMPT", "a");
// try envmap.put("PS1", "(wtmp)");

fn startShell(allocator: std.mem.Allocator, workdir: std.fs.Dir) !void {
    const argv = &[_][]const u8{"zsh"};

    var child = std.process.Child.init(argv, allocator);
    child.cwd_dir = workdir;

    var env = try std.process.getEnvMap(allocator);
    try env.put("AAA", "bbb");
    defer env.deinit();
    child.env_map = &env;

    const term = try child.spawnAndWait();
    std.debug.print("exit code: {d}\n", .{term.Exited});
}

pub fn start(tmppath: []u8) !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const workdir = try std.fs.openDirAbsolute(tmppath, .{});
    try startShell(allocator, workdir);
}
