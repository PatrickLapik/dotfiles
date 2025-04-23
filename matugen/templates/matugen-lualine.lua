local colors = {
	background = "{{colors.background.default.hex}}",
	on_background = "{{colors.on_background.default.hex}}",

	primary = "{{colors.primary.default.hex}}",
	on_primary = "{{colors.on_primary.default.hex}}",

	secondary = "{{colors.secondary.default.hex}}",
	on_secondary = "{{colors.on_secondary.default.hex}}",

	tertiary = "{{colors.tertiary.default.hex}}",
	on_tertiary = "{{colors.on_tertiary.default.hex}}",

	error = "{{colors.error.default.hex}}",
	on_error = "{{colors.on_error.default.hex}}",

	surface_variant = "{{colors.surface_variant.default.hex}}",
	on_surface_variant = "{{colors.on_surface_variant.default.hex}}",

	surface_container_low = "{{colors.surface_container_low.default.hex}}",
	surface_container_high = "{{colors.surface_container_high.default.hex}}",
	outline = "{{colors.outline.default.hex}}",
}

return {
	normal = {
		a = { bg = colors.on_background, fg = colors.background, gui = "bold" },
		b = { bg = colors.surface_container_high, fg = colors.on_background },
		c = { bg = colors.surface_container_low, fg = colors.on_background },
	},
	insert = {
		a = { bg = colors.primary, fg = colors.background, gui = "bold" },
		b = { bg = colors.surface_container_high, fg = colors.primary },
		c = { bg = colors.surface_container_low, fg = colors.on_background },
	},
	visual = {
		a = { bg = colors.tertiary, fg = colors.background, gui = "bold" },
		b = { bg = colors.surface_container_high, fg = colors.tertiary },
		c = { bg = colors.surface_container_low, fg = colors.on_background },
	},
	replace = {
		a = { bg = colors.error, fg = colors.background, gui = "bold" },
		b = { bg = colors.surface_container_high, fg = colors.error },
		c = { bg = colors.surface_container_low, fg = colors.on_background },
	},
	command = {
		a = { bg = colors.secondary, fg = colors.background, gui = "bold" },
		b = { bg = colors.surface_container_high, fg = colors.secondary },
		c = { bg = colors.surface_container_low, fg = colors.on_background },
	},
	inactive = {
		a = { bg = colors.surface_container_low, fg = colors.on_surface_variant, gui = "bold" },
		b = { bg = colors.surface_container_low, fg = colors.on_surface_variant },
		c = { bg = colors.surface_container_low, fg = colors.on_surface_variant },
	},
}
