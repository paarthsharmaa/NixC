-- Hyprland entry point.
-- Common behaviour is shared by every graphical host.
-- Hardware-specific differences live under hosts/.

local hostnameFile =
    assert(
        io.open("/etc/hostname", "r"),
        "Unable to read /etc/hostname"
    )

local hostname =
    assert(
        hostnameFile:read("*l"),
        "Unable to read hostname"
    )

hostnameFile:close()

require("common.appearance")
require("common.input")
require("common.binds")
require("common.rules")

local supportedHosts = {
    yoga = true,
    legion = true,
}

local profile =
    supportedHosts[hostname]
        and hostname
        or "generic"

require("hosts." .. profile)
