const std = @import("std");
const pkgtmpdir = @import("tmpdir.zig");

fn startShell(allocator: std.mem.Allocator, workdir: std.fs.Dir) !void {
    const argv = &[_][]const u8{"zsh"};

    var child = std.process.Child.init(argv, allocator);
    child.cwd_dir = workdir;

    var envmap = try std.process.getEnvMap(allocator);
    try envmap.put("AAA", "bbb");

    // see https://qiita.com/syoshika_/items/0211c873475eb0d59e23
    // if (envmap.get("PS1")) |ps1| {
    //     std.debug.print("found {s}\n", .{ps1});
    //     try envmap.put("PS1", try std.fmt.allocPrint(allocator, "(wtmp) {s}", .{ps1}));
    // }
    // try envmap.put("ZDOTDIR", "/Users/nsrciog/tmp");
    try envmap.put("PROMPT", "a"); // .zshrc が上書きしてそう
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
