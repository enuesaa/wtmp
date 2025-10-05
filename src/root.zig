const std = @import("std");

pub fn mkdir() !void {
    const cwd = std.fs.cwd();

    const alloc = std.heap.page_allocator;
    // see https://stackoverflow.com/questions/72709702/how-do-i-get-the-full-path-of-a-std-fs-dir
    const cwdpath = try cwd.realpathAlloc(alloc, ".");
    std.debug.print("cwd: {s}\n", .{cwdpath});

    try cwd.makeDir("testdir");
}

pub fn isDirExists() bool {
    const cwd = std.fs.cwd();
    return if (cwd.access("a", .{})) |_| true else |_| false;
}

pub fn shell() !void {
    const alloc = std.heap.page_allocator;

    const argv = &[_][]const u8{"zsh"};
    var child = std.process.Child.init(argv, alloc);
    // defer child.deinit();

    // try child.setExecutable("/bin/zsh", &[_][]const u8{"zsh"});

    // var env_list = try std.ArrayList([]const u8).init(alloc);
    // defer env_list.deinit();
    // var env_iter = std.os.environ();
    // while (env_iter.next()) |env| {
    //     try env_list.append(env.?);
    // }
    // try env_list.append("MYVAR=hello");
    // try child.setEnv(env_list.toOwnedSlice());

    // child.stdout = .Inherit;
    // child.stderr = .Inherit;
    // , .Inherit, .Inherit);

    const exit_code = try child.spawnAndWait();
    std.debug.print("Exit code: {}\n", .{exit_code});
}

pub fn add(a: i32, b: i32) i32 {
    return a + b;
}

test "basic add functionality" {
    try std.testing.expect(add(3, 7) == 10);
}
