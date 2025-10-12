const std = @import("std");

// see https://stackoverflow.com/questions/72709702/how-do-i-get-the-full-path-of-a-std-fs-dir
pub fn mkdir() !void {
    if (isDirExists()) return;

    const cwd = std.fs.cwd();
    const alloc = std.heap.page_allocator;
    const cwdpath = try cwd.realpathAlloc(alloc, ".");
    std.debug.print("cwd: {s}\n", .{cwdpath});

    try cwd.makeDir("testdir");
}

fn isDirExists() bool {
    const cwd = std.fs.cwd();
    return if (cwd.access("testdir", .{})) |_| true else |_| false;
}

pub fn rmdir() !void {
    if (!isDirExists()) return;

    const cwd = std.fs.cwd();
    try cwd.deleteDir("testdir");
}

pub fn listFilesInCurrentDir() !void {
    const cwd = std.fs.cwd();

    const entries = try cwd.openDir(".", .{ .iterate = true });
    var it = entries.iterate();

    while (try it.next()) |entry| {
        std.debug.print("{s}\n", .{entry.name});
    }
}

pub fn shell() !void {
    const alloc = std.heap.page_allocator;

    const argv = &[_][]const u8{"zsh"};
    var child = std.process.Child.init(argv, alloc);

    const cwd = std.fs.cwd();

    const launchdir = try cwd.openDir("src", .{}); // ここに絶対パスを指定可能 (/Users/aaa/tmp)
    child.cwd_dir = launchdir;

    var env_map = try std.process.getEnvMap(alloc);
    try env_map.put("AAA", "bbb");
    child.env_map = &env_map;

    const exit_code = try child.spawnAndWait();
    std.debug.print("Exit code: {}\n", .{exit_code});
}
