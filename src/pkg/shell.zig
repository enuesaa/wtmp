const std = @import("std");
const pkgtmpdir = @import("tmpdir.zig");

// TODO
// How to override PS1
// try envmap.put("ZDOTDIR", "/Users/aaa/tmp");
// try envmap.put("PROMPT", "a");
// try envmap.put("PS1", "(wtmp)");

fn startShell(allocator: std.mem.Allocator, workdir: std.fs.Dir) !void {
    const argv = &[_][]const u8{"zsh"};

    var child = std.process.Child.init(argv, allocator);
    child.cwd_dir = workdir;

    var envmap = try std.process.getEnvMap(allocator);
    try envmap.put("AAA", "bbb");
    child.env_map = &envmap;

    const term = try child.spawnAndWait();
    std.debug.print("exit code: {d}\n", .{term.Exited});
}

pub fn start(tmpdir: pkgtmpdir.TmpDir) !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    const workdir = try std.fs.openDirAbsolute(tmpdir.path, .{});
    try startShell(allocator, workdir);
}
