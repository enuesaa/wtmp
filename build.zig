const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // mod
    const mod = b.addModule("wtmp", .{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
    });
    const exe = b.addExecutable(.{
        .name = "wtmp",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{
                .{ .name = "wtmp", .module = mod },
            },
        }),
    });
    b.installArtifact(exe);

    // run
    const run_step = b.step("run", "Run the app");
    const run_cmd = b.addRunArtifact(exe);
    run_step.dependOn(&run_cmd.step);
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    // test
    const test_step = b.step("test", "Run tests");
    const test_mod = b.addTest(.{
        .root_module = mod,
    });
    const test_mod_run = b.addRunArtifact(test_mod);
    test_step.dependOn(&test_mod_run.step);
}
