const std = @import("std");
const wtmp = @import("wtmp");
const cli = @import("cli");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    // start work-in-tmp
    // NOTE: first argument is the binary name like `wtmp`
    if (args.len == 1) {
        try wtmp.workInTmp();
        return;
    }

    // cli
    var runner = try cli.AppRunner.init(allocator);

    const app = cli.App{
        .command = cli.Command{
            .name = "wtmp",
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
                                .exec = wtmp.list,
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
    return runner.run(&app);
}
