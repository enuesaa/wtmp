const std = @import("std");
const pkgregistry = @import("pkg/registry.zig");
const pkgtmpdir = @import("pkg/tmpdir.zig");

pub fn makeRegistry() !void {
    try pkgregistry.make();
}

pub fn makeTmpDir() !void {
    try pkgtmpdir.make();
}

// pub fn rmdir() !void {
//     if (!isDirExists()) return;

//     const cwd = std.fs.cwd();
//     try cwd.deleteDir("testdir");
// }

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
