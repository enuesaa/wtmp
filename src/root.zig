const pkgregistry = @import("pkg/registry.zig");
const pkgtmpdir = @import("pkg/tmpdir.zig");
const pkgshell = @import("pkg/shell.zig");
const pkglist = @import("pkg/list.zig");

pub fn workInTmp() !void {
    // create registry if not exist
    try pkgregistry.make();

    // create
    const tmpdir = try pkgtmpdir.make();

    // start shell
    try pkgshell.start(tmpdir);
}

pub fn list() !void {
    try pkglist.handle();
}
