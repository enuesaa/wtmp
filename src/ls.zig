const std = @import("std");
const vaxis = @import("vaxis");
const vxfw = vaxis.vxfw;

const Model = struct {
    split: vxfw.SplitView,
    lhs: vxfw.Text,
    rhs: vxfw.Text,
    children: [1]vxfw.SubSurface = undefined,
    menu: [3][]const u8 = [_][]const u8{ "top", "second", "third" },
    selected: u32 = 0,

    pub fn widget(self: *Model) vxfw.Widget {
        return .{
            .userdata = self,
            .eventHandler = Model.eventHandler,
            .drawFn = Model.drawFn,
        };
    }

    fn eventHandler(ptr: *anyopaque, ctx: *vxfw.EventContext, event: vxfw.Event) !void {
        const self: *Model = @ptrCast(@alignCast(ptr));
        switch (event) {
            .init => {
                self.split.lhs = self.lhs.widget();
                self.split.rhs = self.rhs.widget();
            },
            .key_press => |key| {
                if (key.matches('c', .{ .ctrl = true })) {
                    ctx.quit = true;
                    return;
                }
                if (key.matches('q', .{})) {
                    ctx.quit = true;
                    return;
                }
                if (key.codepoint == vaxis.Key.up) {
                    if (self.selected > 0) {
                        self.selected -|= 1;
                    }
                    return ctx.consumeAndRedraw();
                }
                if (key.codepoint == vaxis.Key.down) {
                    if (self.selected + 1 < self.menu.len) {
                        self.selected +|= 1;
                    }
                    return ctx.consumeAndRedraw();
                }
                if (key.codepoint == vaxis.Key.enter) {
                    ctx.quit = true;
                    return;
                }
            },
            else => {},
        }
    }

    fn drawFn(ptr: *anyopaque, ctx: vxfw.DrawContext) !vxfw.Surface {
        const self: *Model = @ptrCast(@alignCast(ptr));

        self.lhs.text = try Model.buildMenuText(ptr, ctx);
        self.split.lhs = self.lhs.widget();
        self.rhs.text = try std.fmt.allocPrint(ctx.arena, "  right {s}\n", .{self.menu[self.selected]});
        self.split.rhs = self.rhs.widget();

        self.children[0] = .{
            .origin = .{ .row = 1, .col = 1 },
            .surface = try self.split.widget().draw(ctx),
        };

        return .{
            .size = ctx.max.size(),
            .widget = self.widget(),
            .buffer = &.{},
            .children = &self.children,
        };
    }

    fn buildMenuText(ptr: *anyopaque, ctx: vxfw.DrawContext) ![]u8 {
        const self: *Model = @ptrCast(@alignCast(ptr));
        var buf = std.array_list.Managed([]const u8).init(ctx.arena);

        for (self.menu, 0..) |item, i| {
            const text = try std.fmt.allocPrint(ctx.arena, "{s}{s}\n", .{
                if (self.selected == i) "> " else "  ",
                item,
            });
            try buf.append(text);
        }
        return try std.mem.join(ctx.arena, "", buf.items[0..buf.items.len]);
    }
};

fn launch() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var app = try vxfw.App.init(allocator);
    defer app.deinit();

    const model = try allocator.create(Model);
    defer allocator.destroy(model);

    model.* = .{
        .lhs = .{ .text = "" },
        .rhs = .{ .text = "  right" },
        .split = .{ .lhs = undefined, .rhs = undefined, .width = 20 },
    };
    try app.run(model.widget(), .{});
}

pub fn handle() !void {
    launch() catch |e| {
        std.debug.print("run error: {}\n", .{e});
    };
    std.debug.print("a", .{});
}
