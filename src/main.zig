const std = @import("std");
const wtmp = @import("wtmp");

// pub fn main() !void {
//     std.debug.print("start\n", .{});

//     // create tmp dir here
//     try wtmp.mkdir();

//     // start shell
//     try wtmp.shell();

//     // delete tmp dir here
//     try wtmp.rmdir();
// }

const cli = @import("cli");

var config = struct {
    host: []const u8 = "localhost",
    port: u16 = undefined,
}{};

pub fn main() !void {
    var r = try cli.AppRunner.init(std.heap.page_allocator);

    const app = cli.App{
        .command = cli.Command{
            .name = "short",
            .options = try r.allocOptions(&.{
                .{
                    .long_name = "host",
                    .help = "host to listen on",
                    .value_ref = r.mkRef(&config.host),
                },
                .{
                    .long_name = "port",
                    .help = "port to bind to",
                    .required = true,
                    .value_ref = r.mkRef(&config.port),
                },
            }),
            .target = cli.CommandTarget{
                .action = cli.CommandAction{
                    .exec = dd,
                },
            },
        },
    };
    return r.run(&app);
}

fn dd() !void {
    std.log.debug("dd", .{});
}
