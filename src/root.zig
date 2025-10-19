const pkgregistry = @import("pkg/registry.zig");
const pkgtmpdir = @import("pkg/tmpdir.zig");
const pkgshell = @import("pkg/shell.zig");
const pkglist = @import("pkg/list.zig");

pub fn workInTmp() !void {
    // create registry if not exist
    try pkgregistry.make();

    // create
    var tmpdir = try pkgtmpdir.make();
    defer tmpdir.deinit();

    // start shell
    try pkgshell.start(tmpdir.path);
}

pub fn list() !void {
    try pkglist.handle();
}
