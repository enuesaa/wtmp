const std = @import("std");
const ttm = @import("ttm");
const cli = @import("cli");
const config = @import("config");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    // first argument is the binary name like `ttm`
    if (args.len == 1) {
        try ttm.workInTmp();
        return;
    }
    try launchCLI();
}

var cliargs = struct {
    pinFrom: []const u8 = undefined,
    pinTo: []const u8 = undefined,
}{};

pub fn launchCLI() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    // cli
    var runner = try cli.AppRunner.init(allocator);

    const app = cli.App{
        .version = config.version,
        .command = cli.Command{
            .name = "ttm",
            .description = cli.Description{
                .one_line = "A CLI tool to manage tmp dirs for throwaway work",
            },
            .target = cli.CommandTarget{
                .subcommands = try runner.allocCommands(&.{
                    cli.Command{
                        .name = "ls",
                        .description = cli.Description{
                            .one_line = "list tmp dirs",
                        },
                        .target = cli.CommandTarget{
                            .action = cli.CommandAction{
                                .exec = ttm.list,
                            },
                        },
                    },
                    cli.Command{
                        .name = "pin",
                        .description = cli.Description{
                            .one_line = "pin session",
                        },
                        .target = cli.CommandTarget{
                            .action = cli.CommandAction{
                                .positional_args = cli.PositionalArgs{
                                    .required = try runner.allocPositionalArgs(&.{
                                        .{
                                            .name = "FROM",
                                            .help = "tmpdir name",
                                            .value_ref = runner.mkRef(&cliargs.pinFrom),
                                        },
                                        .{
                                            .name = "TO",
                                            .help = "tmpdir name",
                                            .value_ref = runner.mkRef(&cliargs.pinTo),
                                        },
                                    }),
                                },
                                .exec = pin,
                            },
                        },
                    },
                }),
            },
        },
        .help_config = cli.HelpConfig{
            .color_usage = .never,
        },
    };
    defer allocator.free(cliargs.pinFrom);
    defer allocator.free(cliargs.pinTo);
    try runner.run(&app);
}

fn pin() !void {
    try ttm.pin(cliargs.pinFrom, cliargs.pinTo);
}
