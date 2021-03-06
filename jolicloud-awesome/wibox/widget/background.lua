---------------------------------------------------------------------------
-- @author Uli Schlachter
-- @copyright 2010 Uli Schlachter
-- @release v3.4-799-g4711354
---------------------------------------------------------------------------

local base = require("wibox.widget.base")
local color = require("gears.color")
local layout_base = require("wibox.layout.base")
local surface = require("gears.surface")
local cairo = require("lgi").cairo
local setmetatable = setmetatable
local pairs = pairs
local type = type

-- wibox.widget.background
local background = { mt = {} }

--- Draw this widget
function background.draw(box, wibox, cr, width, height)
    if not box.widget then
        return
    end

    cr:save()

    if box.background then
        cr:set_source(box.background)
        cr:paint()
    end
    if box.bgimage then
        local pattern = cairo.Pattern.create_for_surface(box.bgimage)
        cr:set_source(pattern)
        pattern.extend = 'REPEAT'
        cr:rectangle(0, 0, width, height)
        cr:fill()
        -- cr:paint()
    end

    cr:restore()

    if box.foreground then
        cr:save()
        cr:set_source(box.foreground)
    end
    layout_base.draw_widget(wibox, cr, box.widget, 0, 0, width, height)
    if box.foreground then
        cr:restore()
    end
end

--- Fit this widget into the given area
function background.fit(box, width, height)
    if not box.widget then
        return 0, 0
    end

    return box.widget:fit(width, height)
end

--- Set the widget that is drawn on top of the background
function background.set_widget(box, widget)
    if box.widget then
        box.widget:disconnect_signal("widget::updated", box._emit_updated)
    end
    if widget then
        base.check_widget(widget)
        widget:connect_signal("widget::updated", box._emit_updated)
    end
    box.widget = widget
    box._emit_updated()
end

--- Set the background to use
function background.set_bg(box, bg)
    if bg then
        box.background = color(bg)
    else
        box.background = nil
    end
    box._emit_updated()
end

--- Set the foreground to use
function background.set_fg(box, fg)
    if fg then
        box.foreground = color(fg)
    else
        box.foreground = nil
    end
    box._emit_updated()
end

--- Set the background image to use
function background.set_bgimage(box, image)
    box.bgimage = surface.load(image)
    box._emit_updated()
end

local function new()
    local ret = base.make_widget()

    for k, v in pairs(background) do
        if type(v) == "function" then
            ret[k] = v
        end
    end

    ret._emit_updated = function()
        ret:emit_signal("widget::updated")
    end

    return ret
end

function background.mt:__call(...)
    return new(...)
end

return setmetatable(background, background.mt)

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:textwidth=80
