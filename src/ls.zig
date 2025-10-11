const std = @import("std");
const vaxis = @import("vaxis");
const vxfw = vaxis.vxfw;

const Model = struct {
    split: vxfw.SplitView,
    lhs: vxfw.Text,
    rhs: vxfw.Text,
    children: [1]vxfw.SubSurface = undefined,
    count: u32 = 0,
    menuItems: [3][]const u8 = [_][]const u8{ "top", "second", "third" },
    selected: u32 = 0,

    pub fn widget(self: *Model) vxfw.Widget {
        return .{
            .userdata = self,
            .eventHandler = Model.eventHandler,
            .drawFn = Model.drawFn,
        };
    }

    fn eventHandler(ptr: *anyopaque, ctx: *vxfw.EventContext, event: vxfw.Event) anyerror!void {
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
                if (key.matches('t', .{})) {
                    if (self.selected > 0) {
                        self.selected -|= 1;
                    }
                    return ctx.consumeAndRedraw();
                }
                if (key.matches('b', .{})) {
                    if (self.selected + 1 < self.menuItems.len) {
                        self.selected +|= 1;
                    }
                    return ctx.consumeAndRedraw();
                }
                if (key.matches('a', .{})) {
                    self.count +|= 1;
                    return ctx.consumeAndRedraw();
                }
            },
            else => {},
        }
    }

    fn drawFn(ptr: *anyopaque, ctx: vxfw.DrawContext) std.mem.Allocator.Error!vxfw.Surface {
        const self: *Model = @ptrCast(@alignCast(ptr));

        self.lhs.text = try std.fmt.allocPrint(ctx.arena, "{s}\n{s}\n{s}\n", .{
            if (self.selected == 0) "> top" else "  top",
            if (self.selected == 1) "> second" else "  second",
            if (self.selected == 2) "> third" else "  third",
        });

        self.rhs.text = try std.fmt.allocPrint(ctx.arena, "Clicks: {d}", .{self.count});

        self.split.lhs = self.lhs.widget();
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
};

pub fn handle() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var app = try vxfw.App.init(allocator);
    defer app.deinit();

    const model = try allocator.create(Model);
    defer allocator.destroy(model);

    model.* = .{
        .lhs = .{ .text = "Left side" },
        .rhs = .{ .text = "right side" },
        .split = .{ .lhs = undefined, .rhs = undefined, .width = 20 },
    };
    model.split.lhs = model.lhs.widget();
    model.split.rhs = model.rhs.widget();

    try app.run(model.widget(), .{});
}
